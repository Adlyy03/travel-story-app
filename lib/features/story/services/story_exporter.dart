import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/story_model.dart';
import '../story_renderer.dart';

/// Renders StoryModel to a 1080x1920 PNG file in temp directory.
/// Caller is responsible for cleanup after sharing.
class StoryExporter {
  /// Returns path to the exported PNG file.
  /// The file is in the system temp dir — clean up via [cleanup].
  Future<String> exportImage(StoryModel story) async {
    final bytes = await _render(story);
    final dir = await getTemporaryDirectory();
    final filename = _filename(story);
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    debugPrint('[StoryExporter] Exported image: ${file.path}');
    return file.path;
  }

  /// Returns raw PNG bytes without writing to disk.
  Future<Uint8List> renderBytes(StoryModel story) => _render(story);

  /// Delete temp file after sharing to prevent cache bloat.
  Future<void> cleanup(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
        debugPrint('[StoryExporter] Cleaned up: $filePath');
      }
    } catch (e) {
      debugPrint('[StoryExporter] Cleanup error: $e');
    }
  }

  Future<Uint8List> _render(StoryModel story) async {
    final renderer = StoryRenderer();
    return await renderer.render(story);
  }

  String _filename(StoryModel story) {
    final date = story.date;
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return 'travel_story_${dateStr}_${story.tripId.substring(0, 8)}.png';
  }
}

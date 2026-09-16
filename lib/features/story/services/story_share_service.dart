import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/story_model.dart';
import 'story_exporter.dart';

class StoryShareService {
  final StoryExporter _exporter = StoryExporter();

  /// Save to device gallery. Returns true on success.
  Future<bool> saveToGallery(StoryModel story) async {
    String? tempPath;
    try {
      tempPath = await _exporter.exportImage(story);
      await Gal.putImage(tempPath);
      debugPrint('[StoryShareService] Saved to gallery');
      return true;
    } catch (e) {
      debugPrint('[StoryShareService] Save to gallery error: $e');
      return false;
    } finally {
      // Keep gallery copy; only clean temp
      if (tempPath != null) await _exporter.cleanup(tempPath);
    }
  }

  /// Native share sheet (WhatsApp, Instagram, TikTok, etc.)
  Future<void> shareStory(StoryModel story) async {
    String? tempPath;
    try {
      tempPath = await _exporter.exportImage(story);
      final xFile = XFile(tempPath, mimeType: 'image/png');
      final text = story.title.isNotEmpty
          ? 'Cerita perjalananku: ${story.title}'
          : 'Lihat cerita perjalananku!';
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: text,
          subject: story.title,
        ),
      );
    } catch (e) {
      debugPrint('[StoryShareService] Share error: $e');
      rethrow;
    } finally {
      // Delay cleanup to ensure share sheet has read the file
      if (tempPath != null) {
        Future.delayed(const Duration(seconds: 30), () {
          _exporter.cleanup(tempPath!);
        });
      }
    }
  }

  /// Save to app documents directory for persistent access.
  Future<String?> saveToAppDocuments(StoryModel story) async {
    try {
      final bytes = await _exporter.renderBytes(story);
      final dir = await getApplicationDocumentsDirectory();
      final storiesDir = Directory('${dir.path}/stories');
      if (!storiesDir.existsSync()) storiesDir.createSync(recursive: true);
      final path = '${storiesDir.path}/story_${story.tripId}.png';
      await File(path).writeAsBytes(bytes);
      debugPrint('[StoryShareService] Saved to documents: $path');
      return path;
    } catch (e) {
      debugPrint('[StoryShareService] Save to documents error: $e');
      return null;
    }
  }
}

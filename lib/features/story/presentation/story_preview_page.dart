import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/story_model.dart';
import '../story_renderer.dart';
import '../../trip/data/trip_repository.dart';
import '../../trip/data/trip_local_data_source.dart';
import '../../../core/theme/app_colors.dart';

/// Day 24: Story Preview — shows exact story output before export.
class StoryPreviewPage extends StatefulWidget {
  const StoryPreviewPage({super.key});

  @override
  State<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

class _StoryPreviewPageState extends State<StoryPreviewPage> {
  StoryModel? _story;
  Uint8List? _imageBytes;
  bool _isRendering = true;
  String? _error;
  String? _customBackgroundPath;
  late TripRepository _tripRepository;

  @override
  void initState() {
    super.initState();
    _tripRepository = TripRepository(TripLocalDataSource());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final story = ModalRoute.of(context)?.settings.arguments as StoryModel?;
    if (story != null && _story == null) {
      _story = story;
      _customBackgroundPath = story.backgroundImagePath;
      _renderStory(story);
    } else if (story == null && _story == null) {
      setState(() {
        _isRendering = false;
        _error = 'Data story tidak ditemukan';
      });
    }
  }

  Future<void> _renderStory(StoryModel story) async {
    setState(() {
      _isRendering = true;
      _error = null;
    });
    try {
      final renderer = StoryRenderer();
      final storyWithBackground = StoryModel(
        tripId: story.tripId,
        title: story.title,
        date: story.date,
        route: story.route,
        distanceMeters: story.distanceMeters,
        durationSeconds: story.durationSeconds,
        elevationGainMeters: story.elevationGainMeters,
        places: story.places,
        timeline: story.timeline,
        backgroundImagePath: _customBackgroundPath,
        routePoints: story.routePoints,
      );
      final bytes = await renderer.render(storyWithBackground);
      setState(() {
        _imageBytes = bytes;
        _isRendering = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Render failed: $e';
        _isRendering = false;
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    if (_isRendering) return;
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      // Copy to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final storageDir = Directory('${appDir.path}/story_backgrounds');
      if (!storageDir.existsSync()) {
        storageDir.createSync(recursive: true);
      }

      final filename = 'bg_${_story!.tripId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${storageDir.path}/$filename';
      await File(image.path).copy(savedPath);

      // Save to database
      await _tripRepository.updateStoryBackgroundImage(_story!.tripId, savedPath);

      // Update UI
      setState(() {
        _customBackgroundPath = savedPath;
      });

      // Re-render
      _renderStory(_story!);
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _resetBackground() async {
    if (_isRendering) return;
    try {
      await _tripRepository.updateStoryBackgroundImage(_story!.tripId, null);
      setState(() {
        _customBackgroundPath = null;
      });
      _renderStory(_story!);
    } catch (e) {
      setState(() {
        _error = 'Failed to reset: $e';
      });
    }
  }

  void _navigateToExport() {
    Navigator.pushNamed(
      context,
      '/story/export',
      arguments: {
        'story': StoryModel(
          tripId: _story!.tripId,
          title: _story!.title,
          date: _story!.date,
          route: _story!.route,
          distanceMeters: _story!.distanceMeters,
          durationSeconds: _story!.durationSeconds,
          elevationGainMeters: _story!.elevationGainMeters,
          places: _story!.places,
          timeline: _story!.timeline,
          backgroundImagePath: _customBackgroundPath,
          routePoints: _story!.routePoints,
        ),
        'bytes': _imageBytes,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.surface,
        title: const Text('Pratinjau Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.surface),
            tooltip: 'Edit Template & Desain',
            onPressed: () {
              if (_story != null) {
                Navigator.pushNamed(context, '/story/editor', arguments: _story!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.surface),
            tooltip: 'Putar Video Story',
            onPressed: () {
              if (_story != null) {
                Navigator.pushNamed(context, '/story/player', arguments: _story!);
              }
            },
          ),
          if (_imageBytes != null)
            TextButton.icon(
              onPressed: _navigateToExport,
              icon: const Icon(Icons.share_outlined, color: AppColors.surface, size: 20),
              label: const Text('Export', style: TextStyle(color: AppColors.surface, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _isRendering
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.surface),
                  SizedBox(height: 16),
                  Text('Memproses story...', style: TextStyle(color: AppColors.inkSoft)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, 
                          style: const TextStyle(color: AppColors.danger),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _renderStory(_story!),
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _imageBytes != null
                  ? Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: InteractiveViewer(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: AppColors.ink,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ActionButton(
                                icon: Icons.photo_outlined,
                                label: 'Ganti Foto',
                                onTap: _pickBackgroundImage,
                              ),
                              if (_customBackgroundPath != null)
                                _ActionButton(
                                  icon: Icons.refresh_outlined,
                                  label: 'Reset Foto',
                                  onTap: _resetBackground,
                                ),
                              _ActionButton(
                                icon: Icons.share_outlined,
                                label: 'Export',
                                onTap: _navigateToExport,
                                primary: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? AppColors.accent : AppColors.surface.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.surface, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.surface, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

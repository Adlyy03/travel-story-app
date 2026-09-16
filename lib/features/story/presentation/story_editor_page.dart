import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../domain/story_model.dart';
import '../domain/story_template.dart';
import '../services/story_share_service.dart';
import '../story_renderer.dart';
import '../../trip/data/trip_repository.dart';
import '../../trip/data/trip_local_data_source.dart';
import '../../../shared/models/trip_photo.dart';
import '../../../core/theme/app_colors.dart';

class StoryEditorPage extends StatefulWidget {
  const StoryEditorPage({super.key});

  @override
  State<StoryEditorPage> createState() => _StoryEditorPageState();
}

class _StoryEditorPageState extends State<StoryEditorPage>
    with SingleTickerProviderStateMixin {
  StoryModel? _story;
  Uint8List? _previewBytes;
  bool _isRendering = false;
  bool _isExporting = false;
  String? _renderError;

  late TabController _tabCtrl;
  late TripRepository _repository;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _repository = TripRepository(TripLocalDataSource());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_story == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is StoryModel) {
        _story = args;
        _renderPreview();
      }
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _renderPreview() async {
    if (_story == null || _isRendering) return;
    setState(() {
      _isRendering = true;
      _renderError = null;
    });
    try {
      final bytes = await StoryRenderer().render(_story!);
      if (mounted) {
        setState(() {
          _previewBytes = bytes;
          _isRendering = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _renderError = e.toString();
          _isRendering = false;
        });
      }
    }
  }

  void _updateStory(StoryModel updated) {
    setState(() => _story = updated);
    _renderPreview();
  }

  Future<void> _addPhoto() async {
    if (_story == null) return;
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultiImage();
      if (files.isEmpty) return;

      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/trip_photos');
      if (!photosDir.existsSync()) photosDir.createSync(recursive: true);

      final uuid = const Uuid();
      final newPhotos = <TripPhoto>[];
      for (final file in files) {
        final ext = file.path.split('.').last.toLowerCase();
        final id = uuid.v4();
        final dest = '${photosDir.path}/$id.$ext';
        await File(file.path).copy(dest);
        final photo = TripPhoto(
          id: id,
          tripId: _story!.tripId,
          path: dest,
          timestamp: DateTime.now(),
        );
        await _repository.addTripPhoto(photo);
        newPhotos.add(photo);
      }

      _updateStory(_story!.copyWith(
        photos: [..._story!.photos, ...newPhotos],
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah foto: $e')),
        );
      }
    }
  }

  Future<void> _removePhoto(TripPhoto photo) async {
    if (_story == null) return;
    await _repository.deleteTripPhoto(photo.id);
    final updated = List<TripPhoto>.from(_story!.photos)
      ..removeWhere((p) => p.id == photo.id);
    _updateStory(_story!.copyWith(photos: updated));
  }

  Future<void> _shareStory() async {
    if (_story == null || _isExporting) return;
    setState(() => _isExporting = true);
    try {
      await StoryShareService().shareStory(_story!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_story == null || _isExporting) return;
    setState(() => _isExporting = true);
    try {
      final ok = await StoryShareService().saveToGallery(_story!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Tersimpan ke galeri' : 'Gagal menyimpan'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _openAnimatedPlayer() {
    if (_story == null) return;
    Navigator.pushNamed(context, '/story/player', arguments: _story!);
  }

  void _openFullscreenPreview() {
    if (_previewBytes == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenPreview(bytes: _previewBytes!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('Story Editor',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
        iconTheme: const IconThemeData(color: AppColors.ink),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accent)),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.ink),
              onSelected: (v) {
                if (v == 'gallery') _saveToGallery();
                if (v == 'share') _shareStory();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'gallery',
                  child: Row(
                    children: [
                      Icon(Icons.photo_library_outlined),
                      SizedBox(width: 12),
                      Text('Simpan ke Galeri'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined),
                      SizedBox(width: 12),
                      Text('Bagikan Story'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _story == null
          ? const Center(child: Text('Tidak ada data story'))
          : Column(
              children: [
                // ── Preview Card ──────────────────────────────────────────
                _buildPreviewCard(),

                // ── Tab Bar ───────────────────────────────────────────────
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    controller: _tabCtrl,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.inkSoft,
                    indicatorColor: AppColors.accent,
                    indicatorWeight: 2.5,
                    tabs: const [
                      Tab(text: 'Template'),
                      Tab(text: 'Konten'),
                      Tab(text: 'Foto'),
                    ],
                  ),
                ),

                // ── Tab Content ───────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _TemplateTab(story: _story!, onUpdate: _updateStory),
                      _ContentTab(story: _story!, onUpdate: _updateStory),
                      _PhotosTab(
                        story: _story!,
                        onAddPhoto: _addPhoto,
                        onRemovePhoto: _removePhoto,
                      ),
                    ],
                  ),
                ),

                // ── Bottom Action Bar ────────────────────────────────────
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      color: const Color(0xFF111827),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 9:16 Preview
          SizedBox(
            height: 220,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: GestureDetector(
                onTap: _previewBytes != null ? _openFullscreenPreview : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Preview content
                      if (_isRendering)
                        Container(
                          color: Colors.black45,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white60),
                                SizedBox(height: 8),
                                Text('Rendering...',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                          ),
                        )
                      else if (_renderError != null)
                        Container(
                          color: const Color(0xFF1A0A0A),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.white38, size: 28),
                              const SizedBox(height: 6),
                              const Text('Error render',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 10)),
                              TextButton(
                                onPressed: _renderPreview,
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 28)),
                                child: const Text('Coba lagi',
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 11)),
                              ),
                            ],
                          ),
                        )
                      else if (_previewBytes != null)
                        Image.memory(_previewBytes!, fit: BoxFit.cover)
                      else
                        Container(
                          color: const Color(0xFF0F172A),
                          child: const Center(
                            child: Text('Pilih template',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 10)),
                          ),
                        ),

                      // Tap to fullscreen overlay
                      if (_previewBytes != null && !_isRendering)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.fullscreen,
                                color: Colors.white60, size: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Action buttons column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play button (always visible if story available)
              _PreviewActionButton(
                icon: Icons.play_circle_filled_rounded,
                label: 'Play',
                color: AppColors.accent,
                onTap: _openAnimatedPlayer,
              ),
              const SizedBox(height: 12),
              // Refresh render
              _PreviewActionButton(
                icon: Icons.refresh_rounded,
                label: 'Render',
                color: Colors.white60,
                onTap: _isRendering ? null : _renderPreview,
              ),
              const SizedBox(height: 12),
              // Share
              _PreviewActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                color: Colors.white60,
                onTap: _isExporting ? null : _shareStory,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _openAnimatedPlayer,
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: const Text('Putar Story Sekarang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small action button for preview panel
// ---------------------------------------------------------------------------
class _PreviewActionButton extends StatelessWidget {
  const _PreviewActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Template Tab
// ---------------------------------------------------------------------------
class _TemplateTab extends StatelessWidget {
  const _TemplateTab({required this.story, required this.onUpdate});
  final StoryModel story;
  final void Function(StoryModel) onUpdate;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: StoryTemplate.values.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final tpl = StoryTemplate.values[i];
        final selected = story.template == tpl;
        return InkWell(
          onTap: () => onUpdate(story.copyWith(template: tpl)),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconFor(tpl),
                    color: selected ? Colors.white : AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tpl.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: selected ? AppColors.accent : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tpl.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: AppColors.accent, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(StoryTemplate tpl) {
    switch (tpl) {
      case StoryTemplate.minimal:
        return Icons.crop_square_outlined;
      case StoryTemplate.glass:
        return Icons.blur_on_outlined;
      case StoryTemplate.cinematic:
        return Icons.movie_outlined;
      case StoryTemplate.strava:
        return Icons.route_outlined;
      case StoryTemplate.journal:
        return Icons.menu_book_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Content Tab
// ---------------------------------------------------------------------------
class _ContentTab extends StatefulWidget {
  const _ContentTab({required this.story, required this.onUpdate});
  final StoryModel story;
  final void Function(StoryModel) onUpdate;

  @override
  State<_ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<_ContentTab> {
  late TextEditingController _titleCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.story.title);
  }

  @override
  void didUpdateWidget(covariant _ContentTab old) {
    super.didUpdateWidget(old);
    if (old.story.title != widget.story.title &&
        _titleCtrl.text != widget.story.title) {
      _titleCtrl.text = widget.story.title;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Judul ──────────────────────────────────────────────────────
        _SectionLabel('Judul Perjalanan'),
        const SizedBox(height: 8),
        TextField(
          controller: _titleCtrl,
          onChanged: (v) => widget.onUpdate(story.copyWith(title: v)),
          style: const TextStyle(color: AppColors.ink, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Nama perjalananmu...',
            hintStyle:
                const TextStyle(color: AppColors.inkSoft, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),

        // ── Tampilkan ──────────────────────────────────────────────────
        _SectionLabel('Tampilkan di Story'),
        const SizedBox(height: 8),
        _ToggleTile(
          label: 'Statistik perjalanan',
          subtitle: 'Jarak, durasi, kecepatan',
          icon: Icons.bar_chart_rounded,
          value: story.showStatistics,
          onChanged: (v) =>
              widget.onUpdate(story.copyWith(showStatistics: v)),
        ),
        _ToggleTile(
          label: 'Rute pada peta',
          subtitle: 'Gambar jalur perjalanan',
          icon: Icons.route_outlined,
          value: story.showRoute,
          onChanged: (v) => widget.onUpdate(story.copyWith(showRoute: v)),
        ),
        _ToggleTile(
          label: 'Timeline kejadian',
          subtitle: 'Urutan waktu & pemberhentian',
          icon: Icons.timeline_rounded,
          value: story.showTimeline,
          onChanged: (v) =>
              widget.onUpdate(story.copyWith(showTimeline: v)),
        ),
        _ToggleTile(
          label: 'Foto perjalanan',
          subtitle: 'Tampilkan momen terbaik',
          icon: Icons.photo_library_outlined,
          value: story.showPhotos,
          onChanged: (v) => widget.onUpdate(story.copyWith(showPhotos: v)),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.inkSoft,
          letterSpacing: 0.5),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value ? AppColors.accentSoft : AppColors.bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18,
              color: value ? AppColors.accent : AppColors.inkSoft),
        ),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink)),
        subtitle: Text(subtitle,
            style:
                const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        dense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photos Tab
// ---------------------------------------------------------------------------
class _PhotosTab extends StatelessWidget {
  const _PhotosTab({
    required this.story,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });
  final StoryModel story;
  final VoidCallback onAddPhoto;
  final void Function(TripPhoto) onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Tambah Foto dari Galeri'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: AppColors.accent),
                foregroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        if (story.photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.inkSoft),
                const SizedBox(width: 6),
                Text('${story.photos.length} foto dipilih',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.inkSoft)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (story.photos.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 56, color: AppColors.border),
                  SizedBox(height: 12),
                  Text('Belum ada foto',
                      style: TextStyle(
                          color: AppColors.inkSoft,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('Tambah foto untuk mempercantik story',
                      style:
                          TextStyle(color: AppColors.border, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: story.photos.length,
              itemBuilder: (_, i) {
                final photo = story.photos[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: File(photo.path).existsSync()
                          ? Image.file(
                              File(photo.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(
                              color: AppColors.bg,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.border),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemovePhoto(photo),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fullscreen Preview
// ---------------------------------------------------------------------------
class _FullscreenPreview extends StatelessWidget {
  const _FullscreenPreview({required this.bytes});
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Preview Fullscreen'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

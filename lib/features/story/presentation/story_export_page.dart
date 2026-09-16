import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import '../domain/story_model.dart';
import '../../../core/theme/app_colors.dart';

class StoryExportPage extends StatefulWidget {
  const StoryExportPage({super.key});

  @override
  State<StoryExportPage> createState() => _StoryExportPageState();
}

class _StoryExportPageState extends State<StoryExportPage> {
  StoryModel? _story;
  Uint8List? _bytes;
  bool _isExporting = false;
  String? _savedPath;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _story == null) {
      _story = args['story'] as StoryModel?;
      _bytes = args['bytes'] as Uint8List?;
    } else if (args == null && _story == null) {
      _error = 'Data gambar story tidak ditemukan';
    }
  }

  String _generateFilename() {
    if (_story == null) return 'travel_story.png';
    final date = DateFormat('yyyy-MM-dd').format(_story!.date);
    return 'travel_story_$date.png';
  }

  Future<void> _saveToGallery() async {
    if (_bytes == null || _isExporting) return;
    setState(() {
      _isExporting = true;
      _error = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final filename = _generateFilename();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(_bytes!);

      await Gal.putImage(file.path);

      setState(() {
        _savedPath = 'Gallery';
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tersimpan ke galeri')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal menyimpan: $e';
        _isExporting = false;
      });
    }
  }

  Future<void> _share() async {
    if (_bytes == null || _isExporting) return;
    setState(() => _isExporting = true);

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${_generateFilename()}');
      await file.writeAsBytes(_bytes!);

      final xFile = XFile(file.path, mimeType: 'image/png');
      final textMsg = _story?.title.isNotEmpty == true
          ? 'Lihat perjalananku: ${_story!.title}'
          : 'Lihat perjalananku di Travel Story!';

      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: textMsg,
          subject: _story?.title ?? 'Travel Story',
        ),
      );
    } catch (e) {
      setState(() => _error = 'Gagal membagikan: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.surface,
        title: const Text('Export & Bagikan Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_bytes != null) ...[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_bytes!, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.danger)),
              ),
            if (_savedPath != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.accent, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tersimpan ke galeri',
                        style: TextStyle(color: AppColors.accent, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isExporting)
              const CircularProgressIndicator(color: AppColors.surface)
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveToGallery,
                      icon: const Icon(Icons.download_outlined, size: 20),
                      label: const Text('Simpan Galeri'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.surface),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_outlined, size: 20),
                      label: const Text('Bagikan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

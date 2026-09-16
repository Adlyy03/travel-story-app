import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/trip.dart';
import '../../core/theme/app_colors.dart';
import 'data/trip_repository.dart';
import 'data/trip_local_data_source.dart';

class TripFormPage extends StatefulWidget {
  final Trip? trip;

  const TripFormPage({super.key, this.trip});

  @override
  State<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
  late final TripRepository _repository;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();

  late DateTime _selectedDateTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _repository = TripRepository(TripLocalDataSource());

    final initialTrip = widget.trip;
    if (initialTrip != null) {
      _nameController.text = initialTrip.title ??
          'Trip ${DateFormat('dd/MM/yyyy').format(initialTrip.startedAt)}';
      _selectedDateTime = initialTrip.startedAt;
      if (initialTrip.distanceMeters != null && initialTrip.distanceMeters! > 0) {
        _distanceController.text =
            (initialTrip.distanceMeters! / 1000).toStringAsFixed(1);
      }
    } else {
      _selectedDateTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.surface,
              surface: AppColors.surface,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.surface,
              surface: AppColors.surface,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      double? distanceMeters;
      final distText = _distanceController.text.trim().replaceAll(',', '.');
      if (distText.isNotEmpty) {
        final parsedKm = double.tryParse(distText);
        if (parsedKm != null && parsedKm > 0) {
          distanceMeters = parsedKm * 1000;
        }
      }

      if (widget.trip == null) {
        final newTrip = Trip(
          id: const Uuid().v4(),
          title: name,
          startedAt: _selectedDateTime,
          endedAt: _selectedDateTime.add(const Duration(hours: 1)),
          status: TripStatus.completed,
          distanceMeters: distanceMeters ?? 0.0,
          durationSeconds: 3600,
          syncStatus: SyncStatus.pending,
        );
        await _repository.createTrip(newTrip);
      } else {
        final existing = widget.trip!;
        final updatedTrip = existing.copyWith(
          title: name,
          startedAt: _selectedDateTime,
          distanceMeters: distanceMeters ?? existing.distanceMeters,
          syncStatus: SyncStatus.pending,
        );
        await _repository.updateTrip(updatedTrip);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.trip == null
                ? 'Trip berhasil dibuat'
                : 'Perubahan berhasil disimpan'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan trip'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.trip != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Trip' : 'Buat Trip Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nama Trip field
            const Text(
              'Nama Trip',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Misal: Liburan ke Puncak',
                prefixIcon: Icon(Icons.edit_outlined, size: 20),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama trip harus diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Tanggal & Waktu field
            const Text(
              'Waktu Perjalanan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _isSaving ? null : _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppColors.inkSoft),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMMM yyyy, HH:mm')
                              .format(_selectedDateTime),
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.ink),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.inkSoft),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Jarak estimasi (optional)
            const Text(
              'Jarak Tempuh (km) — Opsional',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _distanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Contoh: 15.5',
                prefixIcon: Icon(Icons.straighten, size: 20),
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 36),

            // Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : Text(isEdit ? 'Simpan' : 'Buat Trip'),
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

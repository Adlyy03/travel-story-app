import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/tracking_service.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/models/trip.dart';

class LiveTripSheet extends StatefulWidget {
  const LiveTripSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LiveTripSheet(),
    );
  }

  @override
  State<LiveTripSheet> createState() => _LiveTripSheetState();
}

class _LiveTripSheetState extends State<LiveTripSheet> {
  Timer? _timer;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Trip trip) {
    final totalSec = DateTime.now().difference(trip.startedAt).inSeconds;
    final activeSec = (totalSec - trip.pausedDurationSeconds).clamp(0, 8640000);
    final h = activeSec ~/ 3600;
    final m = (activeSec % 3600) ~/ 60;
    final s = activeSec % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Trip?>(
      valueListenable: TrackingService.instance.activeTripNotifier,
      builder: (context, activeTrip, child) {
        if (activeTrip == null) {
          if (_isBusy) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 20),
                  Text(
                    'Menyimpan dan mengakhiri perjalanan...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Menghitung statistik & jalur rute...',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 48, color: AppColors.accent),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada perjalanan aktif',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isBusy
                        ? null
                        : () async {
                            setState(() => _isBusy = true);
                            await TrackingService.instance.startTrip();
                            if (mounted) setState(() => _isBusy = false);
                          },
                    icon: _isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(_isBusy ? 'Memulai...' : 'Mulai Perjalanan Baru'),
                  ),
                ),
              ],
            ),
          );
        }

        final isPaused = activeTrip.status == TripStatus.paused;
        final statusColor = isPaused ? const Color(0xFFF59E0B) : AppColors.accent;

        return Container(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isPaused ? 'Status: Istirahat' : 'Statistik Perjalanan Live',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaused
                          ? const Color(0xFFFEF3C7)
                          : AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPaused ? 'ISTIRAHAT' : 'REC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Live stats grid
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _statItem(
                          isPaused ? 'Durasi Aktif' : 'Durasi Live',
                          _formatDuration(activeTrip),
                          Icons.timer_outlined,
                        ),
                        _statItem(
                          'Waktu Mulai',
                          _formatTime(activeTrip.startedAt),
                          Icons.access_time,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    Row(
                      children: [
                        _statItem(
                          'Jarak Terdaftar',
                          _formatDistance(activeTrip.distanceMeters ?? 0),
                          Icons.straighten,
                        ),
                        _statItem(
                          'Pemberhentian',
                          '${activeTrip.stops.length} lokasi',
                          Icons.place_outlined,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.my_location,
                              size: 18, color: AppColors.accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokasi Terkini',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkSoft),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                TrackingService.instance.lastCapturedPoint != null
                                    ? '${TrackingService.instance.lastCapturedPoint!.latitude.toStringAsFixed(5)}, ${TrackingService.instance.lastCapturedPoint!.longitude.toStringAsFixed(5)}'
                                    : 'Mencari sinyal GPS...',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/trip/map',
                          arguments: activeTrip.id,
                        );
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Rute Map'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        minimumSize: const Size(0, 48),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isPaused)
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await TrackingService.instance.pauseTrip();
                        },
                        icon: const Icon(Icons.pause_circle_outline, size: 20),
                        label: const Text('Istirahat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await TrackingService.instance.resumeTrip();
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Lanjutkan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _isBusy
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hentikan Perjalanan?'),
                                  content: const Text(
                                      'Perjalanan akan disimpan dan tracking dihentikan.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.danger),
                                      child: const Text('Hentikan'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final rootNav = Navigator.of(context, rootNavigator: true);
                                if (mounted) setState(() => _isBusy = true);
                                try {
                                  final stoppedTrip =
                                      await TrackingService.instance.stopTrip();
                                  
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  rootNav.pushNamed(
                                    '/trip/completed',
                                    arguments: stoppedTrip,
                                  );
                                } catch (e) {
                                  debugPrint('[LiveTripSheet] Stop error: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal menghentikan: $e')),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _isBusy = false);
                                }
                              }
                            },
                      icon: _isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.stop_rounded, size: 18),
                      label: Text(_isBusy ? 'Menyimpan...' : 'Hentikan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.surface,
                        minimumSize: const Size(0, 48),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

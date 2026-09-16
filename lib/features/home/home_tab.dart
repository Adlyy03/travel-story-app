import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/location_service.dart';
import '../../core/services/tracking_service.dart';
import '../../features/trip/live_trip_sheet.dart';
import '../trip/data/trip_local_data_source.dart';
import '../trip/data/trip_repository.dart';
import '../story/domain/story_builder.dart';
import '../../shared/models/trip.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/sync_status_badge.dart';

enum StatsTimeframe { weekly, monthly, all }

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final LocationService _locationService;
  late final TrackingService _trackingService;
  late final TripRepository _repository;

  Trip? _todayTrip;
  List<Trip> _completedTrips = [];
  StatsTimeframe _selectedTimeframe = StatsTimeframe.weekly;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _repository = TripRepository(TripLocalDataSource());
    _trackingService = TrackingService.instance;
    _loadData();

    _trackingService.activeTripNotifier.addListener(_onActiveTripChanged);
  }

  @override
  void dispose() {
    _trackingService.activeTripNotifier.removeListener(_onActiveTripChanged);
    super.dispose();
  }

  void _onActiveTripChanged() {
    if (mounted) _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _trackingService.getActiveTrip();
      final trips = await _repository.getAllTrips();
      _completedTrips =
          trips.where((t) => t.status == TripStatus.completed).toList();

      final today = DateTime.now();
      _todayTrip = _completedTrips
          .where((t) =>
              t.startedAt.year == today.year &&
              t.startedAt.month == today.month &&
              t.startedAt.day == today.day)
          .fold<Trip?>(null, (prev, t) {
        if (prev == null) return t;
        return t.startedAt.isAfter(prev.startedAt) ? t : prev;
      });
    } catch (e) {
      _error = 'Gagal memuat data dashboard';
    }

    setState(() => _isLoading = false);
  }

  List<Trip> get _filteredTrips {
    final now = DateTime.now();
    switch (_selectedTimeframe) {
      case StatsTimeframe.weekly:
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return _completedTrips
            .where((t) =>
                t.startedAt.isAfter(startOfWeek) ||
                t.startedAt.isAtSameMomentAs(startOfWeek))
            .toList();
      case StatsTimeframe.monthly:
        return _completedTrips
            .where((t) =>
                t.startedAt.year == now.year &&
                t.startedAt.month == now.month)
            .toList();
      case StatsTimeframe.all:
        return _completedTrips;
    }
  }

  Future<void> _handleStartTripAction() async {
    setState(() => _error = null);
    final active = _trackingService.activeTrip;

    if (active != null) {
      LiveTripSheet.show(context);
    } else {
      final permissionStatus = await _locationService.checkPermission();
      if (permissionStatus != LocationPermissionStatus.granted) {
        final requested = await _locationService.requestPermission();
        if (requested != LocationPermissionStatus.granted) {
          setState(
              () => _error = 'Izin lokasi diperlukan untuk merekam perjalanan');
          return;
        }
      }

      try {
        final trip = await _trackingService.startTrip();
        if (trip == null) {
          setState(() =>
              _error = 'Gagal mendapatkan sinyal GPS. Pastikan GPS aktif.');
          return;
        }
        if (mounted) {
          LiveTripSheet.show(context);
        }
      } catch (e) {
        setState(() => _error = 'Gagal memulai perjalanan');
      }
    }
  }

  String _formatTotalDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}j ${m}m';
    return '${m}m';
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final d = (end ?? DateTime.now()).difference(start);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          const Center(child: SyncStatusBadge()),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) _buildError(),
                    _buildUserStats(),
                    _buildMulaiButtonCard(),
                    if (_todayTrip != null) ...[
                      const SizedBox(height: 16),
                      _buildTodayJourney(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_error!,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    final trips = _filteredTrips;
    final totalDistance =
        trips.fold(0.0, (sum, t) => sum + (t.distanceMeters ?? 0.0));
    final totalTrips = trips.length;
    final totalDuration = trips.fold(Duration.zero, (sum, t) {
      final d = (t.endedAt ?? DateTime.now()).difference(t.startedAt);
      return sum + d;
    });
    final totalStops = trips.fold(0, (sum, t) => sum + t.stops.length);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistik Perjalanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              _buildTimeframeSelector(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Jarak',
                  _formatDistance(totalDistance),
                  Icons.straighten,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Total Trip',
                  '$totalTrips trip',
                  Icons.route_outlined,
                  AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Waktu',
                  _formatTotalDuration(totalDuration),
                  Icons.timer_outlined,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Pemberhentian',
                  '$totalStops lokasi',
                  Icons.place_outlined,
                  AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _timeframeOption('Minggu', StatsTimeframe.weekly),
          _timeframeOption('Bulan', StatsTimeframe.monthly),
          _timeframeOption('Semua', StatsTimeframe.all),
        ],
      ),
    );
  }

  Widget _timeframeOption(String label, StatsTimeframe timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return GestureDetector(
      onTap: () {
        if (_selectedTimeframe != timeframe) {
          setState(() => _selectedTimeframe = timeframe);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.accent : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
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

  Widget _buildMulaiButtonCard() {
    return ValueListenableBuilder<Trip?>(
      valueListenable: _trackingService.activeTripNotifier,
      builder: (context, activeTrip, child) {
        final isLive = activeTrip != null;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isLive ? AppColors.accentSoft : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: isLive ? 0.6 : 0.3),
              width: isLive ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLive ? AppColors.accent : AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLive ? Icons.sensors : Icons.navigation_outlined,
                  size: 36,
                  color: isLive ? AppColors.surface : AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isLive
                    ? 'Perjalanan Sedang Berlangsung'
                    : 'Siap Jelajahi Rute Baru?',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(
                isLive
                    ? 'Klik tombol di bawah untuk melihat statistik live'
                    : 'Mulai perjalanan sekarang dan rekam setiap momenmu',
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _handleStartTripAction,
                  icon: Icon(
                    isLive ? Icons.bar_chart_rounded : Icons.play_arrow_rounded,
                    size: 24,
                  ),
                  label: Text(
                    isLive ? 'Lihat Statistik Live' : 'Mulai Perjalanan',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openStory(Trip trip) async {
    final points = await _repository.getLocationPoints(trip.id);
    final stops = await _repository.getStops(trip.id);

    final fullTrip = trip.copyWith(
      locationPoints: points,
      stops: stops,
    );

    final story = StoryBuilder().build(fullTrip);
    if (mounted) {
      Navigator.pushNamed(context, '/story/preview', arguments: story);
    }
  }

  Widget _buildTodayJourney() {
    final trip = _todayTrip!;
    final titleText = trip.title?.isNotEmpty == true
        ? trip.title!
        : 'Perjalanan hari ini';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_outlined, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleText,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (trip.distanceMeters != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('Jarak', _formatDistance(trip.distanceMeters!)),
                _stat('Durasi', _formatDuration(trip.startedAt, trip.endedAt)),
                if (trip.stops.isNotEmpty)
                  _stat('Berhenti', '${trip.stops.length}'),
              ],
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      '/trip/detail',
                      arguments: trip.id,
                    );
                    if (mounted) _loadData();
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Detail'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openStory(trip),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Story'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
      ],
    );
  }
}

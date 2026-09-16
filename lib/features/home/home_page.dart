import 'package:flutter/material.dart';
import '../../core/services/location_service.dart';
import '../../core/services/tracking_service.dart';
import '../../core/services/trip_engine.dart';
import '../../core/services/gps_cleaner.dart';
import '../../core/services/trip_calculator.dart';
import '../../core/services/elevation_calculator.dart';
import '../../core/services/stop_detector.dart';
import '../../features/trip/data/trip_local_data_source.dart';
import '../../features/trip/data/trip_repository.dart';
import '../../features/story/domain/story_builder.dart';
import '../../shared/models/trip.dart';
import '../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LocationService _locationService;
  late final TrackingService _trackingService;
  late final TripRepository _repository;
  late final TripEngine _tripEngine;

  Trip? _activeTrip;
  Trip? _todayTrip;
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _repository = TripRepository(TripLocalDataSource());
    _tripEngine = TripEngine(
      GpsCleaner(),
      TripCalculator(),
      ElevationCalculator(),
      StopDetector(),
    );
    _trackingService =
        TrackingService(_repository, _locationService, _tripEngine);
    _loadData();
  }

  @override
  void dispose() {
    _trackingService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _activeTrip = await _trackingService.getActiveTrip();
      _trips = await _repository.getAllTrips();

      // Today's journey: latest completed trip from today
      final today = DateTime.now();
      _todayTrip = _trips
          .where((t) =>
              t.status == TripStatus.completed &&
              t.startedAt.year == today.year &&
              t.startedAt.month == today.month &&
              t.startedAt.day == today.day)
          .fold<Trip?>(null, (prev, t) {
        if (prev == null) return t;
        return t.startedAt.isAfter(prev.startedAt) ? t : prev;
      });
    } catch (e) {
      _error = 'Gagal memuat data perjalanan';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _startTrip() async {
    setState(() => _error = null);

    final permissionStatus = await _locationService.checkPermission();

    if (permissionStatus != LocationPermissionStatus.granted) {
      final requested = await _locationService.requestPermission();

      if (requested != LocationPermissionStatus.granted) {
        setState(() {
          _error = 'Izin lokasi diperlukan untuk merekam perjalanan';
        });
        return;
      }
    }

    try {
      final trip = await _trackingService.startTrip();
      setState(() {
        _activeTrip = trip;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memulai perjalanan';
      });
    }
  }

  Future<void> _stopTrip() async {
    setState(() => _error = null);

    try {
      await _trackingService.stopTrip();
      await _loadData();
    } catch (e) {
      setState(() {
        _error = 'Gagal menghentikan perjalanan';
      });
    }
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final duration = (end ?? DateTime.now()).difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  Future<void> _createStory(Trip trip) async {
    final points = await _repository.getLocationPoints(trip.id);
    final stops = await _repository.getStops(trip.id);
    final fullTrip = trip.copyWith(locationPoints: points, stops: stops);
    final story = StoryBuilder().build(fullTrip);
    if (mounted) {
      Navigator.pushNamed(context, '/story/preview', arguments: story);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Story'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
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
                            child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    ),
                  _buildTrackingCard(),
                  if (_todayTrip != null) _buildTodayJourney(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildTripList()),
                ],
              ),
            ),
    );
  }

  Widget _buildTodayJourney() {
    final trip = _todayTrip!;
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
          const Row(
            children: [
              Icon(Icons.today_outlined, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Perjalanan hari ini',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (trip.distanceMeters != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _todayStat('Jarak', _formatDistance(trip.distanceMeters!)),
                _todayStat('Durasi', _formatDuration(trip.startedAt, trip.endedAt)),
                if (trip.stops.isNotEmpty)
                  _todayStat('Berhenti', '${trip.stops.length}'),
              ],
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/trip/detail',
                      arguments: trip.id,
                    );
                    if (result == true && mounted) _loadData();
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Lihat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createStory(trip),
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

  Widget _todayStat(String label, String value) {
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

  Widget _buildTrackingCard() {
    if (_activeTrip == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.location_on_outlined, size: 48, color: AppColors.inkSoft),
            const SizedBox(height: 16),
            const Text(
              'Belum ada perjalanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai simpan cerita perjalananmu',
              style: TextStyle(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startTrip,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('Mulai perjalanan'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Perjalanan berlangsung',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Durasi: ${_formatDuration(_activeTrip!.startedAt, null)}',
            style: const TextStyle(fontSize: 15, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai: ${_formatTime(_activeTrip!.startedAt)}',
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _stopTrip,
              icon: const Icon(Icons.stop, size: 20),
              label: const Text('Berhenti'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList() {
    final completedTrips =
        _trips.where((t) => t.status == TripStatus.completed).toList();

    if (completedTrips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_outlined, size: 48, color: AppColors.inkSoft),
              const SizedBox(height: 16),
              const Text(
                'Belum ada perjalanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yuk, mulai simpan perjalananmu',
                style: TextStyle(color: AppColors.inkSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/trip/form');
                  if (result == true && mounted) _loadData();
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Buat trip'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: completedTrips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = completedTrips[index];
        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/trip/detail',
                arguments: trip.id,
              );
              if (result == true) _loadData();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip ${_formatDate(trip.startedAt)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatTime(trip.startedAt)} → ${trip.endedAt != null ? _formatTime(trip.endedAt!) : ""}',
                          style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDuration(trip.startedAt, trip.endedAt),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.accent),
                      ),
                      const SizedBox(height: 4),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkSoft),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../trip/data/trip_local_data_source.dart';
import '../trip/data/trip_repository.dart';
import '../story/domain/story_builder.dart';
import '../story/domain/story_model.dart';
import '../../shared/models/trip.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/sync_status_badge.dart';

class MemoriesTab extends StatefulWidget {
  const MemoriesTab({super.key});

  @override
  State<MemoriesTab> createState() => _MemoriesTabState();
}

class _MemoriesTabState extends State<MemoriesTab> with AutomaticKeepAliveClientMixin {
  late final TripRepository _repository;
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = TripRepository(TripLocalDataSource());
    _loadTrips();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-refresh setiap kali tab visible
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadTrips();
    }
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final trips = await _repository.getAllTrips();
      setState(() {
        _trips = trips
            .where((t) => t.status == TripStatus.completed)
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      });
    } catch (e) {
      setState(() => _error = 'Gagal memuat kenangan');
    }
    setState(() => _isLoading = false);
  }

  Future<StoryModel> _buildStory(Trip trip) async {
    final points = await _repository.getLocationPoints(trip.id);
    final stops = await _repository.getStops(trip.id);
    final photos = await _repository.getTripPhotos(trip.id);
    final fullTrip = trip.copyWith(locationPoints: points, stops: stops);
    final story = StoryBuilder().build(fullTrip);
    return story.copyWith(photos: photos);
  }

  Future<void> _openStoryEditor(Trip trip) async {
    final story = await _buildStory(trip);
    if (mounted) {
      Navigator.pushNamed(context, '/story/editor', arguments: story);
    }
  }

  Future<void> _playStoryVideo(Trip trip) async {
    final story = await _buildStory(trip);
    if (mounted) {
      Navigator.pushNamed(context, '/story/player', arguments: story);
    }
  }

  Future<void> _previewStory(Trip trip) async {
    final story = await _buildStory(trip);
    if (mounted) {
      Navigator.pushNamed(context, '/story/preview', arguments: story);
    }
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final d = (end ?? DateTime.now()).difference(start);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerita Perjalanan'),
        actions: const [
          Center(child: SyncStatusBadge()),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: AppColors.danger)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadTrips, child: const Text('Coba lagi')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTrips,
                  child: _trips.isEmpty ? _buildEmpty() : _buildGrid(),
                ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 48, color: AppColors.accent),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada Cerita Perjalanan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selesaikan perjalanan untuk merangkum cerita naratif, video animasi, & pilihan template desain.',
                    style: TextStyle(color: AppColors.inkSoft),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final trip = _trips[i];
        return _StoryCard(
          trip: trip,
          formatDistance: _formatDistance,
          formatDuration: _formatDuration,
          onPlayVideo: () => _playStoryVideo(trip),
          onEditStory: () => _openStoryEditor(trip),
          onPreviewStory: () => _previewStory(trip),
          onViewDetail: () async {
            await Navigator.pushNamed(
              context,
              '/trip/detail',
              arguments: trip.id,
            );
            if (mounted) _loadTrips();
          },
        );
      },
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.trip,
    required this.formatDistance,
    required this.formatDuration,
    required this.onPlayVideo,
    required this.onEditStory,
    required this.onPreviewStory,
    required this.onViewDetail,
  });

  final Trip trip;
  final String Function(double) formatDistance;
  final String Function(DateTime, DateTime?) formatDuration;
  final VoidCallback onPlayVideo;
  final VoidCallback onEditStory;
  final VoidCallback onPreviewStory;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final titleText = trip.title?.isNotEmpty == true
        ? trip.title!
        : 'Jelajah ${DateFormat('dd MMMM yyyy').format(trip.startedAt)}';

    final distanceStr = trip.distanceMeters != null ? formatDistance(trip.distanceMeters!) : '0 m';
    final durationStr = formatDuration(trip.startedAt, trip.endedAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                    SizedBox(width: 6),
                    Text(
                      'STORY STUDIO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.inkSoft),
                onSelected: (val) {
                  if (val == 'preview') onPreviewStory();
                  if (val == 'detail') onViewDetail();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Pratinjau Story'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18),
                        SizedBox(width: 10),
                        Text('Detail Perjalanan'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Perjalanan sejauh $distanceStr ($durationStr) siap dibuatkan video animasi interaktif dan dikustomisasi dengan aneka template.',
            style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.35),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Main Action: Play Story Video
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  onPressed: onPlayVideo,
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                  label: const Text('Putar Video Story'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Secondary Action: Edit with diverse templates
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: onEditStory,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Edit Story'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

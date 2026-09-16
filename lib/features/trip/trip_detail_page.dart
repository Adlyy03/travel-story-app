import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/trip/data/trip_local_data_source.dart';
import '../../features/trip/data/trip_repository.dart';
import '../../shared/models/trip.dart';
import '../../shared/models/location_point.dart';
import '../../features/story/domain/story_builder.dart';
import '../../core/theme/app_colors.dart';

class TripDetailPage extends StatefulWidget {
  const TripDetailPage({super.key});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late final TripRepository _repository;
  Trip? _trip;
  List<LocationPoint> _points = [];
  bool _isLoading = true;
  String? _error;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _repository = TripRepository(TripLocalDataSource());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tripId = ModalRoute.of(context)?.settings.arguments as String?;
    if (tripId != null) {
      _loadTrip(tripId);
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Perjalanan tidak ditemukan';
      });
    }
  }

  Future<void> _loadTrip(String tripId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final trip = await _repository.getTripById(tripId);
      if (trip != null) {
        final points = await _repository.getLocationPoints(tripId);
        final stops = await _repository.getStops(tripId);

        setState(() {
          _trip = trip.copyWith(locationPoints: points, stops: stops);
          _points = points;
        });
      } else {
        _error = 'Perjalanan tidak ditemukan';
      }
    } catch (e) {
      _error = 'Gagal memuat perjalanan: $e';
    }

    setState(() {
      _isLoading = false;
    });
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

  String _formatDurationFromSeconds(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  void _createStory() {
    if (_trip == null) return;
    final builder = StoryBuilder();
    final story = builder.build(_trip!);
    Navigator.pushNamed(context, '/story/preview', arguments: story);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus trip?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        content: const Text('Trip ini akan dihapus dan tidak bisa dikembalikan', style: TextStyle(color: AppColors.inkSoft)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTrip();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.surface,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip() async {
    if (_trip == null) return;
    
    try {
      await _repository.deleteTrip(_trip!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip berhasil dihapus')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus trip'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context, _hasChanges)),
        title: const Text('Detail Perjalanan'),
        actions: [
          if (_trip != null) ...[
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined, size: 22),
              tooltip: 'Buat story',
              onPressed: _createStory,
            ),
            if (_points.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.map_outlined, size: 22),
                tooltip: 'Lihat peta',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/trip/map',
                  arguments: _trip!.id,
                ),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 22),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.pushNamed(context, '/trip/form', arguments: _trip).then((result) {
                    if (result == true) {
                      _hasChanges = true;
                      _loadTrip(_trip!.id);
                    }
                  });
                } else if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20, color: AppColors.ink),
                      SizedBox(width: 12),
                      Text('Edit trip'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                      SizedBox(width: 12),
                      Text('Hapus trip', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, _hasChanges),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                )
              : _trip == null
                  ? const Center(child: Text('Perjalanan tidak ditemukan'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildStats(),
                          const SizedBox(height: 16),
                          _buildActions(),
                          if (_trip!.stops.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildStops(),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader() {
    final titleText = _trip!.title?.isNotEmpty == true
        ? _trip!.title!
        : 'Trip ${DateFormat('dd MMMM yyyy').format(_trip!.startedAt)}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.route, size: 28, color: AppColors.accent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('dd MMM yyyy, HH:mm').format(_trip!.startedAt)} - ${_trip!.endedAt != null ? DateFormat('HH:mm').format(_trip!.endedAt!) : 'berlangsung'}',
                style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatItem(Icons.straighten, 'Jarak', _trip!.distanceMeters != null ? _formatDistance(_trip!.distanceMeters!) : '-')),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(child: _buildStatItem(Icons.schedule, 'Durasi', _trip!.durationSeconds != null ? _formatDurationFromSeconds(_trip!.durationSeconds!) : _formatDuration(_trip!.startedAt, _trip!.endedAt))),
            ],
          ),
          if (_trip!.stops.isNotEmpty || (_trip!.elevationGainMeters != null && _trip!.elevationGainMeters! > 0)) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_trip!.stops.isNotEmpty)
                  Expanded(child: _buildStatItem(Icons.pause_circle_outline, 'Berhenti', '${_trip!.stops.length}x')),
                if (_trip!.stops.isNotEmpty && _trip!.elevationGainMeters != null && _trip!.elevationGainMeters! > 0)
                  Container(width: 1, height: 40, color: AppColors.border),
                if (_trip!.elevationGainMeters != null && _trip!.elevationGainMeters! > 0)
                  Expanded(child: _buildStatItem(Icons.terrain, 'Elevasi', '+${_trip!.elevationGainMeters!.toStringAsFixed(0)}m')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.inkSoft),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (_points.isNotEmpty)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/trip/map', arguments: _trip!.id),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Lihat peta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        if (_points.isNotEmpty) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _createStory,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Buat story'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildStops() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pemberhentian',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        ...List.generate(_trip!.stops.length, (index) {
          final stop = _trip!.stops[index];
          final duration = Duration(seconds: stop.durationSeconds);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.pause_circle_outline, size: 20, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.placeName ?? 'Berhenti #${index + 1}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('HH:mm').format(stop.arrivalTime)} • ${duration.inMinutes} menit',
                        style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

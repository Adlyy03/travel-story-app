import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../trip/data/trip_local_data_source.dart';
import '../trip/data/trip_repository.dart';
import '../../shared/models/trip.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/sync_status_badge.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> with AutomaticKeepAliveClientMixin {
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
      setState(() => _error = 'Gagal memuat perjalanan');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteSingleTrip(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perjalanan?'),
        content:
            const Text('Apakah Anda yakin ingin menghapus perjalanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteTrip(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perjalanan berhasil dihapus')),
        );
        _loadTrips();
      }
    }
  }

  Future<void> _deleteAllTrips() async {
    if (_trips.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Perjalanan?'),
        content: Text(
            'Apakah Anda yakin ingin menghapus seluruh ${_trips.length} perjalanan? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteAllTrips();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua perjalanan berhasil dihapus')),
        );
        _loadTrips();
      }
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
        title: const Text('Riwayat Perjalanan'),
        actions: [
          const Center(child: SyncStatusBadge()),
          const SizedBox(width: 4),
          if (_trips.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined,
                  size: 22, color: AppColors.danger),
              tooltip: 'Hapus Semua Trip',
              onPressed: _deleteAllTrips,
            ),
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            tooltip: 'Buat trip baru',
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/trip/form');
              if (result == true && mounted) _loadTrips();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadTrips,
                  child: _trips.isEmpty ? _buildEmpty() : _buildList(),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loadTrips, child: const Text('Coba lagi')),
          ],
        ),
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
                  const Icon(Icons.route_outlined,
                      size: 48, color: AppColors.inkSoft),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada perjalanan',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Semua perjalananmu akan muncul di sini',
                    style: TextStyle(color: AppColors.inkSoft),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/trip/form');
                      if (result == true && mounted) _loadTrips();
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Buat trip'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final trip = _trips[i];
        return _TripCard(
          trip: trip,
          formatDistance: _formatDistance,
          formatDuration: _formatDuration,
          onTap: () async {
            await Navigator.pushNamed(
              context,
              '/trip/detail',
              arguments: trip.id,
            );
            if (mounted) _loadTrips();
          },
          onMapTap: () => Navigator.pushNamed(
            context,
            '/trip/map',
            arguments: trip.id,
          ),
          onDeleteTap: () => _deleteSingleTrip(trip.id),
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.formatDistance,
    required this.formatDuration,
    required this.onTap,
    required this.onMapTap,
    required this.onDeleteTap,
  });

  final Trip trip;
  final String Function(double) formatDistance;
  final String Function(DateTime, DateTime?) formatDuration;
  final VoidCallback onTap;
  final VoidCallback onMapTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final titleText = trip.title?.isNotEmpty == true
        ? trip.title!
        : 'Trip ${DateFormat('dd MMM yyyy').format(trip.startedAt)}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.route_outlined,
                          color: AppColors.accent, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (trip.distanceMeters != null) ...[
                                Text(
                                  formatDistance(trip.distanceMeters!),
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.inkSoft),
                                ),
                                const Text(' · ',
                                    style: TextStyle(
                                        fontSize: 13, color: AppColors.inkSoft)),
                              ],
                              Text(
                                formatDuration(trip.startedAt, trip.endedAt),
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.inkSoft),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Map shortcut button
          IconButton(
            icon: const Icon(Icons.map_outlined,
                size: 20, color: AppColors.inkSoft),
            tooltip: 'Lihat rute',
            onPressed: onMapTap,
          ),
          // Single delete button
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: AppColors.danger),
            tooltip: 'Hapus trip',
            onPressed: onDeleteTap,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

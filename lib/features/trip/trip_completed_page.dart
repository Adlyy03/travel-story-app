import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../story/domain/story_builder.dart';
import '../trip/data/trip_repository.dart';
import '../trip/data/trip_local_data_source.dart';
import '../../shared/models/trip.dart';
import '../../shared/models/location_point.dart';
import '../../core/theme/app_colors.dart';

/// Shown immediately after Finish Trip. Displays trip summary + Generate Story CTA.
class TripCompletedPage extends StatefulWidget {
  const TripCompletedPage({super.key});

  @override
  State<TripCompletedPage> createState() => _TripCompletedPageState();
}

class _TripCompletedPageState extends State<TripCompletedPage>
    with SingleTickerProviderStateMixin {
  Trip? _trip;
  List<LocationPoint> _points = [];
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late TripRepository _repository;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = TripRepository(TripLocalDataSource());
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_trip == null && _loading) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Trip) {
        _loadTripData(args);
      } else if (args is String) {
        _fetchAndLoad(args);
      } else {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadTripData(Trip trip) async {
    final points = await _repository.getLocationPoints(trip.id);
    final stops = await _repository.getStops(trip.id);
    final fullTrip = trip.copyWith(locationPoints: points, stops: stops);
    setState(() {
      _trip = fullTrip;
      _points = points;
      _loading = false;
    });
    _animCtrl.forward();
  }

  Future<void> _fetchAndLoad(String tripId) async {
    final trip = await _repository.getTripById(tripId);
    if (trip != null) {
      await _loadTripData(trip);
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _formatDistance(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(2)} km' : '${m.toStringAsFixed(0)} m';

  String _formatDuration(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    return h > 0 ? '${h}j ${m}m' : '${m}m';
  }

  String _formatSpeed(double kmh) => '${kmh.toStringAsFixed(1)} km/h';

  Future<void> _goToStoryEditor() async {
    if (_trip == null) return;
    final photos = await _repository.getTripPhotos(_trip!.id);
    final story = StoryBuilder().build(_trip!, photos: photos);
    if (!mounted) return;
    Navigator.pushNamed(context, '/story/editor', arguments: story);
  }

  void _goToDetail() {
    if (_trip == null) return;
    Navigator.pushReplacementNamed(context, '/trip/detail', arguments: _trip!.id);
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _trip == null
              ? _buildError()
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 16),
          const Text('Data perjalanan tidak ditemukan',
              style: TextStyle(color: AppColors.ink)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _goHome, child: const Text('Ke Beranda')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final trip = _trip!;
    final dist = trip.distanceMeters ?? 0.0;
    final dur = trip.durationSeconds ?? 0;
    double? avgSpeed;
    if (dist > 0 && dur > 0) {
      avgSpeed = (dist / 1000) / (dur / 3600);
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 0,
          floating: false,
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.ink,
          automaticallyImplyLeading: false,
          toolbarHeight: 56,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _goHome,
              ),
              const SizedBox(width: 4),
              const Text('Perjalanan Selesai!',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Celebration banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      AppColors.accent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 56, color: AppColors.accent),
                    const SizedBox(height: 12),
                    Text(
                      trip.title?.isNotEmpty == true
                          ? trip.title!
                          : 'Perjalanan ${DateFormat('d MMM yyyy').format(trip.startedAt)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Perjalananmu berhasil direkam!',
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mini Route Map Preview
              if (_points.length >= 2) ...[
                _RouteMapPreview(points: _points),
                const SizedBox(height: 20),
              ],

              // Stats Grid
              _buildStatsGrid(dist, dur, avgSpeed, trip.stops.length),
              const SizedBox(height: 28),

              // Generate Story CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _goToStoryEditor,
                  icon: const Icon(Icons.auto_awesome, size: 22),
                  label: const Text(
                    'Generate Story',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToDetail,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Lihat Detail',
                          style: TextStyle(color: AppColors.ink)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goHome,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Ke Beranda',
                          style: TextStyle(color: AppColors.ink)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
      double dist, int dur, double? avgSpeed, int stopsCount) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
            label: 'Jarak',
            value: dist > 0 ? _formatDistance(dist) : '–',
            icon: Icons.straighten),
        _StatCard(
            label: 'Durasi',
            value: dur > 0 ? _formatDuration(dur) : '–',
            icon: Icons.timer_outlined),
        _StatCard(
            label: 'Rata-rata Kecepatan',
            value: avgSpeed != null ? _formatSpeed(avgSpeed) : '–',
            icon: Icons.speed),
        _StatCard(
            label: 'Pemberhentian',
            value: '$stopsCount lokasi',
            icon: Icons.place_outlined),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// Draws a simplified route polyline preview using CustomPaint.
class _RouteMapPreview extends StatelessWidget {
  const _RouteMapPreview({required this.points});
  final List<LocationPoint> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Grid lines background
            CustomPaint(
              painter: _GridPainter(),
              child: const SizedBox.expand(),
            ),
            // Route polyline
            CustomPaint(
              painter: _RoutePainter(points: points),
              child: const SizedBox.expand(),
            ),
            // Label
            Positioned(
              top: 10,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Rute Perjalanan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.points});
  final List<LocationPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    if (latRange == 0 && lngRange == 0) return;

    const pad = 20.0;
    final drawW = size.width - pad * 2;
    final drawH = size.height - pad * 2;

    Offset project(LocationPoint p) {
      final nx = lngRange == 0 ? 0.5 : (p.longitude - minLng) / lngRange;
      final ny = latRange == 0 ? 0.5 : (p.latitude - minLat) / latRange;
      return Offset(pad + nx * drawW, pad + (1 - ny) * drawH);
    }

    final path = Path();
    path.moveTo(project(points.first).dx, project(points.first).dy);
    for (final p in points.skip(1)) {
      path.lineTo(project(p).dx, project(p).dy);
    }

    // Shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Main line
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Start dot
    final start = project(points.first);
    canvas.drawCircle(start, 7,
        Paint()..color = const Color(0xFF10B981)); // green
    canvas.drawCircle(start, 3, Paint()..color = Colors.white);

    // End dot
    final end = project(points.last);
    canvas.drawCircle(end, 7, Paint()..color = AppColors.accent);
    canvas.drawCircle(end, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.points != points;
}

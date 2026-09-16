import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../shared/models/trip.dart';
import '../../shared/models/location_point.dart';
import '../../shared/models/stop.dart';
import '../trip/data/trip_local_data_source.dart';
import '../trip/data/trip_repository.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/location_service.dart';
import '../../core/services/tracking_service.dart';
import '../../core/services/route_smoother.dart';
import '../../core/theme/app_colors.dart';

class TripMapPage extends StatefulWidget {
  const TripMapPage({super.key});

  @override
  State<TripMapPage> createState() => _TripMapPageState();
}

class _TripMapPageState extends State<TripMapPage>
    with SingleTickerProviderStateMixin {
  late final TripRepository _repository;
  final MapController _mapController = MapController();

  Trip? _trip;
  List<LocationPoint> _points = [];
  List<Stop> _stops = [];
  List<LatLng> _smoothedPoints = [];
  List<RouteArrow> _turnArrows = [];
  bool _isLoading = true;
  String? _tripId;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _repository = TripRepository(TripLocalDataSource());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    TrackingService.instance.activeTripNotifier.addListener(_onActiveTripUpdated);
    TrackingService.instance.locationNotifier.addListener(_onLocationUpdated);
  }

  @override
  void dispose() {
    TrackingService.instance.activeTripNotifier.removeListener(_onActiveTripUpdated);
    TrackingService.instance.locationNotifier.removeListener(_onLocationUpdated);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tripId = ModalRoute.of(context)?.settings.arguments as String?;
    if (tripId != null && tripId != _tripId) {
      _tripId = tripId;
      _loadTrip(tripId);
    } else if (_tripId == null) {
      final active = TrackingService.instance.activeTrip;
      if (active != null) {
        _tripId = active.id;
        _loadTrip(active.id);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onActiveTripUpdated() {
    // Only do full reload when needed (status change, stop added, etc.)
    // Location-only updates handled by _onLocationUpdated
    if (_tripId != null) {
      _loadTrip(_tripId!);
    }
  }

  void _onLocationUpdated() {
    final newPoint = TrackingService.instance.locationNotifier.value;
    if (newPoint == null || !mounted) return;
    final isLive = _trip?.status == TripStatus.active ||
        TrackingService.instance.activeTrip?.id == _tripId;
    if (!isLive) return;

    final latLng = LatLng(newPoint.latitude, newPoint.longitude);

    setState(() {
      // Add point to smoothed list for live polyline update
      if (_smoothedPoints.isEmpty || _smoothedPoints.last != latLng) {
        _smoothedPoints = [..._smoothedPoints, latLng];
      }
    });

    // Pan map to new location
    try {
      _mapController.move(latLng, _mapController.camera.zoom);
    } catch (_) {}
  }

  Future<void> _loadTrip(String tripId) async {
    final trip = await _repository.getTripById(tripId);
    var points = await _repository.getLocationPoints(tripId);
    final stops = await _repository.getStops(tripId);

    final active = TrackingService.instance.activeTrip;
    final isActiveTrip = trip?.status == TripStatus.active || active?.id == tripId;

    if (points.isEmpty && isActiveTrip) {
      var livePoint = TrackingService.instance.lastCapturedPoint;
      if (livePoint == null) {
        final pos = await LocationService().getCurrentPosition();
        if (pos != null) {
          livePoint = LocationPoint(
            id: const Uuid().v4(),
            tripId: tripId,
            latitude: pos.latitude,
            longitude: pos.longitude,
            timestamp: DateTime.now(),
            accuracy: pos.accuracy,
            altitude: pos.altitude,
          );
          await _repository.addLocationPoint(livePoint);
        }
      }
      if (livePoint != null) {
        points = [livePoint];
      }
    }

    final rawLatLngs = RouteSmoother.toLatLngList(points);
    final smoothed = await RouteSmoother.processRoute(rawLatLngs);
    final arrows = RouteSmoother.extractTurnArrows(smoothed);

    if (mounted) {
      setState(() {
        _trip = trip ?? (isActiveTrip ? active : null);
        _points = points;
        _stops = stops;
        _smoothedPoints = smoothed;
        _turnArrows = arrows;
        _isLoading = false;
      });

      if (isActiveTrip && _smoothedPoints.isNotEmpty) {
        try {
          _mapController.move(_smoothedPoints.last, _mapController.camera.zoom);
        } catch (_) {}
      }
    }
  }

  LatLng? _center() {
    final pts = _smoothedPoints.isNotEmpty
        ? _smoothedPoints
        : _points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    if (pts.isEmpty) return null;

    final isLive = _trip?.status == TripStatus.active;
    if (isLive) {
      return pts.last;
    }

    double minLat = pts.first.latitude;
    double maxLat = pts.first.latitude;
    double minLng = pts.first.longitude;
    double maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final isLive = _trip?.status == TripStatus.active ||
        TrackingService.instance.activeTrip?.id == _tripId;

    final center = _center() ??
        (TrackingService.instance.lastCapturedPoint != null
            ? LatLng(
                TrackingService.instance.lastCapturedPoint!.latitude,
                TrackingService.instance.lastCapturedPoint!.longitude,
              )
            : const LatLng(-6.2088, 106.8456));

    // Markers Construction
    final startMarker = _points.isNotEmpty
        ? Marker(
            point: LatLng(_points.first.latitude, _points.first.longitude),
            width: 32,
            height: 32,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 18),
            ),
          )
        : null;

    final endMarker = (_points.isNotEmpty && !isLive)
        ? Marker(
            point: LatLng(_points.last.latitude, _points.last.longitude),
            width: 32,
            height: 32,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.flag_rounded,
                  color: Colors.white, size: 18),
            ),
          )
        : null;

    // Current Location Live Pulse Marker
    final liveCurrentMarker = (isLive && _smoothedPoints.isNotEmpty)
        ? Marker(
            point: _smoothedPoints.last,
            width: 48,
            height: 48,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 24 * _pulseAnimation.value,
                      height: 24 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        : null;

    final stopMarkers = _stops
        .map((s) => Marker(
              point: LatLng(s.latitude, s.longitude),
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.pause_rounded,
                    color: Colors.white, size: 14),
              ),
            ))
        .toList();

    final arrowMarkers = _turnArrows
        .map((arrow) => Marker(
              point: arrow.position,
              width: 20,
              height: 20,
              child: Transform.rotate(
                angle: (arrow.heading * math.pi / 180),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isLive ? 'Rute Live Perjalanan' : 'Peta Perjalanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTripInfo(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.travelstory.app',
              ),
              // Outer Casing Polyline (Dark Shadow)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _smoothedPoints,
                    strokeWidth: 10,
                    color: const Color(0xFF000000), // Solid black casing
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),
              // Inner Smooth Vibrant Polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _smoothedPoints,
                    strokeWidth: 6,
                    color: isLive ? const Color(0xFF00F5D4) : AppColors.accent,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  ?startMarker,
                  ...stopMarkers,
                  ...arrowMarkers,
                  ?endMarker,
                  ?liveCurrentMarker,
                ],
              ),
            ],
          ),
          // Floating Rec Badge / Status Pill
          if (isLive)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x3300F5D4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00F5D4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'REC LIVE TRACKING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00F5D4),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_points.isEmpty)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isLive
                            ? 'Merekam perjalanan... Menunggu pergerakan atau sinyal GPS'
                            : 'Belum ada data titik rute untuk perjalanan ini.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        tooltip: 'Pusatkan Peta',
        onPressed: () {
          final target = _smoothedPoints.isNotEmpty
              ? _smoothedPoints.last
              : center;
          _mapController.move(target, 16.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _showTripInfo(BuildContext context) {
    if (_trip == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _trip!.title?.isNotEmpty == true ? _trip!.title! : 'Info Perjalanan',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_trip!.distanceMeters != null)
              _infoRow('Jarak', _formatDistance(_trip!.distanceMeters!)),
            if (_trip!.durationSeconds != null)
              _infoRow('Durasi', _formatDuration(_trip!.durationSeconds!)),
            _infoRow('Titik GPS Mentah', '${_points.length}'),
            _infoRow('Titik Rute Halus', '${_smoothedPoints.length}'),
            _infoRow('Pemberhentian', '${_stops.length}'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.inkSoft)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
          ],
        ),
      );

  String _formatDistance(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(2)} km' : '${m.toStringAsFixed(0)} m';

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

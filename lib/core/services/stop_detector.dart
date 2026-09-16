import 'dart:math';
import '../../shared/models/location_point.dart';
import '../../shared/models/stop.dart';
import 'package:uuid/uuid.dart';

class StopDetector {
  static const Duration _minStopDuration = Duration(minutes: 5);
  static const double _movementRadiusMeters = 50.0;

  List<Stop> detectStops(List<LocationPoint> points) {
    if (points.length < 3) return [];

    final stops = <Stop>[];
    int? clusterStart;
    
    for (int i = 0; i < points.length; i++) {
      if (clusterStart == null) {
        clusterStart = i;
        continue;
      }

      final isWithinRadius = _isWithinRadius(
        points[clusterStart],
        points[i],
        _movementRadiusMeters,
      );

      if (!isWithinRadius) {
        final duration = points[i - 1].timestamp.difference(points[clusterStart].timestamp);
        
        if (duration >= _minStopDuration) {
          stops.add(_createStop(points, clusterStart, i - 1));
        }
        
        clusterStart = i;
      }
    }

    if (clusterStart != null && clusterStart < points.length - 1) {
      final duration = points.last.timestamp.difference(points[clusterStart].timestamp);
      if (duration >= _minStopDuration) {
        stops.add(_createStop(points, clusterStart, points.length - 1));
      }
    }

    return stops;
  }

  bool _isWithinRadius(LocationPoint p1, LocationPoint p2, double radiusMeters) {
    final distance = _calculateDistance(p1.latitude, p1.longitude, p2.latitude, p2.longitude);
    return distance <= radiusMeters;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
              sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  Stop _createStop(List<LocationPoint> points, int start, int end) {
    final centerLat = (points[start].latitude + points[end].latitude) / 2;
    final centerLon = (points[start].longitude + points[end].longitude) / 2;
    
    return Stop(
      id: const Uuid().v4(),
      arrivalTime: points[start].timestamp,
      departureTime: points[end].timestamp,
      latitude: centerLat,
      longitude: centerLon,
      durationSeconds: points[end].timestamp.difference(points[start].timestamp).inSeconds,
    );
  }
}

import 'dart:math';
import '../../shared/models/location_point.dart';

class TripCalculator {
  double calculateDistance(List<LocationPoint> points) {
    if (points.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _haversineDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  int calculateDuration(List<LocationPoint> points) {
    if (points.isEmpty) return 0;
    if (points.length == 1) return 0;

    final first = points.first.timestamp;
    final last = points.last.timestamp;
    
    return last.difference(first).inSeconds;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
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
}

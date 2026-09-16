import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../shared/models/location_point.dart';

class GpsCleaner {
  static const double maxAccuracyMeters = 100.0;
  static const double maxSpeedMps = 200.0; // ~720 km/h max realistic movement
  static const double minMovementThresholdMeters = 6.0; // Minimum movement to overcome drift

  List<LocationPoint> clean(List<LocationPoint> points) {
    if (points.isEmpty) return [];

    debugPrint('[GpsCleaner] Cleaning ${points.length} raw points...');
    final cleaned = <LocationPoint>[];
    int rejected = 0;

    for (final point in points) {
      if (!isPointValid(point)) {
        rejected++;
        continue;
      }

      if (cleaned.isNotEmpty) {
        if (_isDuplicate(cleaned.last, point)) {
          rejected++;
          continue;
        }
        if (_isImpossibleMovement(cleaned.last, point)) {
          rejected++;
          continue;
        }
      }

      cleaned.add(point);
    }

    debugPrint('[GpsCleaner] Result: ${cleaned.length} clean points, $rejected rejected');
    return cleaned;
  }

  bool _isImpossibleMovement(LocationPoint p1, LocationPoint p2) {
    final distance = calculateDistance(p1.latitude, p1.longitude, p2.latitude, p2.longitude);
    final timeDiff = p2.timestamp.difference(p1.timestamp).inSeconds;

    if (timeDiff > 0) {
      final speed = distance / timeDiff;
      if (speed > maxSpeedMps) {
        return true; // Speed spike / teleportation jump
      }
    }
    return false;
  }


  bool isPointValid(LocationPoint point) {
    if (!_isValidCoordinate(point)) return false;
    if (!_isValidAccuracy(point)) return false;
    if (!_isValidTimestamp(point)) return false;
    return true;
  }

  bool isSignificantMovement(LocationPoint p1, LocationPoint p2) {
    final distance = calculateDistance(p1.latitude, p1.longitude, p2.latitude, p2.longitude);
    final timeDiff = p2.timestamp.difference(p1.timestamp).inSeconds;

    if (timeDiff <= 0 && distance < 1.0) return false;

    final acc1 = p1.accuracy ?? 10.0;
    final acc2 = p2.accuracy ?? 10.0;
    final dynamicThreshold = max(minMovementThresholdMeters, (acc1 + acc2) / 3.0);

    if (distance < dynamicThreshold) {
      return false; // Stationary GPS drift
    }

    if (timeDiff > 0) {
      final speed = distance / timeDiff;
      if (speed > maxSpeedMps) {
        return false; // Speed spike / teleportation jump
      }
    }

    return true;
  }

  bool _isValidCoordinate(LocationPoint point) {
    // Reject (0,0) explicitly — likely GPS not ready
    if (point.latitude.abs() < 0.0001 && point.longitude.abs() < 0.0001) {
      return false;
    }
    
    return point.latitude >= -90 && 
           point.latitude <= 90 &&
           point.longitude >= -180 && 
           point.longitude <= 180;
  }

  bool _isValidAccuracy(LocationPoint point) {
    if (point.accuracy == null) return true;
    return point.accuracy! <= maxAccuracyMeters;
  }

  bool _isValidTimestamp(LocationPoint point) {
    return !point.timestamp.isAfter(DateTime.now());
  }

  bool _isDuplicate(LocationPoint p1, LocationPoint p2) {
    const epsilon = 0.00001;
    return (p1.latitude - p2.latitude).abs() < epsilon && 
           (p1.longitude - p2.longitude).abs() < epsilon &&
           (p1.timestamp.millisecondsSinceEpoch - p2.timestamp.millisecondsSinceEpoch).abs() < 1000;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

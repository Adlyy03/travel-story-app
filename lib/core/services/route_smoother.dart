import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../shared/models/location_point.dart';

class RouteArrow {
  final LatLng position;
  final double heading; // 0..360 degrees

  const RouteArrow(this.position, this.heading);
}

class RouteSmoother {
  /// Converts LocationPoints to LatLng list
  static List<LatLng> toLatLngList(List<LocationPoint> points) {
    return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }

  /// Calculates Haversine distance in meters between two LatLng points
  static double calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final dLat = (p2.latitude - p1.latitude) * math.pi / 180;
    final dLon = (p2.longitude - p1.longitude) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * math.pi / 180) *
            math.cos(p2.latitude * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Calculates bearing/heading in degrees (0..360) from p1 to p2
  static double calculateBearing(LatLng p1, LatLng p2) {
    final lat1 = p1.latitudeInRad;
    final lon1 = p1.longitudeInRad;
    final lat2 = p2.latitudeInRad;
    final lon2 = p2.longitudeInRad;

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  /// Ramer-Douglas-Peucker (RDP) Simplification algorithm
  /// Reduces unnecessary collinear points while retaining turn features
  static List<LatLng> simplify(List<LatLng> points, {double epsilon = 0.000025}) {
    if (points.length <= 2) return points;

    double maxDist = 0.0;
    int index = 0;
    final end = points.length - 1;

    for (int i = 1; i < end; i++) {
      final dist = _perpendicularDistance(points[i], points[0], points[end]);
      if (dist > maxDist) {
        index = i;
        maxDist = dist;
      }
    }

    if (maxDist > epsilon) {
      final firstPart = simplify(points.sublist(0, index + 1), epsilon: epsilon);
      final secondPart = simplify(points.sublist(index, points.length), epsilon: epsilon);
      return [...firstPart.sublist(0, firstPart.length - 1), ...secondPart];
    } else {
      return [points[0], points[end]];
    }
  }

  static double _perpendicularDistance(LatLng p, LatLng lineStart, LatLng lineEnd) {
    final x = p.longitude;
    final y = p.latitude;
    final x1 = lineStart.longitude;
    final y1 = lineStart.latitude;
    final x2 = lineEnd.longitude;
    final y2 = lineEnd.latitude;

    final dx = x2 - x1;
    final dy = y2 - y1;

    if (dx == 0 && dy == 0) {
      return math.sqrt((x - x1) * (x - x1) + (y - y1) * (y - y1));
    }

    final numerator = ((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1).abs();
    final denominator = math.sqrt(dy * dy + dx * dx);
    return numerator / denominator;
  }

  /// Chaikin's Corner Cutting algorithm for smooth road curves
  static List<LatLng> smoothChaikin(List<LatLng> points, {int iterations = 2}) {
    if (points.length <= 2) return points;

    List<LatLng> current = List.from(points);
    for (int iter = 0; iter < iterations; iter++) {
      final smoothed = <LatLng>[];
      smoothed.add(current.first);

      for (int i = 0; i < current.length - 1; i++) {
        final p0 = current[i];
        final p1 = current[i + 1];

        final q = LatLng(
          0.75 * p0.latitude + 0.25 * p1.latitude,
          0.75 * p0.longitude + 0.25 * p1.longitude,
        );

        final r = LatLng(
          0.25 * p0.latitude + 0.75 * p1.latitude,
          0.25 * p0.longitude + 0.75 * p1.longitude,
        );

        smoothed.add(q);
        smoothed.add(r);
      }

      smoothed.add(current.last);
      current = smoothed;
    }

    return current;
  }

  static final Map<String, List<LatLng>> _matchCache = {};

  /// Master pipeline: Simplifies GPS noise then applies Map Matching for road snapping
  static Future<List<LatLng>> processRoute(List<LatLng> points, {double epsilon = 0.000025, int iterations = 3}) async {
    if (points.length <= 2) return points;
    
    // 1. GPS Noise & Jitter Filtering
    final filtered = _filterGpsNoise(points);
    
    // 2. Moving Average (Smooth out tiny micro-jitter)
    final averaged = _movingAverage(filtered, windowSize: 3);

    // 3. Map Matching / Road Snapping with OSRM (Match -> Route -> Offline Fallback)
    final matched = await _mapMatchWithFallback(averaged);
    
    return matched;
  }

  static Future<List<LatLng>> _mapMatchWithFallback(List<LatLng> points) async {
    try {
      const int chunkSize = 70;
      final matchedPoints = <LatLng>[];
      
      for (int i = 0; i < points.length; i += chunkSize) {
        int end = (i + chunkSize < points.length) ? i + chunkSize : points.length;
        int start = i > 0 ? i - 1 : i;
        
        final chunk = points.sublist(start, end);
        if (chunk.length < 2) continue;
        
        final cacheKey = "${chunk.first.latitude.toStringAsFixed(5)},${chunk.first.longitude.toStringAsFixed(5)}_${chunk.last.latitude.toStringAsFixed(5)},${chunk.last.longitude.toStringAsFixed(5)}_${chunk.length}";
        
        List<LatLng>? chunkMatched;
        
        if (_matchCache.containsKey(cacheKey)) {
          chunkMatched = _matchCache[cacheKey];
        } else {
          // Primary: OSRM Map Matching
          chunkMatched = await _fetchMapMatching(chunk);
          
          // Secondary Fallback: OSRM Routing on waypoints
          chunkMatched ??= await _fetchRouteForWaypoints(chunk);
          
          if (chunkMatched != null && chunk.length == chunkSize) {
            _matchCache[cacheKey] = chunkMatched;
          }
        }
        
        if (chunkMatched != null && chunkMatched.isNotEmpty) {
          if (matchedPoints.isNotEmpty && chunkMatched.first == matchedPoints.last) {
            matchedPoints.addAll(chunkMatched.skip(1));
          } else {
            matchedPoints.addAll(chunkMatched);
          }
        } else {
          // Offline Fallback: Simplify without aggressive Chaikin corner cutting
          final simplified = simplify(chunk, epsilon: 0.000015);
          matchedPoints.addAll(simplified);
        }
      }
      return matchedPoints.isNotEmpty ? matchedPoints : points;
    } catch (e) {
      return simplify(points, epsilon: 0.000015);
    }
  }

  static Future<List<LatLng>?> _fetchMapMatching(List<LatLng> chunk) async {
    try {
      final coords = chunk.map((p) => '${p.longitude},${p.latitude}').join(';');
      final url = 'http://router.project-osrm.org/match/v1/driving/$coords?geometries=geojson&overview=full&radiuses=${List.filled(chunk.length, 30).join(';')}';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['matchings'] != null) {
          final List<LatLng> result = [];
          for (final match in data['matchings']) {
            final geometry = match['geometry'];
            if (geometry != null && geometry['coordinates'] != null) {
              for (final coord in geometry['coordinates']) {
                result.add(LatLng(coord[1] as double, coord[0] as double));
              }
            }
          }
          return result;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<List<LatLng>?> _fetchRouteForWaypoints(List<LatLng> waypoints) async {
    try {
      final simplified = simplify(waypoints, epsilon: 0.00005);
      if (simplified.length < 2) return null;
      
      final coords = simplified.map((p) => '${p.longitude},${p.latitude}').join(';');
      final url = 'http://router.project-osrm.org/route/v1/driving/$coords?geometries=geojson&overview=full';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final List<LatLng> result = [];
          final geometry = data['routes'][0]['geometry'];
          if (geometry != null && geometry['coordinates'] != null) {
            for (final coord in geometry['coordinates']) {
              result.add(LatLng(coord[1] as double, coord[0] as double));
            }
          }
          return result;
        }
      }
    } catch (_) {}
    return null;
  }

  static List<LatLng> _filterGpsNoise(List<LatLng> points) {
    if (points.length <= 2) return points;

    final filtered = <LatLng>[points.first];
    for (int i = 1; i < points.length; i++) {
      final prev = filtered.last;
      final curr = points[i];
      final distMeters = calculateDistance(prev, curr);
      
      // Ignore stationary jitter (< 6m)
      if (distMeters < 6.0) continue;
      
      // Ignore extreme GPS jumps (> 2000m)
      if (distMeters > 2000.0) continue;
      
      filtered.add(curr);
    }
    if (filtered.last != points.last) {
      filtered.add(points.last);
    }
    return filtered;
  }



  static List<LatLng> _movingAverage(List<LatLng> points, {required int windowSize}) {
    if (points.length < windowSize) return points;
    final smoothed = <LatLng>[];
    final halfWindow = windowSize ~/ 2;

    for (int i = 0; i < points.length; i++) {
      int start = math.max(0, i - halfWindow);
      int end = math.min(points.length - 1, i + halfWindow);
      double sumLat = 0.0;
      double sumLng = 0.0;
      int count = 0;

      for (int j = start; j <= end; j++) {
        sumLat += points[j].latitude;
        sumLng += points[j].longitude;
        count++;
      }
      smoothed.add(LatLng(sumLat / count, sumLng / count));
    }
    // Lock start and end points
    if (smoothed.isNotEmpty && points.isNotEmpty) {
      smoothed.first = points.first;
      smoothed.last = points.last;
    }
    return smoothed;
  }

  /// Extracts direction arrows at regular distance intervals along the route
  static List<RouteArrow> extractTurnArrows(
    List<LatLng> points, {
    double minSpacingMeters = 200,
  }) {
    if (points.length < 2) return [];

    final arrows = <RouteArrow>[];
    double accumulatedDistance = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final dist = calculateDistance(p1, p2);
      accumulatedDistance += dist;

      if (accumulatedDistance >= minSpacingMeters) {
        final bearing = calculateBearing(p1, p2);
        final midPoint = LatLng(
          (p1.latitude + p2.latitude) / 2,
          (p1.longitude + p2.longitude) / 2,
        );
        arrows.add(RouteArrow(midPoint, bearing));
        accumulatedDistance = 0.0;
      }
    }

    return arrows;
  }
}

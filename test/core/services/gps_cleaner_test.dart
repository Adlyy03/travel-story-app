import 'package:flutter_test/flutter_test.dart';
import 'package:travel_story/core/services/gps_cleaner.dart';
import 'package:travel_story/shared/models/location_point.dart';

void main() {
  late GpsCleaner cleaner;

  setUp(() {
    cleaner = GpsCleaner();
  });

  group('GpsCleaner', () {
    test('returns empty list for empty input', () {
      final result = cleaner.clean([]);
      expect(result, isEmpty);
    });

    test('filters invalid coordinates', () {
      final base = DateTime(2026, 1, 1, 12, 0);
      final points = [
        _point(-91, 0, base),
        _point(91, 0, base.add(Duration(seconds: 1))),
        _point(0, -181, base.add(Duration(seconds: 2))),
        _point(0, 181, base.add(Duration(seconds: 3))),
        _point(-6.2, 106.8, base.add(Duration(seconds: 4))),
      ];

      final result = cleaner.clean(points);
      expect(result.length, 1);
    });

    test('filters poor accuracy', () {
      final base = DateTime(2026, 1, 1, 12, 0);
      final points = [
        _point(-6.2, 106.8, base, accuracy: 50.0),
        _point(-6.21, 106.81, base.add(Duration(seconds: 10)), accuracy: 150.0),
        _point(-6.22, 106.82, base.add(Duration(seconds: 20)), accuracy: 30.0),
      ];

      final result = cleaner.clean(points);
      expect(result.length, 2);
    });

    test('filters duplicates', () {
      final base = DateTime(2026, 1, 1, 12, 0);
      final points = [
        _point(-6.2, 106.8, base),
        _point(-6.2, 106.8, base),
        _point(-6.21, 106.81, base.add(Duration(seconds: 10))),
      ];

      final result = cleaner.clean(points);
      expect(result.length, 2);
    });

    test('filters impossible jumps', () {
      final base = DateTime(2026, 1, 1, 12, 0);
      final points = [
        _point(-6.2, 106.8, base),
        _point(-6.21, 106.81, base.add(Duration(seconds: 10))),
        _point(0, 0, base.add(Duration(seconds: 11))),
        _point(-6.22, 106.82, base.add(Duration(seconds: 30))),
      ];

      final result = cleaner.clean(points);
      expect(result.length, 3);
    });

    test('accepts normal sequence', () {
      final base = DateTime(2026, 1, 1, 12, 0);
      final points = [
        _point(-6.200, 106.800, base),
        _point(-6.201, 106.801, base.add(Duration(seconds: 10))),
        _point(-6.202, 106.802, base.add(Duration(seconds: 20))),
        _point(-6.203, 106.803, base.add(Duration(seconds: 30))),
      ];

      final result = cleaner.clean(points);
      expect(result.length, 4);
    });

    test('filters future timestamps', () {
      final now = DateTime.now();
      final points = [
        _point(-6.2, 106.8, now.subtract(Duration(minutes: 5))),
        _point(-6.21, 106.81, now.add(Duration(hours: 2))),
        _point(-6.22, 106.82, now.subtract(Duration(minutes: 4))),
      ];

      final result = cleaner.clean(points);
      expect(result.length, 2);
    });
  });
}

int _counter = 0;

LocationPoint _point(double lat, double lon, DateTime time, {double? accuracy}) {
  _counter++;
  return LocationPoint(
    id: 'p$_counter',
    tripId: 'trip',
    latitude: lat,
    longitude: lon,
    timestamp: time,
    accuracy: accuracy,
  );
}

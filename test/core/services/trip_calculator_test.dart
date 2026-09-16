import 'package:flutter_test/flutter_test.dart';
import 'package:travel_story/core/services/trip_calculator.dart';
import 'package:travel_story/shared/models/location_point.dart';

void main() {
  late TripCalculator calculator;

  setUp(() {
    calculator = TripCalculator();
  });

  group('Distance', () {
    test('empty list', () {
      expect(calculator.calculateDistance([]), 0.0);
    });

    test('single point', () {
      final points = [_point(-6.2, 106.8, 0)];
      expect(calculator.calculateDistance(points), 0.0);
    });

    test('Jakarta to Bogor (~50km)', () {
      final points = [
        _point(-6.2088, 106.8456, 0), // Jakarta
        _point(-6.5971, 106.8060, 1), // Bogor
      ];
      
      final distance = calculator.calculateDistance(points);
      expect(distance, greaterThan(40000));
      expect(distance, lessThan(60000));
    });

    test('multiple points', () {
      final points = [
        _point(-6.200, 106.800, 0),
        _point(-6.201, 106.801, 1),
        _point(-6.202, 106.802, 2),
        _point(-6.203, 106.803, 3),
      ];
      
      final distance = calculator.calculateDistance(points);
      expect(distance, greaterThan(0));
    });
  });

  group('Duration', () {
    test('empty list', () {
      expect(calculator.calculateDuration([]), 0);
    });

    test('single point', () {
      final points = [_point(-6.2, 106.8, 0)];
      expect(calculator.calculateDuration(points), 0);
    });

    test('calculates seconds', () {
      final base = DateTime(2026, 1, 1, 10, 0, 0);
      final points = [
        _pointTime(-6.2, 106.8, base),
        _pointTime(-6.3, 106.9, base.add(Duration(minutes: 30))),
      ];
      
      expect(calculator.calculateDuration(points), 1800);
    });

    test('4 hours 12 minutes', () {
      final base = DateTime(2026, 1, 1, 8, 0, 0);
      final points = [
        _pointTime(-6.2, 106.8, base),
        _pointTime(-6.3, 106.9, base.add(Duration(hours: 4, minutes: 12))),
      ];
      
      expect(calculator.calculateDuration(points), 15120);
    });
  });
}

int _counter = 0;

LocationPoint _point(double lat, double lon, int offsetSec) {
  _counter++;
  return LocationPoint(
    id: 'p$_counter',
    tripId: 'trip',
    latitude: lat,
    longitude: lon,
    timestamp: DateTime.now().add(Duration(seconds: offsetSec)),
  );
}

LocationPoint _pointTime(double lat, double lon, DateTime time) {
  _counter++;
  return LocationPoint(
    id: 'p$_counter',
    tripId: 'trip',
    latitude: lat,
    longitude: lon,
    timestamp: time,
  );
}

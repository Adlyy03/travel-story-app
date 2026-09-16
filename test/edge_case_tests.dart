import 'package:flutter_test/flutter_test.dart';
import 'package:travel_story/core/services/trip_engine.dart';
import 'package:travel_story/core/services/gps_cleaner.dart';
import 'package:travel_story/core/services/trip_calculator.dart';
import 'package:travel_story/core/services/elevation_calculator.dart';
import 'package:travel_story/core/services/stop_detector.dart';
import 'package:travel_story/shared/models/location_point.dart';

void main() {
  late TripEngine engine;

  setUp(() {
    engine = TripEngine(
      GpsCleaner(),
      TripCalculator(),
      ElevationCalculator(),
      StopDetector(),
    );
  });

  group('Edge Cases', () {
    test('0 GPS points', () {
      final result = engine.processLocationPoints([]);
      expect(result.distanceMeters, isNull);
      expect(result.stops, isEmpty);
    });

    test('1 GPS point', () {
      final points = [
        LocationPoint(
          id: '1',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: DateTime(2026, 1, 1, 12, 0),
        ),
      ];
      final result = engine.processLocationPoints(points);
      expect(result.distanceMeters, isNull);
      expect(result.stops, isEmpty);
    });

    test('2 GPS points', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = [
        LocationPoint(
          id: '1',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: now,
        ),
        LocationPoint(
          id: '2',
          tripId: 'test',
          latitude: -6.21,
          longitude: 106.81,
          timestamp: now.add(const Duration(seconds: 10)),
        ),
      ];
      final result = engine.processLocationPoints(points);
      expect(result.distanceMeters, isNotNull);
      expect(result.distanceMeters! > 0, isTrue);
    });

    test('GPS noisy - high accuracy values', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = List.generate(
        10,
        (i) => LocationPoint(
          id: '$i',
          tripId: 'test',
          latitude: -6.2 + (i * 0.0001),
          longitude: 106.8 + (i * 0.0001),
          accuracy: 500.0, // very poor
          timestamp: now.add(Duration(seconds: i * 5)),
        ),
      );
      final result = engine.processLocationPoints(points);
      // Should filter poor accuracy
      expect(result.distanceMeters, isNull);
    });

    test('GPS jump - impossible movement', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = [
        LocationPoint(
          id: '1',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: now,
        ),
        LocationPoint(
          id: '2',
          tripId: 'test',
          latitude: -7.5, // jump 144km
          longitude: 108.2,
          timestamp: now.add(const Duration(seconds: 5)),
        ),
      ];
      final result = engine.processLocationPoints(points);
      // Cleaner should reject impossible movement
      expect(result.distanceMeters, isNull);
    });

    test('No elevation data', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = List.generate(
        20,
        (i) => LocationPoint(
          id: '$i',
          tripId: 'test',
          latitude: -6.2 + (i * 0.0001),
          longitude: 106.8 + (i * 0.0001),
          altitude: null,
          timestamp: now.add(Duration(seconds: i * 10)),
        ),
      );
      final result = engine.processLocationPoints(points);
      expect(result.elevationGainMeters, isNull);
      expect(result.elevationLossMeters, isNull);
    });

    test('Very long trip - 100 stops', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = <LocationPoint>[];
      
      for (int i = 0; i < 100; i++) {
        // Move
        for (int j = 0; j < 5; j++) {
          points.add(LocationPoint(
            id: '${i}_$j',
            tripId: 'test',
            latitude: -6.2 + (i * 0.001),
            longitude: 106.8 + (i * 0.001),
            timestamp: now.add(Duration(seconds: i * 3600 + j * 30)),
          ));
        }
        // Stop
        for (int j = 0; j < 20; j++) {
          points.add(LocationPoint(
            id: '${i}_stop_$j',
            tripId: 'test',
            latitude: -6.2 + (i * 0.001),
            longitude: 106.8 + (i * 0.001),
            timestamp: now.add(Duration(seconds: i * 3600 + 200 + j * 30)),
          ));
        }
      }
      
      final result = engine.processLocationPoints(points);
      expect(result.distanceMeters, isNotNull);
      expect(result.stops.isNotEmpty, isTrue);
    });

    test('Very short trip - 10 seconds', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = [
        LocationPoint(
          id: '1',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: now,
        ),
        LocationPoint(
          id: '2',
          tripId: 'test',
          latitude: -6.20001,
          longitude: 106.80001,
          timestamp: now.add(const Duration(seconds: 10)),
        ),
      ];
      final result = engine.processLocationPoints(points);
      expect(result.distanceMeters, isNotNull);
      expect(result.durationSeconds, 10);
    });

    test('1 stop only', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = <LocationPoint>[];
      
      // Stationary for 30 minutes
      for (int i = 0; i < 180; i++) {
        points.add(LocationPoint(
          id: '$i',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: now.add(Duration(seconds: i * 10)),
        ));
      }
      
      final result = engine.processLocationPoints(points);
      expect(result.stops.length, 1);
    });

    test('Duplicate timestamps', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = [
        LocationPoint(
          id: '1',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: now,
        ),
        LocationPoint(
          id: '2',
          tripId: 'test',
          latitude: -6.21,
          longitude: 106.81,
          timestamp: now, // duplicate
        ),
        LocationPoint(
          id: '3',
          tripId: 'test',
          latitude: -6.22,
          longitude: 106.82,
          timestamp: now.add(const Duration(seconds: 10)),
        ),
      ];
      final result = engine.processLocationPoints(points);
      // Cleaner should handle duplicates
      expect(result.distanceMeters, isNotNull);
    });

    test('Invalid coordinates', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = [
        LocationPoint(
          id: '1',
          tripId: 'test',
          latitude: 0.0,
          longitude: 0.0,
          timestamp: now,
        ),
        LocationPoint(
          id: '2',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: now.add(const Duration(seconds: 10)),
        ),
      ];
      final result = engine.processLocationPoints(points);
      // Cleaner should reject 0,0
      expect(result.distanceMeters, isNull);
    });

    test('Altitude noise', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = List.generate(
        20,
        (i) => LocationPoint(
          id: '$i',
          tripId: 'test',
          latitude: -6.2 + (i * 0.0001),
          longitude: 106.8 + (i * 0.0001),
          altitude: 100 + (i.isEven ? 50 : -50), // extreme noise
          timestamp: now.add(Duration(seconds: i * 10)),
        ),
      );
      final result = engine.processLocationPoints(points);
      // Elevation calculator should smooth noise
      if (result.elevationGainMeters != null) {
        expect(result.elevationGainMeters! < 1000, isTrue);
      }
    });

    test('Missing timestamps', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final points = [
        LocationPoint(
          id: '1',
          tripId: 'test',
          latitude: -6.2,
          longitude: 106.8,
          timestamp: now,
        ),
        LocationPoint(
          id: '2',
          tripId: 'test',
          latitude: -6.21,
          longitude: 106.81,
          timestamp: now.add(const Duration(hours: 5)), // huge gap
        ),
      ];
      final result = engine.processLocationPoints(points);
      expect(result.durationSeconds, greaterThan(3600 * 4));
    });
  });
}

import 'package:flutter/foundation.dart';
import '../../shared/models/location_point.dart';
import '../../shared/models/trip.dart';
import 'gps_cleaner.dart';
import 'trip_calculator.dart';
import 'elevation_calculator.dart';
import 'stop_detector.dart';

class TripEngine {
  final GpsCleaner _cleaner;
  final TripCalculator _calculator;
  final ElevationCalculator _elevationCalculator;
  final StopDetector _stopDetector;

  TripEngine(
    this._cleaner,
    this._calculator,
    this._elevationCalculator,
    this._stopDetector,
  );

  Trip processLocationPoints(List<LocationPoint> rawPoints) {
    final rawTrip = Trip(
      id: 'test',
      startedAt: rawPoints.isNotEmpty ? rawPoints.first.timestamp : DateTime.now(),
      endedAt: rawPoints.isNotEmpty ? rawPoints.last.timestamp : DateTime.now(),
      status: TripStatus.completed,
    );
    return processTrip(rawTrip, rawPoints);
  }

  Trip processTrip(Trip rawTrip, List<LocationPoint> rawPoints) {
    debugPrint('[TripEngine] Processing trip with ${rawPoints.length} raw points');
    
    final cleanedPoints = _cleaner.clean(rawPoints);
    
    if (cleanedPoints.isEmpty) {
      debugPrint('[TripEngine] No valid points after cleaning');
      return rawTrip;
    }

    if (cleanedPoints.length < 2) {
      debugPrint('[TripEngine] Less than 2 valid points, cannot calculate metrics');
      return Trip(
        id: rawTrip.id,
        title: rawTrip.title,
        startedAt: rawTrip.startedAt,
        endedAt: rawTrip.endedAt,
        status: rawTrip.status,
        locationPoints: cleanedPoints,
        stops: const [],
        distanceMeters: null,
        durationSeconds: rawTrip.durationSeconds,
        pausedDurationSeconds: rawTrip.pausedDurationSeconds,
        elevationGainMeters: null,
        elevationLossMeters: null,
        highestAltitude: cleanedPoints.first.altitude,
        lowestAltitude: cleanedPoints.first.altitude,
        storyBackgroundImagePath: rawTrip.storyBackgroundImagePath,
        syncStatus: rawTrip.syncStatus,
        lastSyncedAt: rawTrip.lastSyncedAt,
      );
    }

    final distance = _calculator.calculateDistance(cleanedPoints);
    final duration = _calculator.calculateDuration(cleanedPoints);
    final elevation = _elevationCalculator.calculate(cleanedPoints);
    final stops = _stopDetector.detectStops(cleanedPoints);

    debugPrint('[TripEngine] Metrics: distance=${distance.toStringAsFixed(1)}m, duration=${duration}s, elevation=+${elevation.gain?.toStringAsFixed(1) ?? 0}m/-${elevation.loss?.toStringAsFixed(1) ?? 0}m, stops=${stops.length}');

    return Trip(
      id: rawTrip.id,
      title: rawTrip.title,
      startedAt: rawTrip.startedAt,
      endedAt: rawTrip.endedAt,
      status: rawTrip.status,
      locationPoints: cleanedPoints,
      stops: stops,
      distanceMeters: distance,
      durationSeconds: rawTrip.durationSeconds ?? duration,
      pausedDurationSeconds: rawTrip.pausedDurationSeconds,
      elevationGainMeters: elevation.gain,
      elevationLossMeters: elevation.loss,
      highestAltitude: elevation.highest,
      lowestAltitude: elevation.lowest,
      storyBackgroundImagePath: rawTrip.storyBackgroundImagePath,
      syncStatus: rawTrip.syncStatus,
      lastSyncedAt: rawTrip.lastSyncedAt,
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/trip.dart';
import '../../shared/models/location_point.dart';
import '../../features/trip/data/trip_repository.dart';
import '../../features/trip/data/trip_local_data_source.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'widget_service.dart';
import 'sync_service.dart';
import 'trip_engine.dart';
import 'gps_cleaner.dart';
import 'trip_calculator.dart';
import 'elevation_calculator.dart';
import 'stop_detector.dart';

class TrackingService {
  static final TrackingService instance = TrackingService(
    TripRepository(TripLocalDataSource()),
    LocationService(),
    TripEngine(
      GpsCleaner(),
      TripCalculator(),
      ElevationCalculator(),
      StopDetector(),
    ),
    GpsCleaner(),
  );

  final TripRepository _repository;
  final LocationService _locationService;
  final TripEngine _tripEngine;
  final GpsCleaner _gpsCleaner;

  Trip? _activeTrip;
  LocationPoint? _lastCapturedPoint;
  double _liveDistanceMeters = 0.0;
  Timer? _trackingTimer;
  Timer? _realtimeTickerTimer;
  final List<LocationPoint> _buffer = [];
  bool _isCapturing = false; // Mutex guard for _captureLocation

  static const Duration _trackingInterval = Duration(seconds: 5);
  static const Duration _tickerInterval = Duration(seconds: 1);

  final ValueNotifier<Trip?> activeTripNotifier = ValueNotifier<Trip?>(null);
  final ValueNotifier<LocationPoint?> locationNotifier = ValueNotifier<LocationPoint?>(null);

  TrackingService(
    this._repository,
    this._locationService,
    this._tripEngine, [
    GpsCleaner? gpsCleaner,
  ]) : _gpsCleaner = gpsCleaner ?? GpsCleaner();

  Future<Trip?> startTrip() async {
    if (_activeTrip != null) {
      debugPrint('[TrackingService] Trip already active: ${_activeTrip!.id}');
      activeTripNotifier.value = _activeTrip;
      await WidgetService.updateLiveTripWidget(
        trip: _activeTrip,
        currentPoint: _lastCapturedPoint,
      );
      return _activeTrip;
    }

    debugPrint('[TrackingService] Starting new trip...');
    
    // Wait for initial valid GPS coordinate before creating trip
    final initialPosition = await _waitForValidGPS();
    if (initialPosition == null) {
      debugPrint('[TrackingService] Failed to get initial GPS coordinate');
      return null;
    }

    debugPrint('[TrackingService] Got initial GPS: ${initialPosition.latitude}, ${initialPosition.longitude}, accuracy: ${initialPosition.accuracy}m');

    final uuid = const Uuid();
    final tripId = uuid.v4();
    final now = DateTime.now();
    
    final trip = Trip(
      id: tripId,
      startedAt: now,
      status: TripStatus.active,
      syncStatus: SyncStatus.pending,
      distanceMeters: 0.0,
    );

    await _repository.createTrip(trip);
    _activeTrip = trip;
    _liveDistanceMeters = 0.0;
    _buffer.clear();

    // Store initial point
    final initialPoint = LocationPoint(
      id: uuid.v4(),
      tripId: tripId,
      latitude: initialPosition.latitude,
      longitude: initialPosition.longitude,
      timestamp: now,
      accuracy: initialPosition.accuracy,
      altitude: initialPosition.altitude,
    );
    _lastCapturedPoint = initialPoint;
    _buffer.add(initialPoint);
    await _repository.addLocationPoint(initialPoint);
    
    debugPrint('[TrackingService] Trip created with initial point: $tripId');
    
    activeTripNotifier.value = _activeTrip;
    _startTracking();

    // Schedule reminder to continue/finish tracking 30m after start
    await NotificationService.instance
        .scheduleTrackingReminderNotification(trip.id);

    await WidgetService.updateLiveTripWidget(trip: trip, currentPoint: _lastCapturedPoint);

    // Trigger auto-sync when online
    SyncService.instance.triggerSync();

    return trip;
  }

  /// Wait for valid GPS coordinate (max 15s timeout with fallbacks)
  Future<dynamic> _waitForValidGPS() async {
    const maxAttempts = 3;
    dynamic bestPosition;

    for (int i = 0; i < maxAttempts; i++) {
      debugPrint('[TrackingService] GPS attempt ${i + 1}/$maxAttempts...');
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      // Validate coordinate
      if (position.latitude.abs() < 0.0001 && position.longitude.abs() < 0.0001) {
        debugPrint('[TrackingService] GPS returned (0,0), retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      if (position.accuracy <= 100) {
        return position;
      }

      bestPosition = position;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (bestPosition != null) {
      debugPrint('[TrackingService] Using best available GPS position: accuracy ${bestPosition.accuracy}m');
      return bestPosition;
    }

    // Fallback: Try last known position
    final lastKnown = await _locationService.getLastKnownPosition();
    if (lastKnown != null && lastKnown.latitude.abs() >= 0.0001) {
      debugPrint('[TrackingService] Using last known GPS position: ${lastKnown.latitude}, ${lastKnown.longitude}');
      return lastKnown;
    }

    // Dev/Offline Fallback coordinates (e.g. desktop/emulator without hardware GPS)
    debugPrint('[TrackingService] GPS hardware unavailable, using initial fallback coordinates');
    return Position(
      latitude: -6.2088,
      longitude: 106.8456,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 10.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  DateTime? _pausedAt;

  Future<Trip?> pauseTrip() async {
    if (_activeTrip == null) return null;
    if (_activeTrip!.status == TripStatus.paused) return _activeTrip;

    _pausedAt = DateTime.now();
    _stopTracking();

    _activeTrip = _activeTrip!.copyWith(status: TripStatus.paused);
    activeTripNotifier.value = _activeTrip;

    try {
      await _repository.updateTrip(_activeTrip!);
      await WidgetService.updateLiveTripWidget(
        trip: _activeTrip,
        currentPoint: _lastCapturedPoint,
      );
    } catch (e) {
      debugPrint('[TrackingService] Error persisting pause state: $e');
    }

    return _activeTrip;
  }

  Future<Trip?> resumeTrip() async {
    if (_activeTrip == null) return null;
    if (_activeTrip!.status == TripStatus.active) return _activeTrip;

    int additionalPaused = 0;
    if (_pausedAt != null) {
      additionalPaused = DateTime.now().difference(_pausedAt!).inSeconds;
      _pausedAt = null;
    }

    final newPausedSeconds = _activeTrip!.pausedDurationSeconds + additionalPaused;
    _activeTrip = _activeTrip!.copyWith(
      status: TripStatus.active,
      pausedDurationSeconds: newPausedSeconds,
    );
    activeTripNotifier.value = _activeTrip;

    _startTracking();

    try {
      await _repository.updateTrip(_activeTrip!);
      await WidgetService.updateLiveTripWidget(
        trip: _activeTrip,
        currentPoint: _lastCapturedPoint,
      );
    } catch (e) {
      debugPrint('[TrackingService] Error persisting resume state: $e');
    }

    return _activeTrip;
  }

  Future<Trip?> stopTrip() async {
    if (_activeTrip == null) {
      _activeTrip = await _repository.getActiveTrip();
      if (_activeTrip == null) {
        debugPrint('[TrackingService] No active trip to stop');
        return null;
      }
    }

    debugPrint('[TrackingService] Stopping trip: ${_activeTrip!.id}');
    final tripId = _activeTrip!.id;
    
    // Stop timers immediately
    _stopTracking();

    if (_pausedAt != null) {
      final addPaused = DateTime.now().difference(_pausedAt!).inSeconds;
      _activeTrip = _activeTrip!.copyWith(
        pausedDurationSeconds: _activeTrip!.pausedDurationSeconds + addPaused,
      );
      _pausedAt = null;
    }

    // Flush buffer
    if (_buffer.isNotEmpty) {
      debugPrint('[TrackingService] Flushing ${_buffer.length} buffered points');
      for (final p in _buffer) {
        try {
          await _repository.addLocationPoint(p);
        } catch (_) {}
      }
      _buffer.clear();
    }

    final points = await _repository.getLocationPoints(tripId);
    debugPrint('[TrackingService] Loaded ${points.length} points from database');

    final totalElapsedSeconds = DateTime.now().difference(_activeTrip!.startedAt).inSeconds;
    final activeDurationSeconds = (totalElapsedSeconds - _activeTrip!.pausedDurationSeconds).clamp(0, 8640000);

    final rawTrip = Trip(
      id: tripId,
      startedAt: _activeTrip!.startedAt,
      endedAt: DateTime.now(),
      status: TripStatus.completed,
      durationSeconds: activeDurationSeconds,
      pausedDurationSeconds: _activeTrip!.pausedDurationSeconds,
      syncStatus: SyncStatus.pending,
    );

    debugPrint('[TrackingService] Processing trip with TripEngine...');
    final processedTrip = _tripEngine.processTrip(rawTrip, points);
    debugPrint('[TrackingService] Processed: distance=${processedTrip.distanceMeters?.toStringAsFixed(1)}m, duration=${processedTrip.durationSeconds}s, stops=${processedTrip.stops.length}');

    await _repository.updateTrip(processedTrip);

    for (final stop in processedTrip.stops) {
      try {
        await _repository.addStop(stop, processedTrip.id);
      } catch (e) {
        debugPrint('[TrackingService] Error saving stop: $e');
      }
    }

    final savedTrip = processedTrip;
    _activeTrip = null;
    _lastCapturedPoint = null;
    activeTripNotifier.value = null;
    locationNotifier.value = null;

    // Clear Home Screen Widget safely
    try {
      await WidgetService.clearLiveTripWidget();
    } catch (e) {
      debugPrint('[TrackingService] Widget clear error: $e');
    }

    // 1. Cancel tracking reminder
    try {
      await NotificationService.instance
          .cancelTrackingReminderNotification(tripId);
    } catch (_) {}

    // 2. Show automatic trip completed notification immediately
    try {
      await NotificationService.instance
          .showTripCompletedNotification(processedTrip);
    } catch (_) {}

    // 3. Schedule Story reminder 24 hours later
    try {
      await NotificationService.instance
          .scheduleCreateStoryReminderNotification(tripId);
    } catch (_) {}

    // 4. Trigger auto-sync when online
    try {
      SyncService.instance.triggerSync();
    } catch (_) {}

    debugPrint('[TrackingService] Trip stopped successfully');
    return savedTrip;
  }

  Future<Trip?> getActiveTrip() async {
    if (_activeTrip != null) {
      activeTripNotifier.value = _activeTrip;
      await WidgetService.updateLiveTripWidget(
        trip: _activeTrip,
        currentPoint: _lastCapturedPoint,
      );
      return _activeTrip;
    }

    _activeTrip = await _repository.getActiveTrip();

    if (_activeTrip != null) {
      final rawPoints = await _repository.getLocationPoints(_activeTrip!.id);
      final cleanedPoints = _gpsCleaner.clean(rawPoints);
      _lastCapturedPoint = cleanedPoints.isNotEmpty ? cleanedPoints.last : null;
      _liveDistanceMeters = TripCalculator().calculateDistance(cleanedPoints);
      _activeTrip = _activeTrip!.copyWith(distanceMeters: _liveDistanceMeters);

      _startTracking();
      await NotificationService.instance
          .scheduleTrackingReminderNotification(_activeTrip!.id);
      await WidgetService.updateLiveTripWidget(
        trip: _activeTrip,
        currentPoint: _lastCapturedPoint,
      );
    } else {
      await WidgetService.clearLiveTripWidget();
    }

    activeTripNotifier.value = _activeTrip;
    return _activeTrip;
  }

  void _startTracking() {
    _trackingTimer?.cancel();
    _realtimeTickerTimer?.cancel();

    debugPrint('[TrackingService] Starting GPS tracking timers');

    // Location sampling loop (every 5s)
    _trackingTimer = Timer.periodic(_trackingInterval, (timer) async {
      await _captureLocation();
    });

    // Real-time UI & Widget sync ticker (every 1s)
    _realtimeTickerTimer = Timer.periodic(_tickerInterval, (timer) async {
      final trip = _activeTrip; // Atomic snapshot
      if (trip != null && trip.status == TripStatus.active) {
        // Trigger listeners for duration updates (no state mutation here)
        activeTripNotifier.value = trip;
        await WidgetService.updateLiveTripWidget(
          trip: trip,
          currentPoint: _lastCapturedPoint,
        );
      }
    });

    // Immediate first capture
    _captureLocation();
  }

  void _stopTracking() {
    debugPrint('[TrackingService] Stopping GPS tracking timers');
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _realtimeTickerTimer?.cancel();
    _realtimeTickerTimer = null;
  }

  Future<void> _captureLocation() async {
    // Mutex guard: prevent concurrent execution
    if (_isCapturing) {
      debugPrint('[TrackingService] _captureLocation already running, skipping');
      return;
    }
    _isCapturing = true;

    try {
      // Guard: check active trip still exists
      final trip = _activeTrip;
      if (trip == null || trip.status == TripStatus.paused) {
        return;
      }

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        debugPrint('[TrackingService] GPS position null');
        return;
      }

      final uuid = const Uuid();
      final point = LocationPoint(
        id: uuid.v4(),
        tripId: trip.id,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
        altitude: position.altitude,
      );

      // 1. Filter out poor accuracy or invalid points
      if (!_gpsCleaner.isPointValid(point)) {
        debugPrint('[TrackingService] GPS point rejected (invalid): lat=${point.latitude}, lon=${point.longitude}, acc=${point.accuracy}m');
        return;
      }

      // 2. Check if movement from last valid captured point is significant (prevents drift)
      if (_lastCapturedPoint != null) {
        final timeSinceLast = point.timestamp.difference(_lastCapturedPoint!.timestamp).inSeconds;
        final hasMoved = _gpsCleaner.isSignificantMovement(_lastCapturedPoint!, point);
        
        // Skip tiny jitter if < 30s, but record periodic heartbeat point (every 30s) to allow stop detection
        if (!hasMoved && timeSinceLast < 30) {
          debugPrint('[TrackingService] GPS point skipped (stationary within 30s)');
          return;
        }

        final delta = _gpsCleaner.calculateDistance(
          _lastCapturedPoint!.latitude,
          _lastCapturedPoint!.longitude,
          point.latitude,
          point.longitude,
        );
        if (hasMoved) {
          _liveDistanceMeters += delta;
        }
        debugPrint('[TrackingService] GPS point accepted: +${delta.toStringAsFixed(1)}m, total=${_liveDistanceMeters.toStringAsFixed(1)}m');
      } else {
        debugPrint('[TrackingService] GPS point accepted (first point): lat=${point.latitude}, lon=${point.longitude}');
      }

      _lastCapturedPoint = point;
      // Notify location listeners immediately (map update without DB reload)
      locationNotifier.value = point;
      _buffer.add(point);

      // Guard: check trip still active before updating
      if (_activeTrip != null && _activeTrip!.id == trip.id) {
        _activeTrip = _activeTrip!.copyWith(
          distanceMeters: _liveDistanceMeters,
        );

        // Immediately save each point to repository so map and detail see it in real-time
        await _repository.addLocationPoint(point);
        await _repository.updateTrip(_activeTrip!);
        _buffer.clear();

        // Refresh active trip reference in notifier
        activeTripNotifier.value = _activeTrip;

        // Update Home Screen Widget real-time
        await WidgetService.updateLiveTripWidget(
          trip: _activeTrip,
          currentPoint: _lastCapturedPoint,
        );
      }
    } finally {
      _isCapturing = false;
    }
  }

  bool get isTracking => _activeTrip != null;

  Trip? get activeTrip => _activeTrip;

  LocationPoint? get lastCapturedPoint => _lastCapturedPoint;

  void dispose() {
    _stopTracking();
  }
}







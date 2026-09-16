import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/trip/data/trip_local_data_source.dart';
import '../../features/trip/data/trip_repository.dart';
import '../../shared/models/trip.dart';

enum SyncState { offline, synced, syncing, failed }

class SyncService {
  static final SyncService instance = SyncService(
    TripRepository(TripLocalDataSource()),
  );

  final TripRepository _repository;
  final ValueNotifier<SyncState> syncStateNotifier =
      ValueNotifier<SyncState>(SyncState.synced);

  Timer? _connectivityTimer;
  bool _isSyncing = false;
  bool _isOnline = true;

  static const String _backendEndpoint = 'https://httpbin.org/post';

  SyncService(this._repository);

  void init() {
    _startConnectivityCheck();
    triggerSync();
  }

  void _startConnectivityCheck() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final online = await _checkInternetConnection();
      if (online != _isOnline) {
        _isOnline = online;
        if (!_isOnline) {
          syncStateNotifier.value = SyncState.offline;
        } else {
          triggerSync();
        }
      } else if (_isOnline && syncStateNotifier.value == SyncState.offline) {
        triggerSync();
      }
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;

    final online = await _checkInternetConnection();
    _isOnline = online;

    if (!online) {
      syncStateNotifier.value = SyncState.offline;
      return;
    }

    _isSyncing = true;
    syncStateNotifier.value = SyncState.syncing;

    try {
      final unsyncedTrips = await _repository.getUnsyncedTrips();

      if (unsyncedTrips.isEmpty) {
        syncStateNotifier.value = SyncState.synced;
        _isSyncing = false;
        return;
      }

      bool hasFailures = false;

      for (final trip in unsyncedTrips) {
        final success = await _syncSingleTrip(trip);
        if (success) {
          await _repository.updateSyncStatus(
            trip.id,
            SyncStatus.synced,
            syncedAt: DateTime.now(),
          );
        } else {
          await _repository.updateSyncStatus(
            trip.id,
            SyncStatus.failed,
          );
          hasFailures = true;
        }
      }

      if (hasFailures) {
        syncStateNotifier.value = SyncState.failed;
      } else {
        syncStateNotifier.value = SyncState.synced;
      }
    } catch (e) {
      debugPrint('SyncService error during sync: $e');
      syncStateNotifier.value = SyncState.failed;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _syncSingleTrip(Trip trip) async {
    try {
      final payload = {
        'trip_id': trip.id,
        'title': trip.title,
        'started_at': trip.startedAt.toIso8601String(),
        'ended_at': trip.endedAt?.toIso8601String(),
        'status': trip.status.name,
        'distance_meters': trip.distanceMeters,
        'duration_seconds': trip.durationSeconds,
        'elevation_gain_meters': trip.elevationGainMeters,
        'elevation_loss_meters': trip.elevationLossMeters,
        'highest_altitude': trip.highestAltitude,
        'lowest_altitude': trip.lowestAltitude,
        'story_background_image_path': trip.storyBackgroundImagePath,
        'location_points': trip.locationPoints
            .map((p) => {
                  'id': p.id,
                  'latitude': p.latitude,
                  'longitude': p.longitude,
                  'timestamp': p.timestamp.toIso8601String(),
                  'accuracy': p.accuracy,
                  'altitude': p.altitude,
                })
            .toList(),
        'stops': trip.stops
            .map((s) => {
                  'id': s.id,
                  'arrival_time': s.arrivalTime.toIso8601String(),
                  'departure_time': s.departureTime.toIso8601String(),
                  'latitude': s.latitude,
                  'longitude': s.longitude,
                  'duration_seconds': s.durationSeconds,
                  'place_id': s.placeId,
                  'place_name': s.placeName,
                })
            .toList(),
      };

      final response = await http
          .post(
            Uri.parse(_backendEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error syncing trip ${trip.id}: $e');
      return false;
    }
  }

  bool get isOnline => _isOnline;

  void dispose() {
    _connectivityTimer?.cancel();
  }
}

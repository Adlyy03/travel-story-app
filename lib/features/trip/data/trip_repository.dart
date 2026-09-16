import '../../../core/services/notification_service.dart';
import '../../../shared/models/location_point.dart';
import '../../../shared/models/stop.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/trip_photo.dart';
import 'trip_local_data_source.dart';

class TripRepository {
  final TripLocalDataSource _localDataSource;

  TripRepository(this._localDataSource);

  Future<String> createTrip(Trip trip) async {
    return await _localDataSource.createTrip(trip);
  }

  Future<void> updateTrip(Trip trip) async {
    await _localDataSource.updateTrip(trip);
  }

  Future<Trip?> getTripById(String id) async {
    return await _localDataSource.getTripById(id);
  }

  Future<List<Trip>> getAllTrips() async {
    return await _localDataSource.getAllTrips();
  }

  Future<Trip?> getActiveTrip() async {
    return await _localDataSource.getActiveTrip();
  }

  Future<void> deleteTrip(String id) async {
    await _localDataSource.deleteTrip(id);
    await NotificationService.instance.cancelTrackingReminderNotification(id);
    await NotificationService.instance.cancelCreateStoryReminderNotification(id);
  }

  Future<void> deleteAllTrips() async {
    await _localDataSource.deleteAllTrips();
  }

  Future<void> addLocationPoint(LocationPoint point) async {
    await _localDataSource.insertLocationPoint(point);
  }

  Future<List<LocationPoint>> getLocationPoints(String tripId) async {
    return await _localDataSource.getLocationPointsByTripId(tripId);
  }

  Future<void> addStop(Stop stop, String tripId) async {
    await _localDataSource.insertStop(stop, tripId);
  }

  Future<List<Stop>> getStops(String tripId) async {
    return await _localDataSource.getStopsByTripId(tripId);
  }

  Future<void> updateStoryBackgroundImage(
      String tripId, String? imagePath) async {
    await _localDataSource.updateStoryBackgroundImage(tripId, imagePath);
    if (imagePath != null && imagePath.isNotEmpty) {
      await NotificationService.instance
          .cancelCreateStoryReminderNotification(tripId);
    }
  }

  Future<List<Trip>> getUnsyncedTrips() async {
    return await _localDataSource.getUnsyncedTrips();
  }

  Future<void> updateSyncStatus(
    String tripId,
    SyncStatus status, {
    DateTime? syncedAt,
  }) async {
    await _localDataSource.updateSyncStatus(tripId, status, syncedAt: syncedAt);
  }

  Future<void> addTripPhoto(TripPhoto photo) async {
    await _localDataSource.insertTripPhoto(photo);
  }

  Future<List<TripPhoto>> getTripPhotos(String tripId) async {
    return await _localDataSource.getTripPhotosByTripId(tripId);
  }

  Future<void> deleteTripPhoto(String photoId) async {
    await _localDataSource.deleteTripPhoto(photoId);
  }
}

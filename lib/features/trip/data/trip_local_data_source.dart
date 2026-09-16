import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/location_point.dart';
import '../../../shared/models/stop.dart';
import '../../../shared/models/trip_photo.dart';

class TripLocalDataSource {
  Future<String> createTrip(Trip trip) async {
    final db = await AppDatabase.database;
    await db.insert('trips', trip.toMap());
    return trip.id;
  }

  Future<void> updateTrip(Trip trip) async {
    final db = await AppDatabase.database;
    await db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<Trip?> getTripById(String id) async {
    final db = await AppDatabase.database;
    final results = await db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;

    return Trip.fromMap(results.first);
  }

  Future<List<Trip>> getAllTrips() async {
    final db = await AppDatabase.database;
    final results = await db.query(
      'trips',
      orderBy: 'started_at DESC',
    );

    return results.map((map) => Trip.fromMap(map)).toList();
  }

  Future<Trip?> getActiveTrip() async {
    final db = await AppDatabase.database;
    final results = await db.query(
      'trips',
      where: 'status = ? OR status = ?',
      whereArgs: ['active', 'paused'],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Trip.fromMap(results.first);
  }

  Future<void> deleteTrip(String id) async {
    final db = await AppDatabase.database;
    await db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTrips() async {
    final db = await AppDatabase.database;
    await db.delete('trips');
    await db.delete('location_points');
    await db.delete('stops');
  }

  Future<void> insertLocationPoint(LocationPoint point) async {
    final db = await AppDatabase.database;
    await db.insert(
      'location_points',
      point.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStop(Stop stop, String tripId) async {
    final db = await AppDatabase.database;
    final stopMap = stop.toMap();
    stopMap['trip_id'] = tripId;
    await db.insert(
      'stops',
      stopMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Stop>> getStopsByTripId(String tripId) async {
    final db = await AppDatabase.database;
    final results = await db.query(
      'stops',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'arrival_time ASC',
    );

    return results.map((map) => Stop.fromMap(map)).toList();
  }

  Future<List<LocationPoint>> getLocationPointsByTripId(String tripId) async {
    final db = await AppDatabase.database;
    final results = await db.query(
      'location_points',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'timestamp ASC',
    );

    return results.map((map) => LocationPoint.fromMap(map)).toList();
  }

  Future<void> updateStoryBackgroundImage(String tripId, String? imagePath) async {
    final db = await AppDatabase.database;
    await db.update(
      'trips',
      {'story_background_image_path': imagePath},
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  Future<List<Trip>> getUnsyncedTrips() async {
    final db = await AppDatabase.database;
    final results = await db.query(
      'trips',
      where: 'sync_status = ? OR sync_status = ?',
      whereArgs: [SyncStatus.pending.name, SyncStatus.failed.name],
      orderBy: 'started_at ASC',
    );

    final List<Trip> trips = [];
    for (final map in results) {
      final trip = Trip.fromMap(map);
      final points = await getLocationPointsByTripId(trip.id);
      final stops = await getStopsByTripId(trip.id);
      trips.add(trip.copyWith(locationPoints: points, stops: stops));
    }
    return trips;
  }

  Future<void> updateSyncStatus(
    String tripId,
    SyncStatus status, {
    DateTime? syncedAt,
  }) async {
    final db = await AppDatabase.database;
    await db.update(
      'trips',
      {
        'sync_status': status.name,
        'last_synced_at': syncedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  Future<void> insertTripPhoto(TripPhoto photo) async {
    final db = await AppDatabase.database;
    await db.insert('trip_photos', photo.toMap());
  }

  Future<List<TripPhoto>> getTripPhotosByTripId(String tripId) async {
    final db = await AppDatabase.database;
    final results = await db.query(
      'trip_photos',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'timestamp ASC',
    );
    return results.map((m) => TripPhoto.fromMap(m)).toList();
  }

  Future<void> deleteTripPhoto(String photoId) async {
    final db = await AppDatabase.database;
    await db.delete(
      'trip_photos',
      where: 'id = ?',
      whereArgs: [photoId],
    );
  }
}

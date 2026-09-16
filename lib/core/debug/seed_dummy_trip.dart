import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

/// Seeds a dummy completed trip around Kebun Raya Bogor into the local database.
/// Call once from a debug button or main, then remove.
class SeedDummyTrip {
  static Future<void> seed() async {
    final db = await AppDatabase.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM trips'));
    if (count != null && count > 0) return;

    const uuid = Uuid();

    final tripId = uuid.v4();
    final startTime = DateTime(2026, 9, 2, 8, 0, 0); // 2 Sep 2026, 08:00
    final endTime = DateTime(2026, 9, 2, 10, 45, 0);  // 10:45

    // Trip record
    await db.insert('trips', {
      'id': tripId,
      'title': 'Eksplorasi Kebun Raya Bogor',
      'started_at': startTime.toIso8601String(),
      'ended_at': endTime.toIso8601String(),
      'status': 'completed',
      'distance_meters': 4850.0,
      'duration_seconds': 9900, // 2h 45m
      'paused_duration_seconds': 600, // 10 min rest
      'elevation_gain_meters': 42.0,
      'elevation_loss_meters': 38.0,
      'highest_altitude': 275.0,
      'lowest_altitude': 248.0,
      'sync_status': 'synced',
    });

    // Realistic GPS route around Kebun Raya Bogor
    // Starting from main gate, clockwise loop through key spots
    final routeCoords = <List<double>>[
      // Gate Utama (Start)
      [-6.59694, 106.79889],
      [-6.59720, 106.79920],
      [-6.59755, 106.79958],
      [-6.59790, 106.79995],
      // Jalan masuk, belok kanan
      [-6.59830, 106.80040],
      [-6.59870, 106.80090],
      [-6.59900, 106.80130],
      [-6.59940, 106.80170],
      // Area Taman Teijsmann
      [-6.59980, 106.80210],
      [-6.60020, 106.80240],
      [-6.60060, 106.80270],
      [-6.60100, 106.80300],
      [-6.60140, 106.80330],
      // Ke arah Danau Gunting
      [-6.60180, 106.80350],
      [-6.60220, 106.80370],
      [-6.60270, 106.80390],
      [-6.60320, 106.80400],
      [-6.60370, 106.80410],
      [-6.60420, 106.80415],
      // Danau Gunting area
      [-6.60470, 106.80410],
      [-6.60520, 106.80400],
      [-6.60560, 106.80385],
      [-6.60600, 106.80365],
      // Belok ke selatan
      [-6.60640, 106.80340],
      [-6.60680, 106.80310],
      [-6.60720, 106.80280],
      [-6.60760, 106.80250],
      [-6.60800, 106.80220],
      // Area Taman Meksiko
      [-6.60840, 106.80190],
      [-6.60880, 106.80160],
      [-6.60920, 106.80130],
      [-6.60960, 106.80100],
      [-6.61000, 106.80070],
      // Belok ke barat
      [-6.61030, 106.80030],
      [-6.61050, 106.79990],
      [-6.61060, 106.79950],
      [-6.61070, 106.79910],
      [-6.61075, 106.79870],
      // Jalan barat, ke utara
      [-6.61070, 106.79830],
      [-6.61060, 106.79790],
      [-6.61040, 106.79750],
      [-6.61015, 106.79710],
      [-6.60985, 106.79680],
      // Area Orchid House
      [-6.60950, 106.79650],
      [-6.60910, 106.79630],
      [-6.60870, 106.79615],
      [-6.60830, 106.79605],
      [-6.60790, 106.79600],
      // Ke utara, lewat Istana Bogor side
      [-6.60750, 106.79600],
      [-6.60710, 106.79605],
      [-6.60670, 106.79615],
      [-6.60630, 106.79630],
      [-6.60590, 106.79650],
      [-6.60550, 106.79670],
      [-6.60510, 106.79695],
      // Belok ke timur, kembali
      [-6.60470, 106.79720],
      [-6.60430, 106.79745],
      [-6.60390, 106.79770],
      [-6.60350, 106.79795],
      [-6.60310, 106.79820],
      [-6.60270, 106.79840],
      // Mendekati gate utara lagi
      [-6.60230, 106.79855],
      [-6.60190, 106.79865],
      [-6.60150, 106.79870],
      [-6.60110, 106.79872],
      [-6.60070, 106.79875],
      [-6.60030, 106.79878],
      [-6.59990, 106.79880],
      [-6.59950, 106.79882],
      [-6.59910, 106.79884],
      [-6.59870, 106.79886],
      [-6.59830, 106.79887],
      [-6.59790, 106.79888],
      [-6.59750, 106.79889],
      // Kembali ke Gate Utama
      [-6.59720, 106.79889],
      [-6.59694, 106.79889],
    ];

    // Insert location points (5-second intervals)
    for (int i = 0; i < routeCoords.length; i++) {
      final coord = routeCoords[i];
      final timestamp = startTime.add(Duration(seconds: i * 120)); // ~2 min per point
      await db.insert('location_points', {
        'id': uuid.v4(),
        'trip_id': tripId,
        'latitude': coord[0],
        'longitude': coord[1],
        'timestamp': timestamp.toIso8601String(),
        'accuracy': 4.0 + (i % 3) * 1.5, // realistic accuracy 4-7.5m
        'altitude': 250.0 + (i % 8) * 3.5, // gentle altitude variation
      });
    }

    // Stops (rest points)
    // Stop 1: Danau Gunting
    await db.insert('stops', {
      'id': uuid.v4(),
      'trip_id': tripId,
      'arrival_time': startTime.add(const Duration(minutes: 40)).toIso8601String(),
      'departure_time': startTime.add(const Duration(minutes: 50)).toIso8601String(),
      'latitude': -6.60470,
      'longitude': 106.80410,
      'duration_seconds': 600,
      'place_name': 'Danau Gunting',
    });

    // Stop 2: Taman Meksiko
    await db.insert('stops', {
      'id': uuid.v4(),
      'trip_id': tripId,
      'arrival_time': startTime.add(const Duration(minutes: 80)).toIso8601String(),
      'departure_time': startTime.add(const Duration(minutes: 88)).toIso8601String(),
      'latitude': -6.61000,
      'longitude': 106.80070,
      'duration_seconds': 480,
      'place_name': 'Taman Meksiko',
    });

    // Stop 3: Orchid House
    await db.insert('stops', {
      'id': uuid.v4(),
      'trip_id': tripId,
      'arrival_time': startTime.add(const Duration(minutes: 115)).toIso8601String(),
      'departure_time': startTime.add(const Duration(minutes: 125)).toIso8601String(),
      'latitude': -6.60870,
      'longitude': 106.79615,
      'duration_seconds': 600,
      'place_name': 'Rumah Anggrek',
    });
  }
}

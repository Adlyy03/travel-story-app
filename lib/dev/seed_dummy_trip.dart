import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../shared/models/trip.dart';
import '../shared/models/location_point.dart';
import '../features/trip/data/trip_repository.dart';
import '../features/trip/data/trip_local_data_source.dart';
import '../core/services/trip_engine.dart';
import '../core/services/gps_cleaner.dart';
import '../core/services/trip_calculator.dart';
import '../core/services/elevation_calculator.dart';
import '../core/services/stop_detector.dart';

/// Seed dummy trip: keliling kota Bogor
/// Route: Kebun Raya → Tugu Kujang → Istana Bogor → Pasar Bogor → Kebun Raya
Future<void> seedDummyTripBogor() async {
  debugPrint('[SeedData] Creating dummy trip: Keliling Kota Bogor');

  final uuid = const Uuid();
  final tripId = uuid.v4();
  
  // Start time: kemarin pagi jam 8
  final startTime = DateTime.now().subtract(const Duration(days: 1, hours: 16));

  // Route points: Kebun Raya → Tugu Kujang → Istana → Pasar → Kebun Raya
  final rawPoints = <LocationPoint>[
    // 1. Kebun Raya Bogor (start)
    _point(tripId, -6.5972, 106.7997, startTime, 0),
    _point(tripId, -6.5975, 106.8005, startTime, 30),
    _point(tripId, -6.5980, 106.8012, startTime, 60),
    
    // 2. Menuju Tugu Kujang
    _point(tripId, -6.5985, 106.8020, startTime, 120),
    _point(tripId, -6.5990, 106.8028, startTime, 180),
    _point(tripId, -6.5995, 106.8035, startTime, 240),
    _point(tripId, -6.6000, 106.8042, startTime, 300),
    _point(tripId, -6.6005, 106.8050, startTime, 360),
    
    // 3. Tugu Kujang (stop 5 menit)
    _point(tripId, -6.6010, 106.8058, startTime, 420),
    _point(tripId, -6.6010, 106.8058, startTime, 480),
    _point(tripId, -6.6010, 106.8058, startTime, 540),
    _point(tripId, -6.6010, 106.8058, startTime, 600),
    _point(tripId, -6.6010, 106.8058, startTime, 660),
    
    // 4. Menuju Istana Bogor
    _point(tripId, -6.6008, 106.8065, startTime, 720),
    _point(tripId, -6.6005, 106.8072, startTime, 780),
    _point(tripId, -6.6000, 106.8078, startTime, 840),
    _point(tripId, -6.5995, 106.8083, startTime, 900),
    _point(tripId, -6.5988, 106.8087, startTime, 960),
    
    // 5. Istana Bogor area (stop 10 menit foto-foto)
    _point(tripId, -6.5980, 106.8090, startTime, 1020),
    _point(tripId, -6.5980, 106.8090, startTime, 1080),
    _point(tripId, -6.5980, 106.8090, startTime, 1140),
    _point(tripId, -6.5980, 106.8090, startTime, 1200),
    _point(tripId, -6.5980, 106.8090, startTime, 1260),
    _point(tripId, -6.5980, 106.8090, startTime, 1320),
    _point(tripId, -6.5980, 106.8090, startTime, 1380),
    _point(tripId, -6.5980, 106.8090, startTime, 1440),
    _point(tripId, -6.5980, 106.8090, startTime, 1500),
    _point(tripId, -6.5980, 106.8090, startTime, 1560),
    _point(tripId, -6.5980, 106.8090, startTime, 1620),
    
    // 6. Menuju Pasar Bogor
    _point(tripId, -6.5975, 106.8095, startTime, 1680),
    _point(tripId, -6.5970, 106.8100, startTime, 1740),
    _point(tripId, -6.5965, 106.8105, startTime, 1800),
    _point(tripId, -6.5960, 106.8110, startTime, 1860),
    
    // 7. Pasar Bogor (stop 15 menit belanja)
    _point(tripId, -6.5955, 106.8115, startTime, 1920),
    _point(tripId, -6.5955, 106.8115, startTime, 1980),
    _point(tripId, -6.5955, 106.8115, startTime, 2040),
    _point(tripId, -6.5955, 106.8115, startTime, 2100),
    _point(tripId, -6.5955, 106.8115, startTime, 2160),
    _point(tripId, -6.5955, 106.8115, startTime, 2220),
    _point(tripId, -6.5955, 106.8115, startTime, 2280),
    _point(tripId, -6.5955, 106.8115, startTime, 2340),
    _point(tripId, -6.5955, 106.8115, startTime, 2400),
    _point(tripId, -6.5955, 106.8115, startTime, 2460),
    _point(tripId, -6.5955, 106.8115, startTime, 2520),
    _point(tripId, -6.5955, 106.8115, startTime, 2580),
    _point(tripId, -6.5955, 106.8115, startTime, 2640),
    _point(tripId, -6.5955, 106.8115, startTime, 2700),
    _point(tripId, -6.5955, 106.8115, startTime, 2760),
    
    // 8. Kembali ke Kebun Raya
    _point(tripId, -6.5960, 106.8108, startTime, 2820),
    _point(tripId, -6.5965, 106.8100, startTime, 2880),
    _point(tripId, -6.5968, 106.8092, startTime, 2940),
    _point(tripId, -6.5970, 106.8085, startTime, 3000),
    _point(tripId, -6.5972, 106.8078, startTime, 3060),
    _point(tripId, -6.5973, 106.8070, startTime, 3120),
    _point(tripId, -6.5974, 106.8062, startTime, 3180),
    _point(tripId, -6.5975, 106.8055, startTime, 3240),
    _point(tripId, -6.5976, 106.8048, startTime, 3300),
    _point(tripId, -6.5977, 106.8040, startTime, 3360),
    _point(tripId, -6.5978, 106.8032, startTime, 3420),
    _point(tripId, -6.5979, 106.8024, startTime, 3480),
    _point(tripId, -6.5980, 106.8016, startTime, 3540),
    _point(tripId, -6.5981, 106.8008, startTime, 3600),
    
    // 9. Finish di Kebun Raya
    _point(tripId, -6.5972, 106.7997, startTime, 3660),
  ];

  debugPrint('[SeedData] Generated ${rawPoints.length} GPS points');

  final repository = TripRepository(TripLocalDataSource());
  final engine = TripEngine(
    GpsCleaner(),
    TripCalculator(),
    ElevationCalculator(),
    StopDetector(),
  );

  // Create raw trip
  final rawTrip = Trip(
    id: tripId,
    title: 'Keliling Kota Bogor',
    startedAt: rawPoints.first.timestamp,
    endedAt: rawPoints.last.timestamp,
    status: TripStatus.completed,
    syncStatus: SyncStatus.pending,
  );

  // Process trip
  debugPrint('[SeedData] Processing trip with TripEngine...');
  final processedTrip = engine.processTrip(rawTrip, rawPoints);

  // Save to database
  await repository.createTrip(processedTrip);
  
  debugPrint('[SeedData] Trip metrics: distance=${processedTrip.distanceMeters?.toStringAsFixed(1) ?? "null"}m, points=${processedTrip.locationPoints.length}, stops=${processedTrip.stops.length}');
  
  for (final point in processedTrip.locationPoints) {
    await repository.addLocationPoint(point);
  }

  for (final stop in processedTrip.stops) {
    await repository.addStop(stop, tripId);
  }

  debugPrint('[SeedData] Trip saved: ${processedTrip.distanceMeters?.toStringAsFixed(0)}m, ${processedTrip.durationSeconds}s, ${processedTrip.stops.length} stops');
  debugPrint('[SeedData] Dummy trip created successfully! Trip ID: $tripId');
}

LocationPoint _point(String tripId, double lat, double lon, DateTime start, int secondsOffset) {
  return LocationPoint(
    id: const Uuid().v4(),
    tripId: tripId,
    latitude: lat,
    longitude: lon,
    timestamp: start.add(Duration(seconds: secondsOffset)),
    accuracy: 8.0 + (secondsOffset % 5), // 8-12m accuracy
    altitude: 250.0 + (secondsOffset % 20 - 10), // ~240-260m elevation
  );
}

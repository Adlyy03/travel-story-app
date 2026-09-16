import 'location_point.dart';
import 'stop.dart';

enum TripStatus { active, paused, completed }

enum SyncStatus { pending, synced, failed }

class Trip {
  final String id;
  final String? title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TripStatus status;
  final List<LocationPoint> locationPoints;
  final List<Stop> stops;
  final double? distanceMeters;
  final int? durationSeconds;
  final int pausedDurationSeconds;
  final double? elevationGainMeters;
  final double? elevationLossMeters;
  final double? highestAltitude;
  final double? lowestAltitude;
  final String? storyBackgroundImagePath;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;

  Trip({
    required this.id,
    this.title,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.locationPoints = const [],
    this.stops = const [],
    this.distanceMeters,
    this.durationSeconds,
    this.pausedDurationSeconds = 0,
    this.elevationGainMeters,
    this.elevationLossMeters,
    this.highestAltitude,
    this.lowestAltitude,
    this.storyBackgroundImagePath,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'status': status.name,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'paused_duration_seconds': pausedDurationSeconds,
      'elevation_gain_meters': elevationGainMeters,
      'elevation_loss_meters': elevationLossMeters,
      'highest_altitude': highestAltitude,
      'lowest_altitude': lowestAltitude,
      'story_background_image_path': storyBackgroundImagePath,
      'sync_status': syncStatus.name,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String?,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null 
          ? DateTime.parse(map['ended_at'] as String) 
          : null,
      status: TripStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TripStatus.active,
      ),
      distanceMeters: (map['distance_meters'] as num?)?.toDouble(),
      durationSeconds: (map['duration_seconds'] as num?)?.toInt(),
      pausedDurationSeconds: (map['paused_duration_seconds'] as num?)?.toInt() ?? 0,
      elevationGainMeters: (map['elevation_gain_meters'] as num?)?.toDouble(),
      elevationLossMeters: (map['elevation_loss_meters'] as num?)?.toDouble(),
      highestAltitude: (map['highest_altitude'] as num?)?.toDouble(),
      lowestAltitude: (map['lowest_altitude'] as num?)?.toDouble(),
      storyBackgroundImagePath: map['story_background_image_path'] as String?,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (map['sync_status'] ?? 'pending'),
        orElse: () => SyncStatus.pending,
      ),
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'] as String)
          : null,
    );
  }
  
  Trip copyWith({
    String? id,
    String? title,
    DateTime? startedAt,
    DateTime? endedAt,
    TripStatus? status,
    List<LocationPoint>? locationPoints,
    List<Stop>? stops,
    double? distanceMeters,
    int? durationSeconds,
    int? pausedDurationSeconds,
    double? elevationGainMeters,
    double? elevationLossMeters,
    double? highestAltitude,
    double? lowestAltitude,
    String? storyBackgroundImagePath,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      locationPoints: locationPoints ?? this.locationPoints,
      stops: stops ?? this.stops,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pausedDurationSeconds: pausedDurationSeconds ?? this.pausedDurationSeconds,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      elevationLossMeters: elevationLossMeters ?? this.elevationLossMeters,
      highestAltitude: highestAltitude ?? this.highestAltitude,
      lowestAltitude: lowestAltitude ?? this.lowestAltitude,
      storyBackgroundImagePath: storyBackgroundImagePath ?? this.storyBackgroundImagePath,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

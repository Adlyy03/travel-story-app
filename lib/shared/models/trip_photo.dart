class TripPhoto {
  final String id;
  final String tripId;
  final String path;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? caption;

  const TripPhoto({
    required this.id,
    required this.tripId,
    required this.path,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.caption,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'path': path,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'caption': caption,
    };
  }

  factory TripPhoto.fromMap(Map<String, dynamic> map) {
    return TripPhoto(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      path: map['path'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      caption: map['caption'] as String?,
    );
  }

  TripPhoto copyWith({
    String? id,
    String? tripId,
    String? path,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? caption,
  }) {
    return TripPhoto(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      path: path ?? this.path,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      caption: caption ?? this.caption,
    );
  }
}

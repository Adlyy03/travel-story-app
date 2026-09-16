class Stop {
  final String id;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final double latitude;
  final double longitude;
  final int durationSeconds;
  final String? placeId;
  final String? placeName;

  Stop({
    required this.id,
    required this.arrivalTime,
    required this.departureTime,
    required this.latitude,
    required this.longitude,
    required this.durationSeconds,
    this.placeId,
    this.placeName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'arrival_time': arrivalTime.toIso8601String(),
      'departure_time': departureTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'duration_seconds': durationSeconds,
      'place_id': placeId,
      'place_name': placeName,
    };
  }

  factory Stop.fromMap(Map<String, dynamic> map) {
    return Stop(
      id: map['id'] as String,
      arrivalTime: DateTime.parse(map['arrival_time'] as String),
      departureTime: DateTime.parse(map['departure_time'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      durationSeconds: (map['duration_seconds'] as num).toInt(),
      placeId: map['place_id'] as String?,
      placeName: map['place_name'] as String?,
    );
  }
}

import '../../../shared/models/trip_photo.dart';
import 'story_template.dart';

/// Immutable data model for a story. TripEngine → StoryBuilder → StoryModel.
class StoryModel {
  final String tripId;
  final String title;
  final DateTime date;
  final String route;
  final double? distanceMeters;
  final int? durationSeconds;
  final double? averageSpeedKmh;
  final double? elevationGainMeters;
  final double? elevationLossMeters;
  final String? startLocationName;
  final String? finishLocationName;
  final List<StoryPlace> places;
  final List<StoryTimelineEntry> timeline;
  final String? backgroundImagePath;
  final List<RoutePoint> routePoints;
  final List<TripPhoto> photos;
  final StoryTemplate template;
  final bool showStatistics;
  final bool showTimeline;
  final bool showRoute;
  final bool showPhotos;

  const StoryModel({
    required this.tripId,
    required this.title,
    required this.date,
    required this.route,
    this.distanceMeters,
    this.durationSeconds,
    this.averageSpeedKmh,
    this.elevationGainMeters,
    this.elevationLossMeters,
    this.startLocationName,
    this.finishLocationName,
    this.places = const [],
    this.timeline = const [],
    this.backgroundImagePath,
    this.routePoints = const [],
    this.photos = const [],
    this.template = StoryTemplate.glass,
    this.showStatistics = true,
    this.showTimeline = true,
    this.showRoute = true,
    this.showPhotos = true,
  });

  StoryModel copyWith({
    String? tripId,
    String? title,
    DateTime? date,
    String? route,
    double? distanceMeters,
    int? durationSeconds,
    double? averageSpeedKmh,
    double? elevationGainMeters,
    double? elevationLossMeters,
    String? startLocationName,
    String? finishLocationName,
    List<StoryPlace>? places,
    List<StoryTimelineEntry>? timeline,
    String? backgroundImagePath,
    bool clearBackground = false,
    List<RoutePoint>? routePoints,
    List<TripPhoto>? photos,
    StoryTemplate? template,
    bool? showStatistics,
    bool? showTimeline,
    bool? showRoute,
    bool? showPhotos,
  }) {
    return StoryModel(
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      date: date ?? this.date,
      route: route ?? this.route,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      elevationLossMeters: elevationLossMeters ?? this.elevationLossMeters,
      startLocationName: startLocationName ?? this.startLocationName,
      finishLocationName: finishLocationName ?? this.finishLocationName,
      places: places ?? this.places,
      timeline: timeline ?? this.timeline,
      backgroundImagePath: clearBackground ? null : (backgroundImagePath ?? this.backgroundImagePath),
      routePoints: routePoints ?? this.routePoints,
      photos: photos ?? this.photos,
      template: template ?? this.template,
      showStatistics: showStatistics ?? this.showStatistics,
      showTimeline: showTimeline ?? this.showTimeline,
      showRoute: showRoute ?? this.showRoute,
      showPhotos: showPhotos ?? this.showPhotos,
    );
  }
}

class StoryPlace {
  final String name;
  final DateTime time;
  final int durationMinutes;

  const StoryPlace({
    required this.name,
    required this.time,
    required this.durationMinutes,
  });
}

class StoryTimelineEntry {
  final DateTime time;
  final String label;
  final bool isStop;
  final bool isPhoto;

  const StoryTimelineEntry({
    required this.time,
    required this.label,
    this.isStop = false,
    this.isPhoto = false,
  });
}

class RoutePoint {
  final double lat;
  final double lng;

  const RoutePoint(this.lat, this.lng);
}

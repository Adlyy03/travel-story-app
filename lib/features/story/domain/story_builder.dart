import 'package:intl/intl.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/trip_photo.dart';
import 'story_model.dart';

/// Transforms a Trip + Photos into a StoryModel.
/// Reads all metrics from Trip fields — never recalculates.
class StoryBuilder {
  StoryModel build(Trip trip, {List<TripPhoto> photos = const []}) {
    final date = trip.startedAt;

    // Build route string from stop place names
    final stopNames = trip.stops
        .where((s) => s.placeName != null && s.placeName!.isNotEmpty)
        .map((s) => s.placeName!)
        .toList();

    final String route;
    if (stopNames.isEmpty) {
      route = DateFormat('d MMM yyyy').format(date);
    } else if (stopNames.length == 1) {
      route = stopNames.first;
    } else {
      route = '${stopNames.first} → ${stopNames.last}';
    }

    final title = trip.title?.isNotEmpty == true
        ? trip.title!
        : 'Journey · ${DateFormat('d MMM yyyy').format(date)}';

    // Average speed km/h
    double? avgSpeed;
    final dist = trip.distanceMeters;
    final dur = trip.durationSeconds;
    if (dist != null && dur != null && dur > 0) {
      avgSpeed = (dist / 1000) / (dur / 3600);
    }

    // Start / finish location names from stops
    String? startName;
    String? finishName;
    if (trip.stops.isNotEmpty) {
      startName = trip.stops.first.placeName;
      finishName = trip.stops.last.placeName;
    }
    // Fallback: use first/last location points coords as label
    if (startName == null && trip.locationPoints.isNotEmpty) {
      final p = trip.locationPoints.first;
      startName = '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';
    }
    if (finishName == null && trip.locationPoints.length > 1) {
      final p = trip.locationPoints.last;
      finishName = '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';
    }

    // Places from stops with names
    final places = trip.stops
        .where((s) => s.placeName != null && s.placeName!.isNotEmpty)
        .map((s) => StoryPlace(
              name: s.placeName!,
              time: s.arrivalTime,
              durationMinutes: s.durationSeconds ~/ 60,
            ))
        .toList();

    // Build timeline: start + stops + photos (sorted by time) + end
    final rawEntries = <StoryTimelineEntry>[
      StoryTimelineEntry(
        time: trip.startedAt,
        label: 'Perjalanan dimulai',
        isStop: false,
      ),
      ...trip.stops.map((s) => StoryTimelineEntry(
            time: s.arrivalTime,
            label: s.placeName ?? 'Pemberhentian (${s.durationSeconds ~/ 60}m)',
            isStop: true,
          )),
      ...photos.map((p) => StoryTimelineEntry(
            time: p.timestamp,
            label: p.caption ?? 'Foto',
            isPhoto: true,
          )),
      if (trip.endedAt != null)
        StoryTimelineEntry(
          time: trip.endedAt!,
          label: 'Perjalanan selesai',
          isStop: false,
        ),
    ];

    // Sort by time
    rawEntries.sort((a, b) => a.time.compareTo(b.time));

    return StoryModel(
      tripId: trip.id,
      title: title,
      date: date,
      route: route,
      distanceMeters: trip.distanceMeters,
      durationSeconds: trip.durationSeconds,
      averageSpeedKmh: avgSpeed,
      elevationGainMeters: trip.elevationGainMeters,
      elevationLossMeters: trip.elevationLossMeters,
      startLocationName: startName,
      finishLocationName: finishName,
      places: places,
      timeline: rawEntries,
      backgroundImagePath: trip.storyBackgroundImagePath,
      routePoints: trip.locationPoints
          .map((p) => RoutePoint(p.latitude, p.longitude))
          .toList(),
      photos: photos,
    );
  }
}

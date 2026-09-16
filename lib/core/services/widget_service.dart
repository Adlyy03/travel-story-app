import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../shared/models/location_point.dart';
import '../../shared/models/trip.dart';

class WidgetService {
  static const String _androidWidgetName = 'LiveTripWidgetProvider';

  static Future<void> updateLiveTripWidget({
    required Trip? trip,
    LocationPoint? currentPoint,
  }) async {
    try {
      if (trip == null || trip.status == TripStatus.completed) {
        await clearLiveTripWidget();
        return;
      }

      final isPaused = trip.status == TripStatus.paused;
      final statusText = isPaused ? 'ISTIRAHAT' : 'PERJALANAN AKTIF';
      final duration = _formatDuration(trip.startedAt);
      final distance = _formatDistance(trip.distanceMeters ?? 0.0);
      final locationText = isPaused
          ? 'Lokasi: Istirahat / Paused'
          : (currentPoint != null
              ? 'Lokasi: ${currentPoint.latitude.toStringAsFixed(4)}, ${currentPoint.longitude.toStringAsFixed(4)}'
              : 'Lokasi: Merekam GPS...');

      await HomeWidget.saveWidgetData<bool>('is_tracking', true);
      await HomeWidget.saveWidgetData<String>('status_text', statusText);
      await HomeWidget.saveWidgetData<String>('duration', duration);
      await HomeWidget.saveWidgetData<String>('distance', distance);
      await HomeWidget.saveWidgetData<String>('location', locationText);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
        qualifiedAndroidName: 'com.example.travel_story.LiveTripWidgetProvider',
      );
    } catch (e) {
      debugPrint('WidgetService updateLiveTripWidget error: $e');
    }
  }

  static Future<void> clearLiveTripWidget() async {
    try {
      await HomeWidget.saveWidgetData<bool>('is_tracking', false);
      await HomeWidget.saveWidgetData<String>('status_text', 'TIDAK AKTIF');
      await HomeWidget.saveWidgetData<String>('duration', '--:--');
      await HomeWidget.saveWidgetData<String>('distance', '0.0 km');
      await HomeWidget.saveWidgetData<String>('location', 'Lokasi: Tidak aktif');

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
        qualifiedAndroidName: 'com.example.travel_story.LiveTripWidgetProvider',
      );
    } catch (e) {
      debugPrint('WidgetService clearLiveTripWidget error: $e');
    }
  }

  static String _formatDuration(DateTime start) {
    final d = DateTime.now().difference(start);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  static String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }
}

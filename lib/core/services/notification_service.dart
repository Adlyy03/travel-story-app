import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/models/trip.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await requestPermissions();

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('NotificationService requestPermissions error: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final route = data['route'] as String?;
      final tripId = data['tripId'] as String?;

      if (route != null && tripId != null) {
        navigatorKey.currentState?.pushNamed(route, arguments: tripId);
      }
    } catch (_) {
      navigatorKey.currentState
          ?.pushNamed('/trip/detail', arguments: payload);
    }
  }

  int _getTrackingReminderId(String tripId) {
    return (tripId.hashCode.abs() % 100000) + 10000;
  }

  int _getStoryReminderId(String tripId) {
    return (tripId.hashCode.abs() % 100000) + 20000;
  }

  // 1. Tracking selesai — otomatis
  Future<void> showTripCompletedNotification(Trip trip) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'trip_completed_channel',
        'Perjalanan Selesai',
        channelDescription: 'Notifikasi saat perjalanan selesai direkam',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      final payload = jsonEncode({
        'route': '/trip/detail',
        'tripId': trip.id,
      });

      await _notificationsPlugin.show(
        id: 0,
        title: 'Perjalanan Selesai 🚗',
        body: 'Perjalanan selesai! Lihat kembali rute dan Story-mu.',
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('showTripCompletedNotification error: $e');
    }
  }

  // 2. Reminder lanjut tracking (30 menit setelah aktif)
  Future<void> scheduleTrackingReminderNotification(
    String tripId, {
    Duration delay = const Duration(minutes: 30),
  }) async {
    try {
      final notificationId = _getTrackingReminderId(tripId);

      await _notificationsPlugin.cancel(id: notificationId);

      const androidDetails = AndroidNotificationDetails(
        'tracking_reminder_channel',
        'Reminder Lanjut Tracking',
        channelDescription:
            'Pengingat untuk melanjut/menyelesaikan perjalanan',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

      final payload = jsonEncode({
        'route': '/',
        'tripId': tripId,
      });

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Perjalanan Masih Berlangsung ⏱️',
        body:
            'Kamu sedang dalam perjalanan. Jangan lupa selesaikan atau cek rutemu.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('scheduleTrackingReminderNotification error: $e');
    }
  }

  Future<void> cancelTrackingReminderNotification(String tripId) async {
    try {
      final notificationId = _getTrackingReminderId(tripId);
      await _notificationsPlugin.cancel(id: notificationId);
    } catch (e) {
      debugPrint('cancelTrackingReminderNotification error: $e');
    }
  }

  // 3. Reminder buat Story (24 jam setelah selesai)
  Future<void> scheduleCreateStoryReminderNotification(
    String tripId, {
    Duration delay = const Duration(hours: 24),
  }) async {
    try {
      final notificationId = _getStoryReminderId(tripId);

      await _notificationsPlugin.cancel(id: notificationId);

      const androidDetails = AndroidNotificationDetails(
        'story_reminder_channel',
        'Reminder Buat Story',
        channelDescription:
            'Pengingat membuat Story dari perjalanan yang selesai',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

      final payload = jsonEncode({
        'route': '/trip/detail',
        'tripId': tripId,
      });

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Buat Story Perjalananmu 📖',
        body:
            'Perjalanan kemarin belum dibuatkan Story! Abadikan momenmu sekarang.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('scheduleCreateStoryReminderNotification error: $e');
    }
  }

  Future<void> cancelCreateStoryReminderNotification(String tripId) async {
    try {
      final notificationId = _getStoryReminderId(tripId);
      await _notificationsPlugin.cancel(id: notificationId);
    } catch (e) {
      debugPrint('cancelCreateStoryReminderNotification error: $e');
    }
  }
}

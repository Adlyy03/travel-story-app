import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/sync_service.dart';
import 'core/debug/seed_dummy_trip.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  SyncService.instance.init();
  // TODO: Remove after seed — one-time dummy data injection
  await SeedDummyTrip.seed();
  runApp(const TravelStoryApp());
}

import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

class TravelStoryApp extends StatelessWidget {
  const TravelStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      title: 'Travel Story',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/splash',
      routes: AppRoutes.routes,
    );
  }
}
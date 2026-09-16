import 'package:flutter/material.dart';

import '../features/splash/splash_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/trip/trip_detail_page.dart';
import '../features/trip/trip_map_page.dart';
import '../features/trip/trip_form_page.dart';
import '../features/trip/trip_completed_page.dart';
import '../features/story/presentation/story_preview_page.dart';
import '../features/story/presentation/story_export_page.dart';
import '../features/story/presentation/story_editor_page.dart';
import '../features/story/presentation/story_animated_player.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/splash': (context) => const SplashScreen(),
    '/': (context) => const MainShell(),
    '/trip/detail': (context) => const TripDetailPage(),
    '/trip/map': (context) => const TripMapPage(),
    '/trip/form': (context) {
      final trip = ModalRoute.of(context)?.settings.arguments;
      return TripFormPage(trip: trip as dynamic);
    },
    '/trip/completed': (context) => const TripCompletedPage(),
    '/story/preview': (context) => const StoryPreviewPage(),
    '/story/export': (context) => const StoryExportPage(),
    '/story/editor': (context) => const StoryEditorPage(),
    '/story/player': (context) => const StoryAnimatedPlayer(),
  };
}

# Graph Report - travel_story  (2026-09-09)

## Corpus Check
- 107 files · ~134,681 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1234 nodes · 1629 edges · 82 communities (74 shown, 8 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Win32Window
- GeneratedPluginRegistrant.swift
- sync_service.dart
- story_renderer.dart
- story_preview_page.dart
- main_shell.dart
- home_page.dart
- tracking_service.dart
- trip_calculator_test.dart
- trips_tab.dart
- trip_detail_page.dart
- home_tab.dart
- my_application.cc
- sync_status_badge.dart
- story_model.dart
- trip.dart
- memories_tab.dart
- trip_map_page.dart
- location_service.dart
- trip_form_page.dart
- trip_repository.dart
- trip_engine.dart
- Day 26-30: Final Polish & Release
- live_trip_sheet.dart
- place_service.dart
- SKILL.md
- location_point.dart
- wWinMain
- gps_cleaner.dart
- stop.dart
- story_editor_page.dart
- elevation_calculator.dart
- stop_detector.dart
- trip_completed_page.dart
- manifest.json
- DESIGN.md — Travel Story (Minimalism)
- widget_service.dart
- story_animated_player.dart
- ../../shared/models/location_point.dart
- route_smoother.dart
- State
- MainActivity.kt
- Development Environment
- travel_story
- rules/graphify.md
- workflows/graphify.md
- LaunchImage.imageset/README.md
- String?
- notification_service.dart
- package:flutter/material.dart
- app_database.dart
- ../../core/theme/app_colors.dart
- story_share_service.dart
- StatelessWidget
- splash_screen.dart
- story_export_page.dart
- LiveTripWidgetProvider.kt
- trip_photo.dart
- _StoryAnimatedPlayerState
- Route /trip/form
- gps_cleaner_test.dart
- edge_case_tests.dart
- story_template.dart
- widget_test.dart
- SingleTickerProviderStateMixin
- _TripsTabState

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 24 edges
2. `TripRepository` - 13 edges
3. `MessageHandler` - 12 edges
4. `Trip` - 10 edges
5. `FlutterWindow` - 10 edges
6. `Create` - 10 edges
7. `WndProc` - 10 edges
8. `MessageHandler` - 9 edges
9. `DESIGN.md — Travel Story (Minimalism)` - 9 edges
10. `_MyApplication` - 7 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.h → windows/flutter/generated_plugin_registrant.cc

## Import Cycles
- None detected.

## Communities (82 total, 8 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.05
Nodes (57): PluginRegistry, RECT, unique_ptr, RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT (+49 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (34): Any, Cocoa, file_picker_darwin, file_selector_macos, Flutter, flutter_local_notifications, FlutterAppDelegate, FlutterImplicitEngineBridge (+26 more)

### Community 2 - "sync_service.dart"
Cohesion: 0.11
Nodes (17): ../../features/trip/data/trip_repository.dart, _backendEndpoint, _checkInternetConnection, _connectivityTimer, dispose, init, instance, _isOnline (+9 more)

### Community 3 - "story_renderer.dart"
Cohesion: 0.05
Nodes (40): dart:ui, domain/story_template.dart, accent, accentCyan, _alignOffset, canvasHeight, canvasWidth, _drawBackgroundImage (+32 more)

### Community 4 - "story_preview_page.dart"
Cohesion: 0.10
Nodes (20): createState, _customBackgroundPath, didChangeDependencies, _error, icon, _imageBytes, initState, _isRendering (+12 more)

### Community 5 - "main_shell.dart"
Cohesion: 0.08
Nodes (25): ../../core/services/location_service.dart, ../home/home_tab.dart, activeIcon, build, children, createState, _currentIndex, _handleCenterStartTrip (+17 more)

### Community 6 - "home_page.dart"
Cohesion: 0.05
Nodes (40): ../../core/services/elevation_calculator.dart, ../../core/services/gps_cleaner.dart, ../../core/services/stop_detector.dart, ../../core/services/trip_calculator.dart, ../../core/services/trip_engine.dart, ../../features/trip/data/trip_local_data_source.dart, TrackingService, createTrip (+32 more)

### Community 7 - "tracking_service.dart"
Cohesion: 0.05
Nodes (36): _activeTrip, activeTripNotifier, _buffer, _captureLocation, dispose, getActiveTrip, _gpsCleaner, instance (+28 more)

### Community 8 - "trip_calculator_test.dart"
Cohesion: 0.18
Nodes (10): TripCalculator, package:travel_story/core/services/trip_calculator.dart, calculator, _counter, lat, lon, main, _point (+2 more)

### Community 9 - "trips_tab.dart"
Cohesion: 0.10
Nodes (19): _buildError, createState, _deleteAllTrips, _deleteSingleTrip, didChangeDependencies, _error, _formatDistance, _formatDuration (+11 more)

### Community 10 - "trip_detail_page.dart"
Cohesion: 0.09
Nodes (22): ../../features/story/domain/story_builder.dart, _buildHeader, _buildStatItem, _buildStats, _buildStops, createState, _deleteTrip, didChangeDependencies (+14 more)

### Community 11 - "home_tab.dart"
Cohesion: 0.07
Nodes (27): ../../features/trip/live_trip_sheet.dart, build, _buildError, _buildMulaiButtonCard, _buildTimeframeSelector, _buildUserStats, _completedTrips, createState (+19 more)

### Community 12 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 13 - "sync_status_badge.dart"
Cohesion: 0.17
Nodes (11): IconData, SyncState, backgroundColor, _BadgeConfig, borderColor, build, _getBadgeConfig, icon (+3 more)

### Community 14 - "story_model.dart"
Cohesion: 0.06
Nodes (34): averageSpeedKmh, backgroundImagePath, copyWith, date, distanceMeters, durationMinutes, durationSeconds, elevationGainMeters (+26 more)

### Community 15 - "trip.dart"
Cohesion: 0.08
Nodes (25): int?, copyWith, distanceMeters, durationSeconds, elevationGainMeters, elevationLossMeters, endedAt, fromMap (+17 more)

### Community 16 - "memories_tab.dart"
Cohesion: 0.06
Nodes (35): _createStory, _openStory, build, _buildEmpty, _buildStory, createState, didChangeDependencies, _error (+27 more)

### Community 17 - "trip_map_page.dart"
Cohesion: 0.07
Nodes (27): ../../core/services/route_smoother.dart, build, _center, createState, didChangeDependencies, dispose, _formatDistance, _formatDuration (+19 more)

### Community 18 - "location_service.dart"
Cohesion: 0.11
Nodes (17): bool get, checkPermission, getCurrentPosition, getLastKnownPosition, isTracking, LocationPermissionStatus, LocationService, _locationSettings (+9 more)

### Community 19 - "trip_form_page.dart"
Cohesion: 0.08
Nodes (23): data/trip_local_data_source.dart, data/trip_repository.dart, ../database/app_database.dart, FormState, seed, SeedDummyTrip, build, createState (+15 more)

### Community 20 - "trip_repository.dart"
Cohesion: 0.04
Nodes (45): ../../../core/database/app_database.dart, build, StoryBuilder, createTrip, deleteAllTrips, deleteTrip, deleteTripPhoto, getActiveTrip (+37 more)

### Community 21 - "trip_engine.dart"
Cohesion: 0.18
Nodes (10): elevation_calculator.dart, gps_cleaner.dart, _calculator, _cleaner, _elevationCalculator, processLocationPoints, processTrip, _stopDetector (+2 more)

### Community 22 - "Day 26-30: Final Polish & Release"
Cohesion: 0.13
Nodes (14): Battery Optimization, Build APK, Current Status, Day 26-30: Final Polish & Release, Day 26: Edge Cases ✅, Day 27: Real World Test, Day 28: Battery & Privacy, Day 29: UI Polish (+6 more)

### Community 23 - "live_trip_sheet.dart"
Cohesion: 0.12
Nodes (16): ../../core/services/tracking_service.dart, build, createState, dispose, _formatDistance, _formatDuration, _formatTime, initState (+8 more)

### Community 24 - "place_service.dart"
Cohesion: 0.13
Nodes (14): dart:convert, _cache, category, clearCache, displayName, _nominatimBase, PlaceInfo, PlaceService (+6 more)

### Community 25 - "SKILL.md"
Cohesion: 0.17
Nodes (10): caveman, Example output, How to invoke, See also, What it does, Auto-Clarity, Boundaries, Intensity (+2 more)

### Community 26 - "location_point.dart"
Cohesion: 0.17
Nodes (11): double?, accuracy, altitude, fromMap, id, latitude, LocationPoint, longitude (+3 more)

### Community 27 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 28 - "gps_cleaner.dart"
Cohesion: 0.14
Nodes (13): calculateDistance, clean, _isDuplicate, _isImpossibleMovement, isPointValid, isSignificantMovement, _isValidAccuracy, _isValidCoordinate (+5 more)

### Community 29 - "stop.dart"
Cohesion: 0.15
Nodes (12): DateTime, arrivalTime, departureTime, durationSeconds, fromMap, id, latitude, longitude (+4 more)

### Community 30 - "story_editor_page.dart"
Cohesion: 0.05
Nodes (37): _addPhoto, build, _buildBottomBar, _buildPreviewCard, bytes, color, createState, didChangeDependencies (+29 more)

### Community 31 - "elevation_calculator.dart"
Cohesion: 0.18
Nodes (10): calculate, ElevationCalculator, ElevationMetrics, gain, highest, loss, lowest, _minAltitudeDiff (+2 more)

### Community 32 - "stop_detector.dart"
Cohesion: 0.18
Nodes (10): _calculateDistance, _createStop, detectStops, _isWithinRadius, _minStopDuration, _movementRadiusMeters, StopDetector, _toRadians (+2 more)

### Community 33 - "trip_completed_page.dart"
Cohesion: 0.06
Nodes (32): CustomPainter, _AnimatedRoutePainter, _animCtrl, build, _buildContent, _buildError, _buildStatsGrid, createState (+24 more)

### Community 34 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 35 - "DESIGN.md — Travel Story (Minimalism)"
Cohesion: 0.20
Nodes (9): 1. PRINSIP, 2. COLOR TOKENS, 3. TYPOGRAPHY, 4. SPACING & RADIUS, 5. COMPONENTS, 6. ICONOGRAPHY, 7. MOTION, 8. CHECKLIST SEBELUM SELESAI STYLING (+1 more)

### Community 36 - "widget_service.dart"
Cohesion: 0.22
Nodes (8): _androidWidgetName, clearLiveTripWidget, _formatDistance, _formatDuration, updateLiveTripWidget, WidgetService, package:flutter/foundation.dart, package:home_widget/home_widget.dart

### Community 37 - "story_animated_player.dart"
Cohesion: 0.05
Nodes (42): build, _buildCoverScene, _buildPhotosScene, _buildRouteScene, _buildSegmentedProgressBar, _buildStatsScene, _buildSummaryScene, _buildVideoContent (+34 more)

### Community 38 - "../../shared/models/location_point.dart"
Cohesion: 0.29
Nodes (6): dart:math, calculateDistance, calculateDuration, _haversineDistance, _toRadians, ../../shared/models/location_point.dart

### Community 39 - "route_smoother.dart"
Cohesion: 0.09
Nodes (21): LatLng, calculateBearing, calculateDistance, extractTurnArrows, _fetchMapMatching, _fetchRouteForWaypoints, _filterGpsNoise, heading (+13 more)

### Community 40 - "State"
Cohesion: 0.16
Nodes (18): HomePage, _HomePageState, HomeTab, _HomeTabState, _CenterNavActionItem, _CenterNavActionItemState, MainShell, _MainShellState (+10 more)

### Community 64 - "notification_service.dart"
Cohesion: 0.07
Nodes (26): FlutterLocalNotificationsPlugin, GlobalKey, cancelCreateStoryReminderNotification, cancelTrackingReminderNotification, _getStoryReminderId, _getTrackingReminderId, init, instance (+18 more)

### Community 65 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (40): app/app.dart, app_colors.dart, core/debug/seed_dummy_trip.dart, core/services/notification_service.dart, ../../core/services/sync_service.dart, ../core/theme/app_theme.dart, ../features/shell/main_shell.dart, ../features/splash/splash_screen.dart (+32 more)

### Community 66 - "app_database.dart"
Cohesion: 0.15
Nodes (12): AppDatabase, close, _database, _databaseName, _databaseVersion, _initDatabase, _onCreate, _onUpgrade (+4 more)

### Community 67 - "../../core/theme/app_colors.dart"
Cohesion: 0.14
Nodes (13): ../../core/theme/app_colors.dart, ../../dev/seed_dummy_trip.dart, build, icon, label, onTap, ProfileTab, _SectionLabel (+5 more)

### Community 68 - "story_share_service.dart"
Cohesion: 0.12
Nodes (18): dart:io, domain/story_model.dart, cleanup, exportImage, _filename, _render, renderBytes, StoryExporter (+10 more)

### Community 69 - "StatelessWidget"
Cohesion: 0.12
Nodes (16): _StoryCard, _AnimatedPageStack, _MinimalNavBar, _NavItem, _StatHeroCard, _FullscreenPreview, _PhotosTab, _PreviewActionButton (+8 more)

### Community 70 - "splash_screen.dart"
Cohesion: 0.17
Nodes (11): Animation, AnimationController, dart:async, build, _controller, createState, dispose, _fadeAnimation (+3 more)

### Community 71 - "story_export_page.dart"
Cohesion: 0.13
Nodes (14): dart:typed_data, StoryModel, build, _bytes, createState, didChangeDependencies, _error, _generateFilename (+6 more)

### Community 72 - "LiveTripWidgetProvider.kt"
Cohesion: 0.33
Nodes (7): LiveTripWidgetProvider, AppWidgetManager, Color, Context, HomeWidgetProvider, IntArray, SharedPreferences

### Community 73 - "trip_photo.dart"
Cohesion: 0.17
Nodes (11): caption, copyWith, fromMap, id, latitude, longitude, path, timestamp (+3 more)

### Community 75 - "Route /trip/form"
Cohesion: 0.25
Nodes (8): _buildTripList, build, _buildActions, build, _buildEmpty, _buildList, Route /trip/form, Route /trip/map

### Community 76 - "gps_cleaner_test.dart"
Cohesion: 0.20
Nodes (9): GpsCleaner, accuracy, cleaner, _counter, lat, lon, main, _point (+1 more)

### Community 77 - "edge_case_tests.dart"
Cohesion: 0.22
Nodes (8): TripEngine, package:travel_story/core/services/elevation_calculator.dart, package:travel_story/core/services/gps_cleaner.dart, package:travel_story/core/services/stop_detector.dart, package:travel_story/core/services/trip_engine.dart, package:travel_story/shared/models/location_point.dart, engine, main

### Community 78 - "story_template.dart"
Cohesion: 0.50
Nodes (3): journal, StoryTemplate, minimal,
  glass,
  cinematic,
  strava,

### Community 79 - "widget_test.dart"
Cohesion: 0.33
Nodes (5): package:flutter/services.dart, package:flutter_test/flutter_test.dart, package:sqflite/sqflite.dart, package:travel_story/app/app.dart, main

### Community 80 - "SingleTickerProviderStateMixin"
Cohesion: 0.40
Nodes (5): SplashScreen, _SplashScreenState, TripMapPage, _TripMapPageState, SingleTickerProviderStateMixin

### Community 81 - "_TripsTabState"
Cohesion: 0.67
Nodes (3): AutomaticKeepAliveClientMixin, TripsTab, _TripsTabState

## Knowledge Gaps
- **750 isolated node(s):** `build`, `AppRoutes`, `routes`, `AppDatabase`, `_database` (+745 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TripRepository` connect `trip_repository.dart` to `trip_completed_page.dart`, `sync_service.dart`, `story_preview_page.dart`, `home_page.dart`, `tracking_service.dart`, `trips_tab.dart`, `trip_detail_page.dart`, `home_tab.dart`, `memories_tab.dart`, `trip_map_page.dart`, `trip_form_page.dart`, `story_editor_page.dart`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Why does `Trip` connect `trip_form_page.dart` to `trip_completed_page.dart`, `home_page.dart`, `tracking_service.dart`, `trips_tab.dart`, `trip_detail_page.dart`, `home_tab.dart`, `trip.dart`, `memories_tab.dart`, `trip_map_page.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `StoryModel` connect `story_export_page.dart` to `story_preview_page.dart`, `story_animated_player.dart`, `story_model.dart`, `story_editor_page.dart`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **What connects `build`, `AppRoutes`, `routes` to the rest of the system?**
  _750 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.05311676909569798 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04964539007092199 - nodes in this community are weakly interconnected._
- **Should `sync_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
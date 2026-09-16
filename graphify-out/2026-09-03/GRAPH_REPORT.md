# Graph Report - travel_story  (2026-09-03)

## Corpus Check
- 100 files · ~120,111 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 971 nodes · 1258 edges · 66 communities (59 shown, 7 thin omitted)
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
- gps_cleaner_test.dart
- trips_tab.dart
- trip_detail_page.dart
- home_tab.dart
- my_application.cc
- package:flutter/material.dart
- story_model.dart
- trip.dart
- memories_tab.dart
- trip_map_page.dart
- location_service.dart
- trip_form_page.dart
- trip_local_data_source.dart
- trip_engine.dart
- Day 26-30: Final Polish & Release
- live_trip_sheet.dart
- app_database.dart
- SKILL.md
- location_point.dart
- wWinMain
- gps_cleaner.dart
- stop.dart
- trip_repository.dart
- elevation_calculator.dart
- stop_detector.dart
- ../../shared/models/trip.dart
- manifest.json
- DESIGN.md — Travel Story (Minimalism)
- ../../shared/models/location_point.dart
- LiveTripWidgetProvider.kt
- trip_calculator.dart
- Route /story/preview
- MainActivity.kt
- Development Environment
- travel_story
- rules/graphify.md
- workflows/graphify.md
- LaunchImage.imageset/README.md
- String?
- notification_service.dart
- profile_tab.dart
- StatelessWidget

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 24 edges
2. `MessageHandler` - 12 edges
3. `TripRepository` - 11 edges
4. `FlutterWindow` - 10 edges
5. `Create` - 10 edges
6. `WndProc` - 10 edges
7. `Trip` - 9 edges
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

## Communities (66 total, 7 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.05
Nodes (57): PluginRegistry, RECT, unique_ptr, RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT (+49 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (34): Any, Cocoa, file_picker_darwin, file_selector_macos, Flutter, flutter_local_notifications, FlutterAppDelegate, FlutterImplicitEngineBridge (+26 more)

### Community 2 - "sync_service.dart"
Cohesion: 0.05
Nodes (41): dart:convert, ../../features/trip/data/trip_local_data_source.dart, ../../features/trip/data/trip_repository.dart, _cache, category, clearCache, displayName, _nominatimBase (+33 more)

### Community 3 - "story_renderer.dart"
Cohesion: 0.05
Nodes (37): dart:ui, accent, accentSoft, AppColors, background, bg, border, danger (+29 more)

### Community 4 - "story_preview_page.dart"
Cohesion: 0.05
Nodes (39): dart:typed_data, domain/story_model.dart, StoryModel, build, _bytes, createState, didChangeDependencies, _error (+31 more)

### Community 5 - "main_shell.dart"
Cohesion: 0.09
Nodes (21): ../../core/services/location_service.dart, ../home/home_tab.dart, activeIcon, build, createState, _currentIndex, _handleCenterStartTrip, icon (+13 more)

### Community 6 - "home_page.dart"
Cohesion: 0.06
Nodes (37): ../../core/import/gpx_parser.dart, ../../core/services/elevation_calculator.dart, ../../core/services/gps_cleaner.dart, ../../core/services/stop_detector.dart, ../../core/services/trip_calculator.dart, ../../core/services/trip_engine.dart, dart:io, TrackingService (+29 more)

### Community 7 - "tracking_service.dart"
Cohesion: 0.06
Nodes (34): _activeTrip, activeTripNotifier, _buffer, _captureLocation, _cleanBatchSize, dispose, getActiveTrip, _gpsCleaner (+26 more)

### Community 8 - "gps_cleaner_test.dart"
Cohesion: 0.07
Nodes (29): GpsCleaner, TripEngine, package:flutter_test/flutter_test.dart, package:travel_story/core/services/elevation_calculator.dart, package:travel_story/core/services/gps_cleaner.dart, package:travel_story/core/services/stop_detector.dart, package:travel_story/core/services/trip_calculator.dart, package:travel_story/core/services/trip_engine.dart (+21 more)

### Community 9 - "trips_tab.dart"
Cohesion: 0.07
Nodes (31): _onNotificationTapped, _buildTodayJourney, _buildTripList, _buildTodayJourney, _buildGrid, build, build, build (+23 more)

### Community 10 - "trip_detail_page.dart"
Cohesion: 0.09
Nodes (22): ../../features/story/domain/story_builder.dart, _buildMetadata, _buildMetadataRow, _buildStops, _buildTimeline, createState, _deleteTrip, didChangeDependencies (+14 more)

### Community 11 - "home_tab.dart"
Cohesion: 0.07
Nodes (28): ../../features/trip/live_trip_sheet.dart, _buildError, _buildMulaiButtonCard, _buildTimeframeSelector, _buildUserStats, _completedTrips, createState, dispose (+20 more)

### Community 12 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 13 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (34): app/app.dart, app_colors.dart, core/services/notification_service.dart, ../../core/services/sync_service.dart, ../core/theme/app_theme.dart, ../features/import/import_page.dart, ../features/shell/main_shell.dart, ../features/splash/splash_screen.dart (+26 more)

### Community 14 - "story_model.dart"
Cohesion: 0.08
Nodes (23): int?, backgroundImagePath, date, distanceMeters, durationMinutes, durationSeconds, elevationGainMeters, isStop (+15 more)

### Community 15 - "trip.dart"
Cohesion: 0.09
Nodes (22): copyWith, distanceMeters, durationSeconds, elevationGainMeters, elevationLossMeters, endedAt, fromMap, highestAltitude (+14 more)

### Community 16 - "memories_tab.dart"
Cohesion: 0.12
Nodes (16): build, _buildEmpty, createState, _error, _formatDistance, _formatDuration, initState, _isLoading (+8 more)

### Community 17 - "trip_map_page.dart"
Cohesion: 0.11
Nodes (17): build, _center, createState, didChangeDependencies, _formatDistance, _formatDuration, _infoRow, initState (+9 more)

### Community 18 - "location_service.dart"
Cohesion: 0.12
Nodes (16): bool get, checkPermission, getCurrentPosition, isTracking, LocationPermissionStatus, LocationService, _locationSettings, openAppSettings (+8 more)

### Community 19 - "trip_form_page.dart"
Cohesion: 0.12
Nodes (17): data/trip_local_data_source.dart, data/trip_repository.dart, FormState, TripRepository, build, createState, dispose, _formKey (+9 more)

### Community 20 - "trip_local_data_source.dart"
Cohesion: 0.12
Nodes (16): ../../../core/database/app_database.dart, createTrip, deleteAllTrips, deleteTrip, getActiveTrip, getAllTrips, getLocationPointsByTripId, getStopsByTripId (+8 more)

### Community 21 - "trip_engine.dart"
Cohesion: 0.20
Nodes (9): elevation_calculator.dart, gps_cleaner.dart, _calculator, _cleaner, _elevationCalculator, processTrip, _stopDetector, stop_detector.dart (+1 more)

### Community 22 - "Day 26-30: Final Polish & Release"
Cohesion: 0.13
Nodes (14): Battery Optimization, Build APK, Current Status, Day 26-30: Final Polish & Release, Day 26: Edge Cases ✅, Day 27: Real World Test, Day 28: Battery & Privacy, Day 29: UI Polish (+6 more)

### Community 23 - "live_trip_sheet.dart"
Cohesion: 0.06
Nodes (42): Animation, AnimationController, ../../core/services/tracking_service.dart, dart:async, HomePage, _HomePageState, ImportPage, _ImportPageState (+34 more)

### Community 24 - "app_database.dart"
Cohesion: 0.15
Nodes (12): AppDatabase, close, _database, _databaseName, _databaseVersion, _initDatabase, _onCreate, _onUpgrade (+4 more)

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
Cohesion: 0.15
Nodes (12): calculateDistance, clean, _isDuplicate, isPointValid, isSignificantMovement, _isValidAccuracy, _isValidCoordinate, _isValidTimestamp (+4 more)

### Community 29 - "stop.dart"
Cohesion: 0.15
Nodes (12): DateTime, arrivalTime, departureTime, durationSeconds, fromMap, id, latitude, longitude (+4 more)

### Community 30 - "trip_repository.dart"
Cohesion: 0.12
Nodes (16): addLocationPoint, addStop, createTrip, deleteAllTrips, deleteTrip, getActiveTrip, getAllTrips, getLocationPoints (+8 more)

### Community 31 - "elevation_calculator.dart"
Cohesion: 0.18
Nodes (10): calculate, ElevationCalculator, ElevationMetrics, gain, highest, loss, lowest, _minAltitudeDiff (+2 more)

### Community 32 - "stop_detector.dart"
Cohesion: 0.18
Nodes (10): _calculateDistance, _createStop, detectStops, _isWithinRadius, _minStopDuration, _movementRadiusMeters, StopDetector, _toRadians (+2 more)

### Community 33 - "../../shared/models/trip.dart"
Cohesion: 0.33
Nodes (5): build, StoryBuilder, package:intl/intl.dart, ../../shared/models/trip.dart, story_model.dart

### Community 34 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 35 - "DESIGN.md — Travel Story (Minimalism)"
Cohesion: 0.20
Nodes (9): 1. PRINSIP, 2. COLOR TOKENS, 3. TYPOGRAPHY, 4. SPACING & RADIUS, 5. COMPONENTS, 6. ICONOGRAPHY, 7. MOTION, 8. CHECKLIST SEBELUM SELESAI STYLING (+1 more)

### Community 36 - "../../shared/models/location_point.dart"
Cohesion: 0.22
Nodes (8): journey_parser.dart, GpxParser, parse, _uuid, JourneyParser, parse, package:uuid/uuid.dart, ../../shared/models/location_point.dart

### Community 37 - "LiveTripWidgetProvider.kt"
Cohesion: 0.33
Nodes (7): LiveTripWidgetProvider, AppWidgetManager, Color, Context, HomeWidgetProvider, IntArray, SharedPreferences

### Community 38 - "trip_calculator.dart"
Cohesion: 0.29
Nodes (6): dart:math, calculateDistance, calculateDuration, _haversineDistance, _toRadians, TripCalculator

### Community 40 - "Route /story/preview"
Cohesion: 0.40
Nodes (5): _createStory, _openStory, _createStory, _createStory, Route /story/preview

### Community 64 - "notification_service.dart"
Cohesion: 0.09
Nodes (21): FlutterLocalNotificationsPlugin, GlobalKey, cancelCreateStoryReminderNotification, cancelTrackingReminderNotification, _getStoryReminderId, _getTrackingReminderId, init, instance (+13 more)

### Community 67 - "profile_tab.dart"
Cohesion: 0.15
Nodes (12): ../../core/theme/app_colors.dart, build, build, build, icon, label, onTap, trailing (+4 more)

### Community 69 - "StatelessWidget"
Cohesion: 0.20
Nodes (10): _MemoryCard, ProfileTab, _SectionLabel, _SettingItem, _CenterNavActionItem, _MinimalNavBar, _NavItem, _ActionButton (+2 more)

## Knowledge Gaps
- **538 isolated node(s):** `build`, `AppRoutes`, `routes`, `AppDatabase`, `_database` (+533 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TripRepository` connect `trip_form_page.dart` to `sync_service.dart`, `story_preview_page.dart`, `home_page.dart`, `tracking_service.dart`, `trips_tab.dart`, `trip_detail_page.dart`, `home_tab.dart`, `memories_tab.dart`, `trip_map_page.dart`, `trip_repository.dart`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Why does `Trip` connect `trip_form_page.dart` to `home_page.dart`, `tracking_service.dart`, `trips_tab.dart`, `trip_detail_page.dart`, `home_tab.dart`, `trip.dart`, `memories_tab.dart`, `trip_map_page.dart`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `GpsCleaner` connect `gps_cleaner_test.dart` to `gps_cleaner.dart`, `trip_engine.dart`, `tracking_service.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `build`, `AppRoutes`, `routes` to the rest of the system?**
  _538 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.05311676909569798 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04964539007092199 - nodes in this community are weakly interconnected._
- **Should `sync_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.048625792811839326 - nodes in this community are weakly interconnected._
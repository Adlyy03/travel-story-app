import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:travel_story/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    databaseFactory = databaseFactorySqflitePlugin;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.tekartik.sqflite'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return '/mock/databases';
        }
        if (methodCall.method == 'openDatabase') {
          return 1;
        }
        if (methodCall.method == 'query') {
          return [];
        }
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelStoryApp());
    expect(find.byType(TravelStoryApp), findsOneWidget);
  });
}

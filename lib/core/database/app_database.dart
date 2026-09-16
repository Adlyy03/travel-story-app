import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;
  static const String _databaseName = 'travel_story.db';
  static const int _databaseVersion = 6;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        title TEXT,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        status TEXT NOT NULL,
        distance_meters REAL,
        duration_seconds INTEGER,
        paused_duration_seconds INTEGER DEFAULT 0,
        elevation_gain_meters REAL,
        elevation_loss_meters REAL,
        highest_altitude REAL,
        lowest_altitude REAL,
        story_background_image_path TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        last_synced_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE location_points (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        accuracy REAL,
        altitude REAL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE stops (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        arrival_time TEXT NOT NULL,
        departure_time TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        duration_seconds INTEGER NOT NULL,
        place_id TEXT,
        place_name TEXT,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE trip_photos (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        path TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        caption TEXT,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_location_points_trip_id ON location_points (trip_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_location_points_timestamp ON location_points (timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_stops_trip_id ON stops (trip_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_trip_photos_trip_id ON trip_photos (trip_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_trips_sync_status ON trips (sync_status)
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE trips ADD COLUMN story_background_image_path TEXT');
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE trips ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'pending'");
      await db.execute('ALTER TABLE trips ADD COLUMN last_synced_at TEXT');
      await db.execute('CREATE INDEX idx_trips_sync_status ON trips (sync_status)');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE trips ADD COLUMN paused_duration_seconds INTEGER DEFAULT 0');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE trips ADD COLUMN title TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS trip_photos (
          id TEXT PRIMARY KEY,
          trip_id TEXT NOT NULL,
          path TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          latitude REAL,
          longitude REAL,
          caption TEXT,
          FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_trip_photos_trip_id ON trip_photos (trip_id)');
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

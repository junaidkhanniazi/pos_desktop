import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;
  final _logger = Logger();
  final _lock = Lock();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> get database async {
    return await _lock.synchronized(() async {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    });
  }

  // Retry logic for locked database
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 5,
    int baseDelay = 100,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if ((e.toString().contains('locked') ||
                e.toString().contains('database is locked')) &&
            attempt < maxRetries) {
          final delay = Duration(milliseconds: baseDelay * attempt);
          print(
            '🔄 Database locked, retrying in ${delay.inMilliseconds}ms (attempt $attempt/$maxRetries)',
          );
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Max retries exceeded for database operation');
  }

  Future<Database> _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    Directory posDesktopFolder = Directory(
      join(documentsDir.path, 'Pos_Desktop'),
    );

    if (!posDesktopFolder.existsSync()) {
      await posDesktopFolder.create(recursive: true);
      _logger.i('📁 Created Pos_Desktop folder: ${posDesktopFolder.path}');
    }

    final String path = join(posDesktopFolder.path, 'pos_system.db');
    _logger.i('💡 Initializing system DB at: $path');

    try {
      final db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: _createSystemTables,
          onUpgrade: _upgradeDatabase,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
            await db.execute('PRAGMA busy_timeout = 10000');
            await db.execute('PRAGMA journal_mode = WAL');
            await db.execute('PRAGMA synchronous = NORMAL');
          },
        ),
      );
      _logger.i('✅ System database initialized!');
      return db;
    } catch (e) {
      _logger.e('❌ Failed to initialize system DB: $e');
      rethrow;
    }
  }

  // ======================================================
  // MASTER DB (per Owner)
  // ======================================================
  Future<Database> openMasterDB(int ownerId, String ownerName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final posDesktopFolder = Directory(
        join(documentsDir.path, 'Pos_Desktop'),
      );
      final posDataFolder = join(posDesktopFolder.path, 'pos_data');
      final ownerFolder = join(posDataFolder, ownerName.toLowerCase());
      await Directory(ownerFolder).create(recursive: true);

      final masterPath = join(
        ownerFolder,
        '${ownerName.toLowerCase()}_master.db',
      );
      _logger.i('📂 Opening Master DB for $ownerName → $masterPath');

      final db = await databaseFactory.openDatabase(
        masterPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS stores (
                id INTEGER PRIMARY KEY,
                ownerId INTEGER,
                storeName TEXT,
                folderPath TEXT,
                dbPath TEXT,
                createdAt TEXT,
                updatedAt TEXT
              );
            ''');
            _logger.i('✅ Master DB created for $ownerName');
          },
        ),
      );
      return db;
    } catch (e) {
      _logger.e('❌ Failed to open Master DB for $ownerName: $e');
      rethrow;
    }
  }

  // ======================================================
  // STORE DB (per Store)
  // ======================================================
  Future<Database> openStoreDB(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
  ) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final posDesktopFolder = Directory(
        join(documentsDir.path, 'Pos_Desktop'),
      );
      final posDataFolder = join(posDesktopFolder.path, 'pos_data');
      final ownerFolder = join(posDataFolder, ownerName.toLowerCase());

      final safeStoreName = storeName.toLowerCase().replaceAll(' ', '_');
      final storeFolderPath = join(
        ownerFolder,
        '${ownerName.toLowerCase()}_$safeStoreName',
      );
      final storeFolder = Directory(storeFolderPath);

      if (!storeFolder.existsSync()) {
        await storeFolder.create(recursive: true);
        _logger.i('📁 Created new store folder: $storeFolderPath');
      }

      final dbPath = join(storeFolder.path, 'store.db');
      _logger.i('🏪 Opening store DB: $dbPath');

      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 2, // ⬅️ bumped version for sync columns
          onCreate: (db, _) async => createStoreTables(db),
          onUpgrade: (db, oldV, newV) async => upgradeStoreDb(db, oldV, newV),
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
            await db.execute('PRAGMA busy_timeout = 10000');
            await db.execute('PRAGMA journal_mode = WAL');
            await db.execute('PRAGMA synchronous = NORMAL');
          },
        ),
      );
      return db;
    } catch (e) {
      _logger.e('❌ Failed to open Store DB for $storeName: $e');
      rethrow;
    }
  }

  // ======================================================
  // STORE TABLES (Sync-ready)
  // ======================================================
  static Future<void> createStoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT NOT NULL,
        sku TEXT UNIQUE,
        price REAL NOT NULL,
        cost_price REAL,
        quantity INTEGER DEFAULT 0,
        barcode TEXT,
        image_url TEXT,
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL,
        payment_method TEXT,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        price REAL,
        total REAL,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        contact TEXT,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        note TEXT,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_push_at TEXT,
        last_pull_at TEXT
      );
    ''');
  }

  // ======================================================
  // STORE DB MIGRATION (add sync columns if missing)
  // ======================================================
  Future<bool> _columnExists(Database db, String table, String column) async {
    final res = await db.rawQuery('PRAGMA table_info($table)');
    for (final row in res) {
      if ((row['name'] as String).toLowerCase() == column.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  Future<void> _ensureSyncColumns(Database db, String table) async {
    if (!await _columnExists(db, table, 'is_synced')) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN is_synced INTEGER DEFAULT 0;',
      );
    }
    if (!await _columnExists(db, table, 'last_updated')) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN last_updated TEXT DEFAULT CURRENT_TIMESTAMP;',
      );
    }
  }

  Future<void> upgradeStoreDb(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      final tables = [
        'categories',
        'products',
        'sales',
        'sale_items',
        'suppliers',
        'customers',
        'expenses',
      ];
      for (final t in tables) {
        await _ensureSyncColumns(db, t);
      }
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_metadata (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          last_push_at TEXT,
          last_pull_at TEXT
        );
      ''');
    }
  }

  // ======================================================
  // SYSTEM TABLES (Super Admin / Owners)
  // ======================================================
  Future<void> _createSystemTables(Database db, int version) async {
    _logger.i('⚙️ Creating Super Admin & Core Tables...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS super_admin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS owners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        super_admin_id INTEGER,
        shop_name TEXT,
        owner_name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        contact TEXT,
        activation_code TEXT,
        status TEXT DEFAULT 'pending',
        is_active INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        subscription_plan TEXT,
        receipt_image TEXT,
        payment_date TEXT,
        subscription_amount REAL,
        subscription_start_date TEXT,
        subscription_end_date TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscription_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        duration_days INTEGER,
        price REAL,
        maxStores INTEGER,
        maxProducts INTEGER,
        maxCategories INTEGER,
        features TEXT
      );
    ''');

    _logger.i('✅ Core System Tables created successfully!');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    _logger.i('🔄 Upgrading system DB $oldVersion → $newVersion');
    try {
      if (oldVersion < 3) {
        await db.execute(
          'ALTER TABLE owners ADD COLUMN subscription_end_date TEXT;',
        );
        _logger.i('✅ Added subscription_end_date to owners');
      }
    } catch (e) {
      _logger.e('❌ Database upgrade failed: $e');
    }
  }

  // ======================================================
  // DEBUGGING HELPERS
  // ======================================================
  Future<void> debugStoreSchema(Database db) async {
    final tables = [
      'categories',
      'products',
      'sales',
      'sale_items',
      'suppliers',
      'customers',
      'expenses',
      'sync_metadata',
    ];
    print('🔎 === STORE DB SCHEMA ===');
    for (final t in tables) {
      try {
        final info = await db.rawQuery('PRAGMA table_info($t)');
        print('📋 $t:');
        for (final c in info) {
          print('   - ${c['name']} | ${c['type']}');
        }
      } catch (_) {
        print('   (not found)');
      }
    }
    print('==========================');
  }

  Future<void> close() async {
    await _lock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _logger.i('🔒 Database closed successfully');
      }
    });
  }

  Future<void> forceResetDatabase() async {
    await _lock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      final appDataDir = await getApplicationSupportDirectory();
      final posDesktopFolder = Directory(join(appDataDir.path, 'Pos_Desktop'));
      final String path = join(posDesktopFolder.path, 'pos_system.db');

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i('🗑️ Database file deleted to reset locks');
      }

      _database = await _initDatabase();
    });
  }
}

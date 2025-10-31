import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;
  final _logger = Logger();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    // Initialize sqflite ffi for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _debugTableStructure(Database db) async {
    try {
      print('🔍 === DEBUG: ACTUAL TABLE STRUCTURE ===');

      // Check subscription_plans table
      final subPlanInfo = await db.rawQuery(
        'PRAGMA table_info(subscription_plans)',
      );
      print('📋 subscription_plans columns:');
      for (final column in subPlanInfo) {
        print('   ${column['name']} | ${column['type']}');
      }

      // Check if any data exists
      final plansData = await db.query('subscription_plans');
      print('📊 Total plans in DB: ${plansData.length}');
      for (final plan in plansData) {
        print('   Plan: $plan');
      }

      print('========================================');
    } catch (e) {
      print('❌ Error in debug: $e');
    }
  }

  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'pos_system.db');
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
            await db.execute('PRAGMA busy_timeout = 5000');
          },
        ),
      );
      _logger.i('✅ System database initialized!');
      await _debugTableStructure(db);
      return db;
    } catch (e) {
      _logger.e('❌ Failed to initialize system DB: $e');
      rethrow;
    }
  }

  // ✅ Simple retry mechanism for database locking issues
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

  // -------------------------------------------------
  // 🔹 MASTER DB (per Owner)
  // -------------------------------------------------
  Future<Database> openMasterDB(int ownerId) async {
    try {
      final dbBase = await getDatabasesPath();
      final ownerFolder = join(dbBase, 'owner_$ownerId');
      await Directory(ownerFolder).create(recursive: true);

      final masterPath = join(ownerFolder, 'master.db');
      _logger.i('📂 Opening Master DB for Owner $ownerId → $masterPath');

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

            await db.execute('''
              CREATE TABLE IF NOT EXISTS subscription_info (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                planName TEXT,
                startDate TEXT,
                endDate TEXT,
                maxStores INTEGER,
                maxProducts INTEGER,
                maxCategories INTEGER
              );
            ''');

            _logger.i('✅ Master DB created for Owner $ownerId');
          },
        ),
      );

      return db;
    } catch (e) {
      _logger.e('❌ Failed to open Master DB for owner $ownerId: $e');
      rethrow;
    }
  }

  // -------------------------------------------------
  // 🔹 STORE DB (per Store)
  // -------------------------------------------------
  Future<Database> openStoreDB(
    int ownerId,
    int storeId,
    String storeName,
  ) async {
    try {
      final dbBase = await getDatabasesPath();
      final ownerFolder = join(dbBase, 'owner_$ownerId');
      final storeFolderPath = join(ownerFolder, 'store_${storeId}_$storeName');
      final storeFolder = Directory(storeFolderPath);

      // ✅ Auto-create store folder if it doesn't exist
      if (!storeFolder.existsSync()) {
        await storeFolder.create(recursive: true);
        _logger.i('📁 Created new store folder: $storeFolderPath');
      }

      final dbPath = join(storeFolder.path, '$storeName.db');
      _logger.i('🏪 Opening store DB: $dbPath');

      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async => createStoreTables(db),
        ),
      );

      return db;
    } catch (e) {
      _logger.e('❌ Failed to open Store DB for store_$storeId: $e');
      rethrow;
    }
  }

  // -------------------------------------------------
  // 🔹 STORE SCHEMA CREATION (per store)
  // -------------------------------------------------
  static Future<void> createStoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
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
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL,
        payment_method TEXT,
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
        total REAL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        contact TEXT,
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
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        note TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');
  }

  // -------------------------------------------------
  // 🔹 SYSTEM TABLES (Super Admin, Plans, Owners)
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 UPGRADE DB (System-level)
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 CLOSE DATABASE
  // -------------------------------------------------
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('🔒 Database closed successfully');
    }
  }
}

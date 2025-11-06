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
          version: 5, // ✅ CHANGED: Incremented to 5 for activation code removal
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
  // MASTER DB (per Owner) - UPDATED FOLDER STRUCTURE
  // ======================================================
  Future<Database> openMasterDB(int ownerId, String ownerName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final posDesktopFolder = Directory(
        join(documentsDir.path, 'Pos_Desktop'),
      );

      // ✅ FOLDER STRUCTURE: Pos_Desktop/owners/owner_name/
      final ownersFolder = join(posDesktopFolder.path, 'owners');
      final ownerFolder = join(ownersFolder, ownerName.toLowerCase());
      await Directory(ownerFolder).create(recursive: true);

      final masterPath = join(ownerFolder, 'master.db');
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
  // STORE DB (per Store) - UPDATED FOLDER STRUCTURE
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

      // ✅ FOLDER STRUCTURE: Pos_Desktop/owners/owner_name/stores/
      final ownersFolder = join(posDesktopFolder.path, 'owners');
      final ownerFolder = join(ownersFolder, ownerName.toLowerCase());
      final storesFolder = join(ownerFolder, 'stores');

      // Create stores folder if not exists
      if (!Directory(storesFolder).existsSync()) {
        await Directory(storesFolder).create(recursive: true);
        _logger.i('📁 Created stores folder: $storesFolder');
      }

      // ✅ DIRECT .db FILE: stores_folder/store_name.db
      final safeStoreName = storeName.toLowerCase().replaceAll(' ', '');
      final dbPath = join(storesFolder, '$safeStoreName.db');
      _logger.i('🏪 Opening store DB: $dbPath');

      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, _) async => createStoreTables(db),
          onUpgrade: (db, oldV, newV) async => upgradeStoreDb(db, oldV, newV),
          onOpen: (db) async {
            try {
              _logger.i('🧩 Verifying store DB schema...');
              await createStoreTables(db);
              _logger.i('✅ Store tables verified/created successfully');
            } catch (e) {
              _logger.e('❌ Failed verifying store tables: $e');
            }
          },
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
  // GET OWNER FOLDER PATH (Helper Method)
  // ======================================================
  Future<String> getOwnerFolderPath(String ownerName) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final posDesktopFolder = Directory(join(documentsDir.path, 'Pos_Desktop'));
    final ownersFolder = join(posDesktopFolder.path, 'owners');
    return join(ownersFolder, ownerName.toLowerCase());
  }

  // ======================================================
  // GET STORE FOLDER PATH (Helper Method)
  // ======================================================
  Future<String> getStoreDbPath(String ownerName, String storeName) async {
    final ownerFolder = await getOwnerFolderPath(ownerName);
    final storesFolder = join(ownerFolder, 'stores');
    final safeStoreName = storeName.toLowerCase().replaceAll(' ', '');
    return join(storesFolder, '$safeStoreName.db');
  }

  Future<List<File>> getStoreDbFiles(String ownerName) async {
    try {
      final ownerFolder = await getOwnerFolderPath(ownerName);
      final storesFolder = join(ownerFolder, 'stores');

      final storesDir = Directory(storesFolder);
      if (!storesDir.existsSync()) {
        return [];
      }

      final files = storesDir.listSync();
      final dbFiles = files
          .where((file) => file is File && file.path.endsWith('.db'))
          .cast<File>()
          .toList();

      return dbFiles;
    } catch (e) {
      _logger.e('❌ Error getting store DB files: $e');
      return [];
    }
  }

  // ======================================================
  // STORE TABLES (Sync-ready) - UNCHANGED
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
        brand_id INTEGER, -- ✅ New
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
  CREATE TABLE IF NOT EXISTS brands (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER,
    name TEXT NOT NULL,
    description TEXT,
    is_synced INTEGER DEFAULT 0,
    last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
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
    _logger.i('🔄 Upgrading store DB from $oldVersion → $newVersion');

    try {
      // ======================================================
      // 1️⃣ Ensure all tables have sync columns
      // ======================================================
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

      // Ensure sync_metadata exists
      await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_push_at TEXT,
        last_pull_at TEXT
      );
    ''');

      _logger.i('✅ Verified sync metadata and sync columns');

      // ======================================================
      // 2️⃣ Ensure brands table exists
      // ======================================================
      await db.execute('''
      CREATE TABLE IF NOT EXISTS brands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT NOT NULL,
        description TEXT,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      );
    ''');

      _logger.i('✅ Verified or created brands table');

      // ======================================================
      // 3️⃣ Ensure brand_id column exists in products
      // ======================================================
      final hasBrandId = await _columnExists(db, 'products', 'brand_id');
      if (!hasBrandId) {
        await db.execute('ALTER TABLE products ADD COLUMN brand_id INTEGER;');
        _logger.i('✅ Added missing brand_id column to products table');
      } else {
        _logger.i('ℹ️ brand_id column already exists in products table');
      }

      // ======================================================
      // 4️⃣ Optional: Add foreign key constraint (if needed)
      // ======================================================
      // Note: SQLite doesn’t allow adding foreign keys directly via ALTER TABLE.
      // If you ever need strict FK enforcement, you’d recreate the table manually.

      _logger.i('✅ Store DB upgraded successfully ✅');
    } catch (e) {
      _logger.e('❌ Error during store DB upgrade: $e');
      rethrow;
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
        status TEXT DEFAULT 'pending',
        is_active INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        subscription_plan_id INTEGER,
        subscription_plan_name TEXT,
        status TEXT DEFAULT 'active', -- active, inactive, expired, cancelled
        receipt_image TEXT,
        payment_date TEXT,
        subscription_amount REAL,
        subscription_start_date TEXT NOT NULL,
        subscription_end_date TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES owners (id) ON DELETE CASCADE
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
      if (oldVersion < 4) {
        // ✅ MIGRATION: Move subscription data to new table
        _logger.i('🔄 Migrating to new subscription schema...');

        final ownerColumns = await db.rawQuery('PRAGMA table_info(owners)');
        final hasOldSubscriptionColumns = ownerColumns.any(
          (col) => [
            'subscription_plan',
            'receipt_image',
            'payment_date',
            'subscription_amount',
            'subscription_start_date',
            'subscription_end_date',
          ].contains(col['name']),
        );

        if (hasOldSubscriptionColumns) {
          _logger.i('📦 Migrating existing subscription data...');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS subscriptions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              owner_id INTEGER NOT NULL,
              subscription_plan_id INTEGER,
              subscription_plan_name TEXT,
              status TEXT DEFAULT 'active',
              receipt_image TEXT,
              payment_date TEXT,
              subscription_amount REAL,
              subscription_start_date TEXT NOT NULL,
              subscription_end_date TEXT NOT NULL,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
              FOREIGN KEY (owner_id) REFERENCES owners (id) ON DELETE CASCADE
            );
          ''');

          await db.execute('''
            INSERT INTO subscriptions (
              owner_id, subscription_plan_name, receipt_image, payment_date, 
              subscription_amount, subscription_start_date, subscription_end_date, status
            )
            SELECT 
              id, 
              subscription_plan, 
              receipt_image, 
              payment_date, 
              subscription_amount, 
              COALESCE(subscription_start_date, datetime('now')),
              COALESCE(subscription_end_date, datetime('now', '+30 days')),
              CASE 
                WHEN subscription_end_date IS NULL OR subscription_end_date = '' THEN 'inactive'
                WHEN date(subscription_end_date) >= date('now') THEN 'active'
                ELSE 'expired'
              END
            FROM owners 
            WHERE subscription_plan IS NOT NULL 
              OR receipt_image IS NOT NULL 
              OR payment_date IS NOT NULL
              OR subscription_amount IS NOT NULL
          ''');

          _logger.i('✅ Subscription data migrated successfully');

          // Create temporary table without subscription columns
          await db.execute('''
            CREATE TABLE owners_temp (
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
              created_at TEXT DEFAULT CURRENT_TIMESTAMP
            );
          ''');

          await db.execute('''
            INSERT INTO owners_temp (
              id, super_admin_id, shop_name, owner_name, email, password, 
              contact, activation_code, status, is_active, created_at
            )
            SELECT 
              id, super_admin_id, shop_name, owner_name, email, password, 
              contact, activation_code, status, is_active, created_at
            FROM owners
          ''');

          await db.execute('DROP TABLE owners');
          await db.execute('ALTER TABLE owners_temp RENAME TO owners');

          _logger.i('✅ Owners table cleaned up successfully');
        } else {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS subscriptions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              owner_id INTEGER NOT NULL,
              subscription_plan_id INTEGER,
              subscription_plan_name TEXT,
              status TEXT DEFAULT 'active',
              receipt_image TEXT,
              payment_date TEXT,
              subscription_amount REAL,
              subscription_start_date TEXT NOT NULL,
              subscription_end_date TEXT NOT NULL,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
              FOREIGN KEY (owner_id) REFERENCES owners (id) ON DELETE CASCADE
            );
          ''');
        }

        _logger.i(
          '✅ Successfully upgraded to version 4 with subscriptions table',
        );
      }

      if (oldVersion < 5) {
        // ✅ MIGRATION: Remove activation_code column completely
        _logger.i('🔄 Removing activation_code column...');

        final ownerColumns = await db.rawQuery('PRAGMA table_info(owners)');
        final hasActivationCode = ownerColumns.any(
          (col) => col['name'] == 'activation_code',
        );

        if (hasActivationCode) {
          await db.execute('''
            CREATE TABLE owners_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              super_admin_id INTEGER,
              shop_name TEXT,
              owner_name TEXT,
              email TEXT UNIQUE,
              password TEXT,
              contact TEXT,
              status TEXT DEFAULT 'pending',
              is_active INTEGER DEFAULT 0,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP
            );
          ''');

          await db.execute('''
            INSERT INTO owners_new (
              id, super_admin_id, shop_name, owner_name, email, password, 
              contact, status, is_active, created_at
            )
            SELECT 
              id, super_admin_id, shop_name, owner_name, email, password, 
              contact, status, is_active, created_at
            FROM owners
          ''');

          await db.execute('DROP TABLE owners');
          await db.execute('ALTER TABLE owners_new RENAME TO owners');

          _logger.i('✅ Activation code removed successfully');
        } else {
          _logger.i('✅ Activation code column already removed');
        }

        _logger.i(
          '✅ Successfully upgraded to version 5 without activation code',
        );
      }
    } catch (e) {
      _logger.e('❌ Database upgrade failed: $e');
      rethrow;
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

  Future<void> debugSystemSchema(Database db) async {
    final tables = [
      'super_admin',
      'owners',
      'subscriptions',
      'subscription_plans',
    ];
    print('🔎 === SYSTEM DB SCHEMA ===');
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

  // Add this method to DatabaseHelper
  Future<void> debugProductsTable(String ownerName, String storeName) async {
    try {
      final dbPath = await getStoreDbPath(ownerName, storeName);
      _logger.i('🔍 Debugging products table for: $dbPath');

      final db = await databaseFactory.openDatabase(dbPath);

      // 1. Check products table structure
      final productsInfo = await db.rawQuery('PRAGMA table_info(products)');
      _logger.i('📋 Products table columns:');
      for (final column in productsInfo) {
        _logger.i('   - ${column['name']} | ${column['type']}');
      }

      // 2. Check if brand_id column exists and has data
      final hasBrandId = productsInfo.any((col) => col['name'] == 'brand_id');
      if (hasBrandId) {
        _logger.i('✅ brand_id column exists in schema');

        // Check if any products have brand_id values
        final brandData = await db.rawQuery('''
        SELECT id, name, brand_id 
        FROM products 
        WHERE brand_id IS NOT NULL
      ''');

        if (brandData.isEmpty) {
          _logger.i(
            'ℹ️ All products have NULL brand_id (expected for existing data)',
          );
        } else {
          _logger.i('📊 Products with brand_id values:');
          for (final product in brandData) {
            _logger.i(
              '   - ${product['id']}: ${product['name']} → brand_id: ${product['brand_id']}',
            );
          }
        }
      }

      // 3. Show first few products with all columns
      final sampleProducts = await db.rawQuery('''
      SELECT * FROM products LIMIT 5
    ''');

      _logger.i('📊 Sample products data:');
      for (final product in sampleProducts) {
        _logger.i('   Product: ${product['id']} - ${product['name']}');
        _logger.i('   All columns: $product');
      }

      await db.close();
    } catch (e) {
      _logger.e('❌ Error debugging products table: $e');
    }
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

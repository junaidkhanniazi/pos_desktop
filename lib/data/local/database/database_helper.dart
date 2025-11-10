import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    // FFI init for Windows/Linux/Mac
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final _logger = Logger();

  // ======================================================
  // COMMON: Safe DB operations with retry (still useful)
  // ======================================================
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 5,
    int baseDelayMs = 100,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        final msg = e.toString();
        if ((msg.contains('locked') || msg.contains('database is locked')) &&
            attempt < maxRetries) {
          final delay = Duration(milliseconds: baseDelayMs * attempt);
          _logger.w(
            '🔄 Database locked, retrying in ${delay.inMilliseconds}ms '
            '(attempt $attempt/$maxRetries)',
          );
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Max retries exceeded for database operation');
  }

  // ======================================================
  // MASTER DB (per owner) → Pos_Desktop/owners/{owner}/master.db
  // ======================================================
  Future<Database> openMasterDB(int ownerId, String ownerName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final posDesktopFolder = Directory(
        join(documentsDir.path, 'Pos_Desktop'),
      );

      final ownersFolder = join(posDesktopFolder.path, 'owners');
      final ownerFolder = join(ownersFolder, ownerName.toLowerCase());
      await Directory(ownerFolder).create(recursive: true);

      final masterPath = join(ownerFolder, 'master.db');
      _logger.i('📂 Opening Master DB for $ownerName → $masterPath');

      final db = await databaseFactory.openDatabase(
        masterPath,
        options: OpenDatabaseOptions(
          version: 1, // clean schema
          onCreate: _createMasterTables,
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
      _logger.e('❌ Failed to open Master DB for $ownerName: $e');
      rethrow;
    }
  }

  Future<void> _createMasterTables(Database db, int version) async {
    _logger.i('⚙️ Creating Master DB tables (stores)...');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stores (
        id INTEGER PRIMARY KEY,
        ownerId INTEGER,
        storeName TEXT,
        folderPath TEXT,
        dbPath TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        is_synced INTEGER DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    _logger.i('✅ Master DB tables created successfully');
  }

  // ======================================================
  // STORE DB (per store) → Pos_Desktop/owners/{owner}/stores/{store}.db
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

      final ownersFolder = join(posDesktopFolder.path, 'owners');
      final ownerFolder = join(ownersFolder, ownerName.toLowerCase());
      final storesFolder = join(ownerFolder, 'stores');

      // create stores folder if missing
      if (!Directory(storesFolder).existsSync()) {
        await Directory(storesFolder).create(recursive: true);
        _logger.i('📁 Created stores folder: $storesFolder');
      }

      final safeStoreName = storeName.toLowerCase().replaceAll(' ', '');
      final dbPath = join(storesFolder, '$safeStoreName.db');
      _logger.i('🏪 Opening store DB: $dbPath');

      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async => createStoreTables(db),
          onOpen: (db) async {
            // Safety: ensure tables exist even if DB created older
            await createStoreTables(db);
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

  // ✅ ALL STORE TABLES (sync ready)
  static Future<void> createStoreTables(Database db) async {
    // CATEGORIES
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

    // BRANDS
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

    // PRODUCTS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT NOT NULL,
        brand_id INTEGER,
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

    // SALES
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

    // SALE ITEMS
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

    // SUPPLIERS
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

    // CUSTOMERS
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

    // EXPENSES
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

    // SYNC METADATA (no is_synced – internal only)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_push_at TEXT,
        last_pull_at TEXT
      );
    ''');
  }

  // ======================================================
  // PATH HELPERS
  // ======================================================
  Future<String> getOwnerFolderPath(String ownerName) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final posDesktopFolder = Directory(join(documentsDir.path, 'Pos_Desktop'));
    final ownersFolder = join(posDesktopFolder.path, 'owners');
    return join(ownersFolder, ownerName.toLowerCase());
  }

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
      if (!storesDir.existsSync()) return [];

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
  // DEBUG HELPERS (only store/master now)
  // ======================================================
  Future<void> debugStoreSchema(Database db) async {
    final tables = [
      'categories',
      'brands',
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

  Future<void> debugProductsTable(String ownerName, String storeName) async {
    try {
      final dbPath = await getStoreDbPath(ownerName, storeName);
      _logger.i('🔍 Debugging products table for: $dbPath');

      final db = await databaseFactory.openDatabase(dbPath);

      final productsInfo = await db.rawQuery('PRAGMA table_info(products)');
      _logger.i('📋 Products table columns:');
      for (final column in productsInfo) {
        _logger.i('   - ${column['name']} | ${column['type']}');
      }

      final brandData = await db.rawQuery('''
        SELECT id, name, brand_id 
        FROM products 
        WHERE brand_id IS NOT NULL
      ''');

      if (brandData.isEmpty) {
        _logger.i('ℹ️ All products have NULL brand_id (old data maybe)');
      } else {
        _logger.i('📊 Products with brand_id values:');
        for (final product in brandData) {
          _logger.i(
            '   - ${product['id']}: ${product['name']} → brand_id: ${product['brand_id']}',
          );
        }
      }

      final sampleProducts = await db.rawQuery(
        'SELECT * FROM products LIMIT 5',
      );
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
}

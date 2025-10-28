import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;
  final _logger = Logger();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    // Initialize sqflite ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'pos_system.db');
    _logger.i('💡 Database initializing at: $path');

    try {
      var db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createTables,
          onConfigure: (db) async {
            // Configure database for better performance
            await db.execute('PRAGMA foreign_keys = ON');
            await db.execute('PRAGMA busy_timeout = 5000');
          },
        ),
      );

      _logger.i('✅ Database initialized successfully!');
      return db;
    } catch (e) {
      _logger.e('❌ Database initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    _logger.i('⚙️ Creating all POS tables...');

    // Create tables one by one (more reliable than batch)

    // 1️⃣ Super Admin
    await db.execute('''
      CREATE TABLE IF NOT EXISTS super_admin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 2️⃣ Owners
    await db.execute('''
      CREATE TABLE IF NOT EXISTS owners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        super_admin_id INTEGER,
        shop_name TEXT NOT NULL,
        owner_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        contact TEXT,
        activation_code TEXT,
        status TEXT DEFAULT 'pending',
        is_active INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (super_admin_id) REFERENCES super_admin (id)
      );
    ''');

    // 3️⃣ Users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        full_name TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT CHECK(role IN ('cashier','accountant','manager','admin')) DEFAULT 'cashier',
        permissions TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES owners (id)
      );
    ''');

    // 4️⃣ Categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES owners (id)
      );
    ''');

    // 5️⃣ Products
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        category_id INTEGER,
        name TEXT NOT NULL,
        sku TEXT UNIQUE,
        price REAL NOT NULL,
        cost_price REAL,
        quantity INTEGER DEFAULT 0,
        barcode TEXT,
        image_url TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES owners (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      );
    ''');

    // 6️⃣ Customers
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES owners (id)
      );
    ''');

    // 7️⃣ Sales
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        customer_id INTEGER,
        total_amount REAL NOT NULL,
        payment_method TEXT CHECK(payment_method IN ('cash','card','upi','other')) DEFAULT 'cash',
        discount REAL DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES owners (id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      );
    ''');

    // 8️⃣ Sale Items
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      );
    ''');

    // 9️⃣ Payments
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        method TEXT NOT NULL,
        reference TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sale_id) REFERENCES sales (id)
      );
    ''');

    // 🔟 Settings
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        key TEXT NOT NULL,
        value TEXT,
        FOREIGN KEY (owner_id) REFERENCES owners (id)
      );
    ''');

    _logger.i('✅ All POS tables created successfully!');

    // Now create indexes AFTER tables are created
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    _logger.i('📊 Creating database indexes...');

    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_owners_email ON owners(email);',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_owners_status ON owners(status);',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_owner_id ON products(owner_id);',
      );

      _logger.i('✅ Database indexes created successfully!');
    } catch (e) {
      _logger.w('⚠️ Index creation failed (tables might not exist yet): $e');
      // Don't throw error for indexes - they're optional for performance
    }
  }

  // Simple retry mechanism
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (e.toString().contains('locked') && attempt < maxRetries) {
          _logger.w('🔄 Database locked, retrying attempt $attempt...');
          await Future.delayed(Duration(milliseconds: 200 * attempt));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Max retries exceeded');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('🔒 Database closed successfully');
    }
  }

  // Example method
  Future<List<Map<String, dynamic>>> fetchAdmins() async {
    final db = await database;
    return await db.query('super_admin');
  }
}

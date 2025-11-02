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

  // 🔹 FIXED: Remove nested synchronization to prevent deadlock
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
    // ✅ CREATE Pos_Desktop FOLDER IN DOCUMENTS
    Directory documentsDir = await getApplicationDocumentsDirectory();
    Directory posDesktopFolder = Directory(
      join(documentsDir.path, 'Pos_Desktop'),
    );

    if (!posDesktopFolder.existsSync()) {
      await posDesktopFolder.create(recursive: true);
      _logger.i('📁 Created Pos_Desktop folder: ${posDesktopFolder.path}');
    }

    // ✅ SYSTEM DB IN Pos_Desktop FOLDER
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
      await _debugTableStructure(db);
      return db;
    } catch (e) {
      _logger.e('❌ Failed to initialize system DB: $e');
      rethrow;
    }
  }

  // -------------------------------------------------
  // 🔹 MASTER DB (per Owner) - UPDATED WITH OWNER NAME
  // -------------------------------------------------
  Future<Database> openMasterDB(int ownerId, String ownerName) async {
    try {
      // ✅ Pos_Desktop FOLDER IN DOCUMENTS
      final documentsDir = await getApplicationDocumentsDirectory();
      final posDesktopFolder = Directory(
        join(documentsDir.path, 'Pos_Desktop'),
      );

      // ✅ pos_data FOLDER INSIDE Pos_Desktop
      final posDataFolder = join(posDesktopFolder.path, 'pos_data');

      // ✅ OWNER FOLDER INSIDE pos_data
      final ownerFolder = join(posDataFolder, ownerName.toLowerCase());
      await Directory(ownerFolder).create(recursive: true);

      // ✅ MASTER DB PATH
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

  // -------------------------------------------------
  // 🔹 STORE DB (per Store) - UPDATED WITH OWNER NAME
  // -------------------------------------------------
  Future<Database> openStoreDB(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
  ) async {
    try {
      // ✅ Pos_Desktop FOLDER IN DOCUMENTS
      final documentsDir = await getApplicationDocumentsDirectory();
      final posDesktopFolder = Directory(
        join(documentsDir.path, 'Pos_Desktop'),
      );

      // ✅ pos_data FOLDER
      final posDataFolder = join(posDesktopFolder.path, 'pos_data');

      // ✅ OWNER FOLDER
      final ownerFolder = join(posDataFolder, ownerName.toLowerCase());

      // ✅ STORE FOLDER (Store Name se - junaid_tailor, junaid_sweets, etc.)
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

      // ✅ STORE DB PATH (Simple store.db filename)
      final dbPath = join(storeFolder.path, 'store.db');
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
      _logger.e('❌ Failed to open Store DB for $storeName: $e');
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
  // 🔹 DEBUG COMPLETE STRUCTURE
  // -------------------------------------------------
  // Future<void> debugCompleteStructure() async {
  //   try {
  //     final appDataDir = await getApplicationSupportDirectory();
  //     final posDesktopFolder = Directory(join(appDataDir.path, 'Pos_Desktop'));

  //     print('=== COMPLETE DATABASE STRUCTURE ===');
  //     print('App Data Path: $appDataDir');

  //     if (await posDesktopFolder.exists()) {
  //       print('📁 Pos_Desktop Folder: EXISTS');
  //       final entities = posDesktopFolder.listSync();

  //       for (var entity in entities) {
  //         if (entity is Directory) {
  //           final ownerName = entity.path.split(Platform.pathSeparator).last;
  //           print('  👤 Owner: $ownerName');

  //           final ownerFiles = entity.listSync();
  //           for (var file in ownerFiles) {
  //             if (file is File) {
  //               print('    📄 ${file.path.split(Platform.pathSeparator).last}');
  //             } else if (file is Directory) {
  //               final storeName = file.path.split(Platform.pathSeparator).last;
  //               print('    🏪 Store: $storeName');
  //               final storeFiles = file.listSync();
  //               for (var storeFile in storeFiles) {
  //                 if (storeFile is File) {
  //                   print(
  //                     '      📄 ${storeFile.path.split(Platform.pathSeparator).last}',
  //                   );
  //                 }
  //               }
  //             }
  //           }
  //         } else if (entity is File) {
  //           print('  📄 ${entity.path.split(Platform.pathSeparator).last}');
  //         }
  //       }
  //     } else {
  //       print('❌ Pos_Desktop Folder: NOT FOUND');
  //     }
  //     print('==================================');
  //   } catch (e) {
  //     print('❌ Error debugging structure: $e');
  //   }
  // }

  // -------------------------------------------------
  // 🔹 CLOSE DATABASE
  // -------------------------------------------------
  Future<void> close() async {
    await _lock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _logger.i('🔒 Database closed successfully');
      }
    });
  }

  // DatabaseHelper mein yeh method add karen
  Future<void> testNewStructure() async {
    try {
      print('=== TESTING NEW DATABASE STRUCTURE ===');

      // 1. System DB check
      final systemDb = await database;
      print('✅ 1. System DB working');

      // 2. Multiple owners ke liye test karen
      final owners = [
        {"id": 8, "name": "junaid"},
        {"id": 9, "name": "hammad"},
        {"id": 10, "name": "hashim"},
      ];

      for (final owner in owners) {
        final ownerId = owner["id"] as int;
        final ownerName = owner["name"] as String;

        // Master DB create karen each owner ke liye
        final masterDb = await openMasterDB(ownerId, ownerName);
        print('✅ Master DB created for $ownerName');

        // Each owner ke liye different stores create karen
        final stores = _getStoresForOwner(ownerName);
        for (int i = 0; i < stores.length; i++) {
          final storeDb = await openStoreDB(
            ownerId,
            ownerName,
            i + 1,
            stores[i],
          );
          await storeDb.close();
          print('✅ Store created for $ownerName: ${stores[i]}');
        }
        await masterDb.close();
      }

      // 3. Structure debug karen
      await debugCompleteStructure();

      print('🎉 ALL TESTS PASSED! New structure working with multiple owners.');
    } catch (e) {
      print('❌ TEST FAILED: $e');
    }
  }

  // Helper method for different stores for different owners
  List<String> _getStoresForOwner(String ownerName) {
    switch (ownerName) {
      case "junaid":
        return ["junaid_tailor", "junaid_sweets", "junaid_traders"];
      case "hammad":
        return ["hammad_electronics", "hammad_mobiles"];
      case "hashim":
        return ["hashim_warehouse", "hashim_wholesale"];
      default:
        return ["main_store"];
    }
  }

  // DatabaseHelper mein yeh method add karen
  Future<void> createMultipleStoresTest() async {
    try {
      print('=== CREATING MULTIPLE STORES FOR MULTIPLE OWNERS ===');

      // 1. Pehle current structure check karen
      print('📊 CURRENT STRUCTURE BEFORE TEST:');
      await debugCompleteStructure();

      // 2. Multiple owners create karen
      final owners = [
        {
          "id": 8,
          "name": "junaid",
          "stores": ["junaid_tailor", "junaid_sweets", "junaid_traders"],
        },
        {
          "id": 9,
          "name": "hammad",
          "stores": ["hammad_electronics", "hammad_mobiles"],
        },
        {
          "id": 10,
          "name": "hashim",
          "stores": ["hashim_warehouse", "hashim_wholesale"],
        },
      ];

      for (final owner in owners) {
        final ownerId = owner["id"] as int;
        final ownerName = owner["name"] as String;
        final stores = owner["stores"] as List<String>;

        print('\n👤 Processing Owner: $ownerName');

        // Master DB create karen
        final masterDb = await openMasterDB(ownerId, ownerName);

        // Each store create karen
        for (int i = 0; i < stores.length; i++) {
          final storeName = stores[i];
          final storeDb = await openStoreDB(
            ownerId,
            ownerName,
            i + 1,
            storeName,
          );
          await storeDb.close();

          // Master DB mein store record add karen
          await masterDb.insert('stores', {
            'id': DateTime.now().millisecondsSinceEpoch + i, // Unique ID
            'ownerId': ownerId,
            'storeName': storeName,
            'folderPath':
                'Pos_Desktop/pos_data/$ownerName/${ownerName}_${storeName.toLowerCase().replaceAll(' ', '_')}',
            'dbPath':
                'Pos_Desktop/pos_data/$ownerName/${ownerName}_${storeName.toLowerCase().replaceAll(' ', '_')}/store.db',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });

          print('   ✅ Store created: $storeName');
        }

        await masterDb.close();
        print('   🎉 $ownerName - All stores created successfully!');
      }

      // 3. Final structure check karen
      print('\n📊 FINAL STRUCTURE AFTER CREATING MULTIPLE OWNERS & STORES:');
      await debugCompleteStructure();

      print('\n🎉 MULTIPLE OWNERS & STORES CREATED SUCCESSFULLY!');
    } catch (e) {
      print('❌ Error creating multiple owners & stores: $e');
    }
  }

  Future<void> debugCompleteStructure() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final posDesktopFolder = Directory(
        join(documentsDir.path, 'Pos_Desktop'),
      );

      print('=== COMPLETE DATABASE STRUCTURE ===');
      print('Documents Path: $documentsDir');

      if (await posDesktopFolder.exists()) {
        print('📁 Pos_Desktop Folder: EXISTS');

        // ✅ SHOW MAIN SYSTEM DB
        final systemDbFile = File(join(posDesktopFolder.path, 'pos_system.db'));
        if (await systemDbFile.exists()) {
          print('  📄 pos_system.db (Main System DB)');
        }

        // ✅ CHECK pos_data FOLDER
        final posDataFolder = Directory(
          join(posDesktopFolder.path, 'pos_data'),
        );
        if (await posDataFolder.exists()) {
          print('  📁 pos_data Folder: EXISTS');
          final ownerFolders = posDataFolder.listSync();

          int totalOwners = 0;
          int totalStores = 0;

          for (var ownerFolder in ownerFolders) {
            if (ownerFolder is Directory) {
              totalOwners++;
              final ownerName = ownerFolder.path
                  .split(Platform.pathSeparator)
                  .last;
              print('    👤 Owner: $ownerName');

              final ownerEntities = ownerFolder.listSync();
              int ownerStoreCount = 0;

              for (var entity in ownerEntities) {
                if (entity is File) {
                  print(
                    '      📄 ${entity.path.split(Platform.pathSeparator).last}',
                  );
                } else if (entity is Directory) {
                  ownerStoreCount++;
                  totalStores++;
                  final storeName = entity.path
                      .split(Platform.pathSeparator)
                      .last;
                  print('      🏪 Store: $storeName');

                  final storeFiles = entity.listSync();
                  for (var storeFile in storeFiles) {
                    if (storeFile is File) {
                      print(
                        '        📄 ${storeFile.path.split(Platform.pathSeparator).last}',
                      );
                    }
                  }
                }
              }
              print('      📊 Stores Count: $ownerStoreCount');
            }
          }

          print('\n📈 SUMMARY:');
          print('   Total Owners: $totalOwners');
          print('   Total Stores: $totalStores');
        } else {
          print('  ❌ pos_data Folder: NOT FOUND');
        }
      } else {
        print('❌ Pos_Desktop Folder: NOT FOUND');
      }
      print('==================================');
    } catch (e) {
      print('❌ Error debugging structure: $e');
    }
  }

  // 🔹 EMERGENCY RESET METHOD
  Future<void> forceResetDatabase() async {
    await _lock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      final appDataDir = await getApplicationSupportDirectory();
      final posDesktopFolder = Directory(join(appDataDir.path, 'Pos_Desktop'));
      final String path = join(posDesktopFolder.path, 'pos_system.db');

      // Delete the database file
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i('🗑️ Database file deleted to reset locks');
      }

      // Reinitialize
      _database = await _initDatabase();
    });
  }
}

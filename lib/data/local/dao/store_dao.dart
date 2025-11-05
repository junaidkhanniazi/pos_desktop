// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:pos_desktop/core/utils/validators.dart';

class StoreDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // -------------------------------------------------
  // 🔹 NEW: COUNT STORES FOR OWNER
  // -------------------------------------------------
  Future<int> getStoreCountByOwner({
    required int ownerId,
    required String ownerName,
  }) async {
    try {
      final masterDb = await _dbHelper.openMasterDB(ownerId, ownerName);
      final result = await masterDb.rawQuery(
        'SELECT COUNT(*) as cnt FROM stores',
      );
      await masterDb.close();
      final count = Sqflite.firstIntValue(result) ?? 0;
      print('📊 Total stores for $ownerName: $count');
      return count;
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 CREATE NEW STORE (with limit check hook)
  // -------------------------------------------------
  Future<void> createStore({
    required BuildContext context,
    required int ownerId,
    required String ownerName,
    required String storeName,
    int? maxAllowedStores, // ✅ New optional param for limit check
  }) async {
    try {
      // 🧩 Validation
      final error = Validators.notEmpty(storeName, fieldName: 'Store name');
      if (error != null) {
        if (context.mounted) {
          AppToast.show(context, message: error, type: ToastType.error);
        }
        return;
      }

      // ✅ If a plan limit was provided, check first
      if (maxAllowedStores != null) {
        final existingCount = await getStoreCountByOwner(
          ownerId: ownerId,
          ownerName: ownerName,
        );

        if (existingCount >= maxAllowedStores) {
          if (context.mounted) {
            AppToast.show(
              context,
              message:
                  'You have reached your store limit ($maxAllowedStores). Please upgrade your plan.',
              type: ToastType.warning,
            );
          }
          return;
        }
      }

      // 🧱 Generate unique store ID
      final storeId = DateTime.now().millisecondsSinceEpoch;

      // 🧭 Folder structure
      final storeDb = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await storeDb.close();

      // 🧠 Insert metadata in master.db
      final masterDb = await _dbHelper.openMasterDB(ownerId, ownerName);
      final store = StoreModel(
        id: storeId,
        ownerId: ownerId,
        storeName: storeName,
        folderPath: 'Pos_Desktop/$ownerName/${ownerName}_store_$storeId',
        dbPath:
            'Pos_Desktop/$ownerName/${ownerName}_store_$storeId/store_$storeId.db',
        createdAt: DateTime.now(),
      );
      await masterDb.insert(
        'stores',
        store.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await masterDb.close();

      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Store "$storeName" created successfully!',
          type: ToastType.success,
        );
      }
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      if (context.mounted) {
        AppToast.show(context, message: failure.message, type: ToastType.error);
      }
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 FETCH ALL STORES
  // -------------------------------------------------
  Future<List<StoreModel>> getAllStores(int ownerId, String ownerName) async {
    try {
      final masterDb = await _dbHelper.openMasterDB(ownerId, ownerName);
      final data = await masterDb.query('stores', orderBy: 'createdAt DESC');
      await masterDb.close();
      return data.map((e) => StoreModel.fromMap(e)).toList();
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 GET STORE BY ID
  // -------------------------------------------------
  Future<StoreModel?> getStoreById(
    int ownerId,
    String ownerName,
    int storeId,
  ) async {
    try {
      final masterDb = await _dbHelper.openMasterDB(ownerId, ownerName);
      final data = await masterDb.query(
        'stores',
        where: 'id = ?',
        whereArgs: [storeId],
        limit: 1,
      );
      await masterDb.close();
      if (data.isEmpty) return null;
      return StoreModel.fromMap(data.first);
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 DELETE STORE
  // -------------------------------------------------
  Future<void> deleteStore({
    required BuildContext context,
    required int ownerId,
    required String ownerName,
    required int storeId,
  }) async {
    try {
      final store = await getStoreById(ownerId, ownerName, storeId);
      if (store == null) {
        if (context.mounted) {
          AppToast.show(
            context,
            message: 'Store not found',
            type: ToastType.warning,
          );
        }
        return;
      }

      final appDataDir = await getApplicationSupportDirectory();
      final storeFolderPath = join(appDataDir.path, store.folderPath);
      final dir = Directory(storeFolderPath);
      if (await dir.exists()) await dir.delete(recursive: true);

      final masterDb = await _dbHelper.openMasterDB(ownerId, ownerName);
      await masterDb.delete('stores', where: 'id = ?', whereArgs: [storeId]);
      await masterDb.close();

      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Store "${store.storeName}" deleted successfully!',
          type: ToastType.success,
        );
      }
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      if (context.mounted) {
        AppToast.show(context, message: failure.message, type: ToastType.error);
      }
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 COPY STORE DATA
  // -------------------------------------------------
  Future<void> copyStoreData({
    required BuildContext context,
    required String sourceDbPath,
    required String destDbPath,
    List<String>? tables,
  }) async {
    try {
      final src = await openDatabase(sourceDbPath);
      final dst = await openDatabase(destDbPath);
      final tablesToCopy = tables ?? ['products', 'categories', 'suppliers'];

      for (final table in tablesToCopy) {
        final rows = await src.query(table);
        for (final row in rows) {
          await dst.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await src.close();
      await dst.close();

      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Store data copied successfully!',
          type: ToastType.success,
        );
      }
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      if (context.mounted) {
        AppToast.show(context, message: failure.message, type: ToastType.error);
      }
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 GET DEFAULT STORE
  // -------------------------------------------------
  Future<StoreModel?> getDefaultStore(int ownerId, String ownerName) async {
    try {
      final stores = await getAllStores(ownerId, ownerName);
      if (stores.isNotEmpty) {
        return stores.first;
      }
      return null;
    } catch (e) {
      print('❌ Error getting default store: $e');
      return null;
    }
  }
  // Add these methods to your existing StoreDao class

  // 🔹 DEBUG: Get store categories count
  Future<int> getStoreCategoriesCount(
    int storeId,
    String ownerName,
    int ownerId,
  ) async {
    try {
      final store = await getStoreById(ownerId, ownerName, storeId);
      if (store == null) return 0;

      final appDir = await getApplicationSupportDirectory();
      final dbPath = join(appDir.path, store.dbPath);

      final db = await openDatabase(dbPath);

      // Check if categories table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='categories'",
      );

      int categoryCount = 0;
      if (tables.isNotEmpty) {
        final categories = await db.query('categories');
        categoryCount = categories.length;
      }

      await db.close();

      print("📊 STORE DEBUG: ${store.storeName}");
      print("   📁 Categories count: $categoryCount");
      print("   📍 DB Path: ${store.dbPath}");

      return categoryCount;
    } catch (e) {
      print("❌ ERROR GETTING CATEGORIES COUNT: $e");
      return 0;
    }
  }

  // 🔹 DEBUG: Print all stores with their data
  Future<void> debugPrintAllStores(int ownerId, String ownerName) async {
    try {
      final stores = await getAllStores(ownerId, ownerName);

      print("\n" + "=" * 50);
      print("🏪 ALL STORES DEBUG INFO");
      print("=" * 50);

      for (final store in stores) {
        final categoryCount = await getStoreCategoriesCount(
          store.id!,
          ownerName,
          ownerId,
        );

        print("📋 Store: ${store.storeName}");
        print("   🆔 ID: ${store.id}");
        print("   📁 Categories: $categoryCount");
        print("   📅 Created: ${store.createdAt}");
        print("   📍 Path: ${store.folderPath}");
        print("   ─────────────────────────");
      }

      print("=" * 50 + "\n");
    } catch (e) {
      print("❌ ERROR DEBUGGING STORES: $e");
    }
  }

  // 🔹 DEBUG: Add dummy category to a store (for testing)
  Future<void> addDummyCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String categoryName,
  }) async {
    try {
      final store = await getStoreById(ownerId, ownerName, storeId);
      if (store == null) {
        print("❌ Store not found: $storeId");
        return;
      }

      final appDir = await getApplicationSupportDirectory();
      final dbPath = join(appDir.path, store.dbPath);
      final db = await openDatabase(dbPath);

      // Create categories table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Insert dummy category
      await db.insert('categories', {
        'name': categoryName,
        'description': 'Dummy category for testing store switching',
        'created_at': DateTime.now().toString(),
      });

      await db.close();

      print("✅ ADDED CATEGORY: '$categoryName' to ${store.storeName}");
    } catch (e) {
      print("❌ ERROR ADDING DUMMY CATEGORY: $e");
    }
  }
  // Add these methods to your existing StoreDao class

  // 🔹 DEBUG: Get store categories with names
  // StoreDao.dart mein ye method verify karein
  Future<List<Map<String, dynamic>>> getStoreCategories(
    int storeId,
    String ownerName,
    int ownerId,
    String storeName, // 🔹 ADD THIS PARAMETER
  ) async {
    try {
      print("\n🔍 DEBUG getStoreCategories:");
      print("   Store ID: $storeId");
      print("   Store Name: $storeName"); // 🔹 ADDED
      print("   Owner Name: $ownerName");
      print("   Owner ID: $ownerId");

      // 🔹 USE ACTUAL STORE NAME INSTEAD OF "temp"
      final db = await DatabaseHelper().openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      print("   📋 TABLES IN DATABASE:");
      for (var table in tables) {
        print("      - ${table['name']}");
      }

      final categories = await db.query('categories');
      print("   📦 CATEGORIES FOUND: ${categories.length}");

      for (var cat in categories) {
        print(
          "      🏷️ ID: ${cat['id']} | Name: ${cat['name']} | Desc: ${cat['description']}",
        );
      }

      await db.close();
      return categories;
    } catch (e) {
      print("❌ ERROR in getStoreCategories: $e");
      return [];
    }
  }

  // 🔹 DEBUG: Add categories to all existing stores
  Future<void> addCategoriesToAllStores(int ownerId, String ownerName) async {
    try {
      final stores = await getAllStores(ownerId, ownerName);

      print("🔄 ADDING CATEGORIES TO EXISTING STORES...");
      print("🏪 FOUND ${stores.length} STORES FOR $ownerName");

      // Define unique categories for each store
      final storeCategories = {
        'hashim': ['Shirts', 'Pants', 'Suits', 'Traditional Wear'],
        'hashimsweets': ['Mithai', 'Snacks', 'Desserts', 'Special Sweets'],
        'hashimtailor': [
          'Measurements',
          'Alterations',
          'New Stitching',
          'Repairs',
        ],
      };

      for (final store in stores) {
        final categories =
            storeCategories[store.storeName] ??
            ['Category 1', 'Category 2', 'Category 3'];

        print("\n📦 ADDING CATEGORIES TO: ${store.storeName}");
        print("   Categories: ${categories.join(', ')}");

        await _addCategoriesToStoreDatabase(
          store,
          categories,
          ownerName,
          ownerId,
        );
      }

      print("✅ CATEGORIES ADDED SUCCESSFULLY TO ALL STORES");
    } catch (e) {
      print("❌ ERROR ADDING CATEGORIES TO STORES: $e");
    }
  }

  // 🔹 DEBUG: Helper method to add categories to a specific store database
  Future<void> _addCategoriesToStoreDatabase(
    StoreModel store,
    List<String> categories,
    String ownerName,
    int ownerId,
  ) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final dbPath = join(appDir.path, store.dbPath);

      print("   📍 Opening DB: ${store.dbPath}");

      final db = await openDatabase(dbPath);

      // Create categories table if not exists
      await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

      // Clear existing categories (to avoid duplicates in testing)
      await db.delete('categories');

      // Add new categories
      for (final category in categories) {
        await db.insert('categories', {
          'name': category,
          'description': 'Category for ${store.storeName} store',
          'created_at': DateTime.now().toString(),
        });
      }

      // Verify categories were added
      final addedCategories = await db.query('categories');

      await db.close();

      print("   ✅ ADDED ${addedCategories.length} CATEGORIES:");
      for (final cat in addedCategories) {
        print("      - ${cat['name']}");
      }
    } catch (e) {
      print("   ❌ ERROR ADDING CATEGORIES TO ${store.storeName}: $e");
    }
  }
}

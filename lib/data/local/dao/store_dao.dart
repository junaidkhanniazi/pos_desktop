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
  // 🔹 CREATE NEW STORE - UPDATED
  // -------------------------------------------------
  Future<void> createStore({
    required BuildContext context,
    required int ownerId,
    required String ownerName, // ✅ ADD OWNER NAME PARAMETER
    required String storeName,
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

      // 🧱 Generate unique store ID
      final storeId = DateTime.now().millisecondsSinceEpoch;

      // 🧭 NEW FOLDER STRUCTURE: Pos_Desktop/ownerName/storeName/
      final storeDb = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await storeDb.close();

      // 🧠 Insert metadata in master.db
      final masterDb = await _dbHelper.openMasterDB(
        ownerId,
        ownerName,
      ); // ✅ UPDATED
      final store = StoreModel(
        id: storeId,
        ownerId: ownerId,
        storeName: storeName,
        folderPath:
            'Pos_Desktop/$ownerName/${ownerName}_store_$storeId', // ✅ UPDATED PATH
        dbPath:
            'Pos_Desktop/$ownerName/${ownerName}_store_$storeId/store_$storeId.db', // ✅ UPDATED PATH
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
  // 🔹 FETCH ALL STORES - UPDATED
  // -------------------------------------------------
  Future<List<StoreModel>> getAllStores(int ownerId, String ownerName) async {
    // ✅ ADD OWNER NAME
    try {
      final masterDb = await _dbHelper.openMasterDB(
        ownerId,
        ownerName,
      ); // ✅ UPDATED
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
  // 🔹 GET STORE BY ID - UPDATED
  // -------------------------------------------------
  Future<StoreModel?> getStoreById(
    int ownerId,
    String ownerName,
    int storeId,
  ) async {
    // ✅ ADD OWNER NAME
    try {
      final masterDb = await _dbHelper.openMasterDB(
        ownerId,
        ownerName,
      ); // ✅ UPDATED
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
  // 🔹 DELETE STORE - UPDATED
  // -------------------------------------------------
  Future<void> deleteStore({
    required BuildContext context,
    required int ownerId,
    required String ownerName, // ✅ ADD OWNER NAME
    required int storeId,
  }) async {
    try {
      final store = await getStoreById(
        ownerId,
        ownerName,
        storeId,
      ); // ✅ UPDATED
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

      // Delete folder recursively
      final appDataDir = await getApplicationSupportDirectory();
      final storeFolderPath = join(appDataDir.path, store.folderPath);
      final dir = Directory(storeFolderPath);

      if (await dir.exists()) await dir.delete(recursive: true);

      final masterDb = await _dbHelper.openMasterDB(
        ownerId,
        ownerName,
      ); // ✅ UPDATED
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
  // 🔹 COPY DATA BETWEEN STORES - UPDATED
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
  // 🔹 GET DEFAULT STORE - NEW METHOD
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
}

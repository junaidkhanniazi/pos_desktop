import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:pos_desktop/core/utils/validators.dart'; // 👈 using your AppToast widget

class StoreDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // -------------------------------------------------
  // 🔹 CREATE NEW STORE
  // -------------------------------------------------
  Future<void> createStore({
    required BuildContext context,
    required int ownerId,
    required String storeName,
  }) async {
    try {
      // 🧩 Validation
      final error = Validators.notEmpty(storeName, fieldName: 'Store name');
      if (error != null) {
        AppToast.show(context, message: error, type: ToastType.error);
        return;
      }

      // 🧱 Generate unique store ID
      final storeId = DateTime.now().millisecondsSinceEpoch;
      final dbBasePath = await getDatabasesPath();

      final safeStoreName = storeName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .trim();

      // 🧭 Folder structure: /pos_data/owner_<id>/store_<id>_<storeName>/
      final ownerFolder = join(dbBasePath, 'owner_$ownerId');
      final storeFolderName = 'store_${storeId}_$safeStoreName';
      final storeFolderPath = join(ownerFolder, storeFolderName);
      await Directory(storeFolderPath).create(recursive: true);

      final storeDbPath = join(storeFolderPath, '$safeStoreName.db');

      // 🧱 Create and initialize new store database
      final storeDb = await openDatabase(
        storeDbPath,
        version: 1,
        onCreate: (db, version) async => DatabaseHelper.createStoreTables(db),
      );
      await storeDb.close();

      // 🧠 Insert metadata in master.db
      final masterDb = await _dbHelper.openMasterDB(ownerId);
      final store = StoreModel(
        id: storeId,
        ownerId: ownerId,
        storeName: safeStoreName,
        folderPath: storeFolderPath,
        dbPath: storeDbPath,
        createdAt: DateTime.now(),
      );
      await masterDb.insert(
        'stores',
        store.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await masterDb.close();

      AppToast.show(
        context,
        message: 'Store "$storeName" created successfully!',
        type: ToastType.success,
      );
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      AppToast.show(context, message: failure.message, type: ToastType.error);
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 FETCH ALL STORES
  // -------------------------------------------------
  Future<List<StoreModel>> getAllStores(int ownerId) async {
    try {
      final masterDb = await _dbHelper.openMasterDB(ownerId);
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
  Future<StoreModel?> getStoreById(int ownerId, int storeId) async {
    try {
      final masterDb = await _dbHelper.openMasterDB(ownerId);
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
    required int storeId,
  }) async {
    try {
      final store = await getStoreById(ownerId, storeId);
      if (store == null) {
        AppToast.show(
          context,
          message: 'Store not found',
          type: ToastType.warning,
        );
        return;
      }

      // Delete folder recursively
      final dir = Directory(store.folderPath);
      if (await dir.exists()) await dir.delete(recursive: true);

      final masterDb = await _dbHelper.openMasterDB(ownerId);
      await masterDb.delete('stores', where: 'id = ?', whereArgs: [storeId]);
      await masterDb.close();

      AppToast.show(
        context,
        message: 'Store "${store.storeName}" deleted successfully!',
        type: ToastType.success,
      );
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      AppToast.show(context, message: failure.message, type: ToastType.error);
      throw failure;
    }
  }

  // -------------------------------------------------
  // 🔹 COPY DATA BETWEEN STORES
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

      AppToast.show(
        context,
        message: 'Store data copied successfully!',
        type: ToastType.success,
      );
    } catch (e, s) {
      final failure = ExceptionHandler.handle(e);
      debugPrintStack(label: failure.message, stackTrace: s);
      AppToast.show(context, message: failure.message, type: ToastType.error);
      throw failure;
    }
  }
}

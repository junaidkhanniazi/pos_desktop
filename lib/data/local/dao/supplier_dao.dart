import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/supplier_model.dart';

class SupplierDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 GET ALL SUPPLIERS
  Future<List<SupplierModel>> getSuppliers({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query('suppliers', orderBy: 'name ASC');
      await db.close();
      return data.map((e) => SupplierModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting suppliers: $e');
      rethrow;
    }
  }

  // 🔹 GET SUPPLIER BY ID
  Future<SupplierModel?> getSupplierById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int supplierId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'suppliers',
        where: 'id = ?',
        whereArgs: [supplierId],
        limit: 1,
      );
      await db.close();
      if (data.isEmpty) return null;
      return SupplierModel.fromMap(data.first);
    } catch (e) {
      print('❌ ERROR getting supplier by ID: $e');
      rethrow;
    }
  }

  // 🔹 INSERT SUPPLIER
  Future<int> insertSupplier({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String name,
    String? contact,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final id = await db.insert('suppliers', {
        'name': name,
        'contact': contact,
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      });
      await db.close();
      return id;
    } catch (e) {
      print('❌ ERROR inserting supplier: $e');
      rethrow;
    }
  }

  // 🔹 UPDATE SUPPLIER
  Future<void> updateSupplier({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int supplierId,
    required String name,
    String? contact,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'suppliers',
        {
          'name': name,
          'contact': contact,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [supplierId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR updating supplier: $e');
      rethrow;
    }
  }

  // 🔹 DELETE SUPPLIER
  Future<void> deleteSupplier({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int supplierId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.delete('suppliers', where: 'id = ?', whereArgs: [supplierId]);
      await db.close();
    } catch (e) {
      print('❌ ERROR deleting supplier: $e');
      rethrow;
    }
  }

  // 🔹 SEARCH SUPPLIERS
  Future<List<SupplierModel>> searchSuppliers({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'suppliers',
        where: 'name LIKE ? OR contact LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      await db.close();
      return data.map((e) => SupplierModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR searching suppliers: $e');
      rethrow;
    }
  }
}

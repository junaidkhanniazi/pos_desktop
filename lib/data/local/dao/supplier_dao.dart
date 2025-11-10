import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/supplier_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SupplierDao {
  final _dbHelper = DatabaseHelper();

  Future<List<SupplierModel>> getAllSuppliers(int storeId) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
    final result = await db.query('suppliers');
    return result.map((e) => SupplierModel.fromMap(e)).toList();
  }

  Future<SupplierModel?> getSupplierById(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    final result = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return SupplierModel.fromMap(result.first);
  }

  Future<int> insertSupplier(SupplierModel model) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    return await db.insert(
      'suppliers',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSupplier(SupplierModel model) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.update(
      'suppliers',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteSupplier(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }
}

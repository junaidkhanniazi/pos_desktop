import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class StoreDao {
  final _dbHelper = DatabaseHelper();

  Future<List<StoreModel>> getAllStores(int ownerId) async {
    final db = await _dbHelper.openMasterDB(ownerId, 'owner_$ownerId');
    final result = await db.query('stores');
    return result.map((e) => StoreModel.fromMap(e)).toList();
  }

  Future<StoreModel?> getStoreById(int id) async {
    final db = await _dbHelper.openMasterDB(0, 'default');
    final result = await db.query('stores', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return StoreModel.fromMap(result.first);
  }

  Future<int> insertStore(StoreModel model) async {
    final db = await _dbHelper.openMasterDB(model.ownerId, 'default');
    return await db.insert(
      'stores',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStore(StoreModel model) async {
    final db = await _dbHelper.openMasterDB(model.ownerId, 'default');
    await db.update(
      'stores',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteStore(int id) async {
    final db = await _dbHelper.openMasterDB(0, 'default');
    await db.delete('stores', where: 'id = ?', whereArgs: [id]);
  }
}

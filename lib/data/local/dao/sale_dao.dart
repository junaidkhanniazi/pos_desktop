import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/sale_model.dart';
import 'package:pos_desktop/data/models/sale_item_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SaleDao {
  final _dbHelper = DatabaseHelper();

  Future<int> insertSale(SaleModel sale, List<SaleItemModel> items) async {
    final db = await _dbHelper.openStoreDB(0, 'default', 0, 'store');
    return await _dbHelper.executeWithRetry(() async {
      final saleId = await db.insert(
        'sales',
        sale.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var item in items) {
        await db.insert('sale_items', {...item.toMap(), 'sale_id': saleId});
      }

      return saleId;
    });
  }

  Future<List<SaleModel>> getAllSales(int storeId) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
    final result = await db.query('sales', orderBy: 'id DESC');
    return result.map((e) => SaleModel.fromMap(e)).toList();
  }

  Future<SaleModel?> getSaleById(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    final result = await db.query('sales', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return SaleModel.fromMap(result.first);
  }

  Future<List<SaleItemModel>> getItemsBySale(int saleId) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    final result = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return result.map((e) => SaleItemModel.fromMap(e)).toList();
  }

  Future<void> deleteSale(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.delete('sale_items', where: 'sale_id = ?', whereArgs: [id]);
    await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markSaleSynced(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.update(
      'sales',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SaleModel>> getUnsyncedSales(int storeId) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
    final result = await db.query(
      'sales',
      where: 'is_synced = 0',
      orderBy: 'id DESC',
    );
    return result.map((e) => SaleModel.fromMap(e)).toList();
  }
}

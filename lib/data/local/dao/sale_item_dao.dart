import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/sale_item_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SaleItemDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<SaleItemModel>> getSaleItems(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    int saleId,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    final result = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return result.map((row) => SaleItemModel.fromMap(row)).toList();
  }

  Future<int> insertSaleItem(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    SaleItemModel item,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    return await db.insert(
      'sale_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSaleItemsBySale(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    int saleId,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    await db.delete('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
  }
}

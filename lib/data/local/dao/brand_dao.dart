import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/brands_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BrandDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<BrandModel>> getAllBrands(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    final result = await db.query('brands');
    return result.map((row) => BrandModel.fromMap(row)).toList();
  }

  Future<int> insertBrand(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    BrandModel brand,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    return await db.insert(
      'brands',
      brand.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateBrand(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    BrandModel brand,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    await db.update(
      'brands',
      brand.toMap(),
      where: 'id = ?',
      whereArgs: [brand.id],
    );
  }

  Future<void> deleteBrand(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    int brandId,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    await db.delete('brands', where: 'id = ?', whereArgs: [brandId]);
  }
}

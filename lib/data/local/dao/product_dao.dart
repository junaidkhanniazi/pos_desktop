import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/product_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProductDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<ProductModel>> getAllProducts(
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
    final result = await db.query('products');
    return result.map((row) => ProductModel.fromMap(row)).toList();
  }

  Future<int> insertProduct(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    ProductModel product,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    ProductModel product,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    int productId,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    await db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }

  Future<List<ProductModel>> searchProducts(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    String query,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    final result = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((row) => ProductModel.fromMap(row)).toList();
  }
}

import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/category__model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CategoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<CategoryModel>> getAllCategories(
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
    final result = await db.query('categories');
    return result.map((row) => CategoryModel.fromMap(row)).toList();
  }

  Future<int> insertCategory(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    CategoryModel category,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    CategoryModel category,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(
    int ownerId,
    String ownerName,
    int storeId,
    String storeName,
    int categoryId,
  ) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    await db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
  }
}

import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/category__model.dart';
import 'package:sqflite/sqflite.dart';

class CategoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 GET ALL CATEGORIES
  Future<List<CategoryModel>> getCategories({
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
        storeName, // Pass the correct store name
      );
      final data = await db.query('categories', orderBy: 'name ASC');
      await db.close();
      return data.map((e) => CategoryModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting categories: $e');
      rethrow;
    }
  }

  // 🔹 GET CATEGORY BY ID
  Future<CategoryModel?> getCategoryById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [categoryId],
        limit: 1,
      );
      await db.close();
      if (data.isEmpty) return null;
      return CategoryModel.fromMap(data.first);
    } catch (e) {
      print('❌ ERROR getting category by ID: $e');
      rethrow;
    }
  }

  // 🔹 INSERT CATEGORY
  Future<int> insertCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String name,
    String? description,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final id = await db.insert('categories', {
        'name': name,
        'description': description ?? '',
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      });
      await db.close();
      return id;
    } catch (e) {
      print('❌ ERROR inserting category: $e');
      rethrow;
    }
  }

  // 🔹 UPDATE CATEGORY
  Future<void> updateCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    String? description,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'categories',
        {
          'name': name,
          'description': description,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [categoryId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR updating category: $e');
      rethrow;
    }
  }

  // 🔹 DELETE CATEGORY
  Future<void> deleteCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
      await db.close();
    } catch (e) {
      print('❌ ERROR deleting category: $e');
      rethrow;
    }
  }

  // 🔹 GET CATEGORIES COUNT
  Future<int> getCategoriesCount({
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
      final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM categories',
      );
      await db.close();
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('❌ ERROR getting categories count: $e');
      rethrow;
    }
  }
}

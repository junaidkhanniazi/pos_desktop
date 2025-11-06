import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/brands_model.dart';
import 'package:sqflite/sqflite.dart';

class BrandDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 GET ALL BRANDS
  Future<List<BrandModel>> getBrands({
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
      final data = await db.query('brands', orderBy: 'name ASC');
      await db.close();
      return data.map((e) => BrandModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting brands: $e');
      rethrow;
    }
  }

  // 🔹 GET BRANDS BY CATEGORY
  // 🔹 GET BRANDS BY CATEGORY - FIXED VERSION
  Future<List<BrandModel>> getBrandsByCategory({
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

      // ✅ FIXED: Get all brands for the category, not just those with products
      final data = await db.query(
        'brands',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'name ASC',
      );

      print(
        '🟢 [BrandDao] Found ${data.length} brands for category $categoryId',
      );
      for (var brand in data) {
        print('   → ${brand['name']} (ID: ${brand['id']})');
      }

      await db.close();
      return data.map((e) => BrandModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR fetching brands by category: $e');
      rethrow;
    }
  }

  // 🔹 GET BRAND BY ID
  Future<BrandModel?> getBrandById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'brands',
        where: 'id = ?',
        whereArgs: [brandId],
        limit: 1,
      );
      await db.close();
      if (data.isEmpty) return null;
      return BrandModel.fromMap(data.first);
    } catch (e) {
      print('❌ ERROR getting brand by ID: $e');
      rethrow;
    }
  }

  // 🔹 INSERT BRAND
  Future<int> insertBrand({
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
      final id = await db.insert('brands', {
        'category_id': categoryId,
        'name': name,
        'description': description ?? '',
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      });
      await db.close();
      return id;
    } catch (e) {
      print('❌ ERROR inserting brand: $e');
      rethrow;
    }
  }

  // 🔹 UPDATE BRAND
  Future<void> updateBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
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
        'brands',
        {
          'name': name,
          'description': description,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [brandId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR updating brand: $e');
      rethrow;
    }
  }

  // 🔹 DELETE BRAND (Soft delete)
  Future<void> deleteBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'brands',
        {'is_active': 0, 'last_updated': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [brandId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR deleting brand: $e');
      rethrow;
    }
  }

  // 🔹 SEARCH BRANDS
  Future<List<BrandModel>> searchBrands({
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
      final whereClause =
          '(name LIKE ? OR description LIKE ?) AND is_active = 1';
      final whereArgs = ['%$query%', '%$query%'];

      final data = await db.query(
        'brands',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      await db.close();
      return data.map((e) => BrandModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR searching brands: $e');
      rethrow;
    }
  }
}

import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/product_model.dart';

class ProductDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 GET ALL PRODUCTS
  Future<List<ProductModel>> getProducts({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    int? brandId, // Add brandId filter
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final whereClause = brandId != null ? 'brand_id = ?' : null;
      final whereArgs = brandId != null ? [brandId] : null;

      final data = await db.query(
        'products',
        where: whereClause, // Add brandId filter to WHERE clause
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      await db.close();
      return data.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting products: $e');
      rethrow;
    }
  }

  // 🔹 GET PRODUCTS BY CATEGORY
  Future<List<ProductModel>> getProductsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    int? brandId, // Add brandId filter
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final whereClause =
          'category_id = ? AND is_active = 1' +
          (brandId != null ? ' AND brand_id = ?' : '');
      final whereArgs = brandId != null ? [categoryId, brandId] : [categoryId];

      final data = await db.query(
        'products',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      await db.close();
      return data.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting products by category: $e');
      rethrow;
    }
  }

  // 🔹 GET PRODUCTS BY BRAND (NEW METHOD)
  Future<List<ProductModel>> getProductsByBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId, // Add brandId parameter
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );

      final whereClause = 'brand_id = ? AND is_active = 1'; // Filter by brandId
      final whereArgs = [brandId];

      final data = await db.query(
        'products',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      await db.close();
      return data.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting products by brand: $e');
      rethrow;
    }
  }

  // 🔹 GET PRODUCT BY ID
  Future<ProductModel?> getProductById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );
      await db.close();
      if (data.isEmpty) return null;
      return ProductModel.fromMap(data.first);
    } catch (e) {
      print('❌ ERROR getting product by ID: $e');
      rethrow;
    }
  }

  // 🔹 INSERT PRODUCT
  Future<int> insertProduct({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    required double price,
    String? sku,
    double? costPrice,
    int quantity = 0,
    String? barcode,
    String? imageUrl,
    int? brandId, // Add brandId to insert query
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final id = await db.insert('products', {
        'category_id': categoryId,
        'name': name,
        'sku': sku,
        'price': price,
        'cost_price': costPrice,
        'quantity': quantity,
        'barcode': barcode,
        'image_url': imageUrl,
        'is_active': 1,
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'brand_id': brandId, // Insert brandId as well
      });
      await db.close();
      return id;
    } catch (e) {
      print('❌ ERROR inserting product: $e');
      rethrow;
    }
  }

  // 🔹 UPDATE PRODUCT
  Future<void> updateProduct({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
    required String name,
    required double price,
    required int categoryId,
    double? costPrice,
    int? quantity,
    String? sku,
    String? barcode,
    int? brandId, // Add brandId to update query
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'products',
        {
          'name': name,
          'price': price,
          'category_id': categoryId,
          'cost_price': costPrice,
          'sku': sku,
          'barcode': barcode,
          if (quantity != null) 'quantity': quantity,
          if (brandId != null)
            'brand_id': brandId, // Update brandId if provided
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR updating product: $e');
      rethrow;
    }
  }

  // 🔹 DELETE PRODUCT (Soft delete)
  Future<void> deleteProduct({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'products',
        {'is_active': 0, 'last_updated': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [productId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR deleting product: $e');
      rethrow;
    }
  }

  // 🔹 UPDATE PRODUCT STOCK
  Future<void> updateProductStock({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
    required int newQuantity,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'products',
        {
          'quantity': newQuantity,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR updating product stock: $e');
      rethrow;
    }
  }

  // 🔹 SEARCH PRODUCTS
  Future<List<ProductModel>> searchProducts({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
    int? brandId, // Add brandId filter for search
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final whereClause = brandId != null
          ? '(name LIKE ? OR sku LIKE ? OR barcode LIKE ?) AND is_active = 1 AND brand_id = ?'
          : '(name LIKE ? OR sku LIKE ? OR barcode LIKE ?) AND is_active = 1';
      final whereArgs = brandId != null
          ? ['%$query%', '%$query%', '%$query%', brandId]
          : ['%$query%', '%$query%', '%$query%'];

      final data = await db.query(
        'products',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      await db.close();
      return data.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR searching products: $e');
      rethrow;
    }
  }
}

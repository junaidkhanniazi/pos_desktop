import 'package:pos_desktop/domain/entities/store/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    int? brandId,
  });

  Future<List<ProductEntity>> getProductsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    int? brandId,
  });

  Future<ProductEntity?> getProductById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  });

  Future<int> insertProduct({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    required double price,
    int? brandId,
    String? sku,
    double? costPrice,
    int quantity = 0,
    String? barcode,
    String? imageUrl,
  });

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
  });

  Future<void> deleteProduct({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  });

  Future<void> updateProductStock({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
    required int newQuantity,
  });

  Future<List<ProductEntity>> searchProducts({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  });

  Future<List<ProductEntity>> getProductsByBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  });
}

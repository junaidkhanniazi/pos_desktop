import 'package:pos_desktop/domain/entities/store/product_entity.dart';
import 'package:pos_desktop/domain/repositories/product_repository.dart';

/// Handles all product-related logic in the domain layer.
class ProductUseCase {
  final ProductRepository _repository;
  ProductUseCase(this._repository);

  /// Get all products for a store (optionally by brand)
  Future<List<ProductEntity>> getAll({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    int? brandId,
  }) {
    return _repository.getProducts(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
    );
  }

  /// Get products by category
  Future<List<ProductEntity>> getByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    int? brandId,
  }) {
    return _repository.getProductsByCategory(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
      brandId: brandId,
    );
  }

  /// Get products by brand
  Future<List<ProductEntity>> getByBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) {
    return _repository.getProductsByBrand(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
    );
  }

  /// Get single product
  Future<ProductEntity?> getById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  }) {
    return _repository.getProductById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
    );
  }

  /// Add new product
  Future<int> add({
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
  }) {
    return _repository.insertProduct(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
      name: name,
      price: price,
      brandId: brandId,
      sku: sku,
      costPrice: costPrice,
      quantity: quantity,
      barcode: barcode,
      imageUrl: imageUrl,
    );
  }

  /// Update existing product
  Future<void> update({
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
  }) {
    return _repository.updateProduct(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
      name: name,
      price: price,
      categoryId: categoryId,
      costPrice: costPrice,
      quantity: quantity,
      sku: sku,
      barcode: barcode,
    );
  }

  /// Delete a product
  Future<void> delete({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  }) {
    return _repository.deleteProduct(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
    );
  }

  /// Update stock quantity
  Future<void> updateStock({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
    required int newQuantity,
  }) {
    return _repository.updateProductStock(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
      newQuantity: newQuantity,
    );
  }

  /// Search products by query
  Future<List<ProductEntity>> search({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) {
    return _repository.searchProducts(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      query: query,
    );
  }
}

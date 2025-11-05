import 'package:pos_desktop/data/local/dao/product_dao.dart';
import 'package:pos_desktop/data/models/product_model.dart';
import 'package:pos_desktop/domain/entities/product_entity.dart';
import 'package:pos_desktop/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao _productDao;

  ProductRepositoryImpl(this._productDao);

  @override
  Future<List<ProductEntity>> getProducts({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    final products = await _productDao.getProducts(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
    );
    return products.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    final products = await _productDao.getProductsByCategory(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
    );
    return products.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProductById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  }) async {
    final product = await _productDao.getProductById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
    );
    return product?.toEntity();
  }

  @override
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
  }) async {
    return await _productDao.insertProduct(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
      name: name,
      price: price,
      sku: sku,
      costPrice: costPrice,
      quantity: quantity,
      barcode: barcode,
      imageUrl: imageUrl,
    );
  }

  @override
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
  }) async {
    await _productDao.updateProduct(
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

  @override
  Future<void> deleteProduct({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  }) async {
    await _productDao.deleteProduct(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
    );
  }

  @override
  Future<void> updateProductStock({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
    required int newQuantity,
  }) async {
    await _productDao.updateProductStock(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
      newQuantity: newQuantity,
    );
  }

  @override
  Future<List<ProductEntity>> searchProducts({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) async {
    final products = await _productDao.searchProducts(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      query: query,
    );
    return products.map((model) => model.toEntity()).toList();
  }
}

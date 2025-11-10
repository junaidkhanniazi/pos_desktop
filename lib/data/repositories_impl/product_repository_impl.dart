import 'package:pos_desktop/data/local/dao/product_dao.dart';
import 'package:pos_desktop/data/models/product_model.dart';
import 'package:pos_desktop/domain/entities/store/product_entity.dart';
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
    int? brandId,
  }) async {
    final models = await _productDao.getAllProducts(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    final filtered = brandId == null
        ? models
        : models.where((p) => p.brandId == brandId).toList();

    return filtered.cast<ProductEntity>();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    int? brandId,
  }) async {
    final models = await _productDao.getAllProducts(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    final filtered = models.where((p) {
      final matchCategory = p.categoryId == categoryId;
      final matchBrand = brandId == null ? true : p.brandId == brandId;
      return matchCategory && matchBrand;
    }).toList();

    return filtered.cast<ProductEntity>();
  }

  @override
  Future<ProductEntity?> getProductById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
  }) async {
    final models = await _productDao.getAllProducts(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    try {
      return models.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
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
    int? brandId,
    String? sku,
    double? costPrice,
    int quantity = 0,
    String? barcode,
    String? imageUrl,
  }) async {
    final model = ProductModel(
      categoryId: categoryId,
      brandId: brandId,
      name: name,
      price: price,
      sku: sku,
      costPrice: costPrice,
      quantity: quantity,
      barcode: barcode,
      imageUrl: imageUrl,
      isActive: true,
      isSynced: false,
      createdAt: DateTime.now(),
    );

    return _productDao.insertProduct(
      ownerId,
      ownerName,
      storeId,
      storeName,
      model,
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
    final existing = await getProductById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
    );

    if (existing == null) return;

    final updated = ProductModel(
      id: existing.id,
      categoryId: categoryId,
      brandId: existing.brandId,
      name: name,
      price: price,
      sku: sku ?? existing.sku,
      costPrice: costPrice ?? existing.costPrice,
      quantity: quantity ?? existing.quantity,
      barcode: barcode ?? existing.barcode,
      imageUrl: existing.imageUrl,
      isActive: existing.isActive,
      isSynced: false,
      createdAt: existing.createdAt,
      lastUpdated: DateTime.now(),
    );

    await _productDao.updateProduct(
      ownerId,
      ownerName,
      storeId,
      storeName,
      updated,
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
      ownerId,
      ownerName,
      storeId,
      storeName,
      productId,
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
    final existing = await getProductById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
    );

    if (existing == null) return;

    final updated = ProductModel(
      id: existing.id,
      categoryId: existing.categoryId,
      brandId: existing.brandId,
      name: existing.name,
      price: existing.price,
      sku: existing.sku,
      costPrice: existing.costPrice,
      quantity: newQuantity,
      barcode: existing.barcode,
      imageUrl: existing.imageUrl,
      isActive: existing.isActive,
      isSynced: false,
      createdAt: existing.createdAt,
      lastUpdated: DateTime.now(),
    );

    await _productDao.updateProduct(
      ownerId,
      ownerName,
      storeId,
      storeName,
      updated,
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
    final models = await _productDao.searchProducts(
      ownerId,
      ownerName,
      storeId,
      storeName,
      query,
    );

    return models.cast<ProductEntity>();
  }

  @override
  Future<List<ProductEntity>> getProductsByBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    final models = await _productDao.getAllProducts(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    final filtered = models.where((p) => p.brandId == brandId).toList();

    return filtered.cast<ProductEntity>();
  }
}

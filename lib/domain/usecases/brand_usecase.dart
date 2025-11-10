import 'package:pos_desktop/domain/entities/store/brand_entity.dart';
import 'package:pos_desktop/domain/repositories/brand_repository.dart';

/// Domain-level logic for all brand operations.
class BrandUseCase {
  final BrandRepository _repository;
  BrandUseCase(this._repository);

  /// Get all brands
  Future<List<BrandEntity>> getAll({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) {
    return _repository.getBrands(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
    );
  }

  /// Get brands by category
  Future<List<BrandEntity>> getByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) {
    return _repository.getBrandsByCategory(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
    );
  }

  /// Get single brand
  Future<BrandEntity?> getById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) {
    return _repository.getBrandById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
    );
  }

  /// Add brand
  Future<int> add({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    String? description,
  }) {
    return _repository.insertBrand(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
      name: name,
      description: description,
    );
  }

  /// Update brand
  Future<void> update({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
    required String name,
    String? description,
  }) {
    return _repository.updateBrand(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
      name: name,
      description: description,
    );
  }

  /// Delete brand
  Future<void> delete({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) {
    return _repository.deleteBrand(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
    );
  }

  /// Search brands
  Future<List<BrandEntity>> search({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) {
    return _repository.searchBrands(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      query: query,
    );
  }
}

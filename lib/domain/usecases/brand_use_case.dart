import 'package:pos_desktop/data/models/brands_model.dart';
import 'package:pos_desktop/domain/repositories/brand_repository.dart';

class BrandUseCase {
  final BrandRepository _brandRepository;

  BrandUseCase(this._brandRepository);

  // 🔹 GET ALL BRANDS
  Future<List<BrandModel>> getBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    return await _brandRepository.getBrands(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
    );
  }

  // 🔹 GET BRANDS BY CATEGORY
  Future<List<BrandModel>> getBrandsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    return await _brandRepository.getBrandsByCategory(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
    );
  }

  // 🔹 GET BRAND BY ID
  Future<BrandModel?> getBrandById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    return await _brandRepository.getBrandById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
    );
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
    return await _brandRepository.insertBrand(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
      name: name,
      description: description,
    );
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
    return await _brandRepository.updateBrand(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
      name: name,
      description: description,
    );
  }

  // 🔹 DELETE BRAND
  Future<void> deleteBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    return await _brandRepository.deleteBrand(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
    );
  }

  // 🔹 SEARCH BRANDS
  Future<List<BrandModel>> searchBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) async {
    return await _brandRepository.searchBrands(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      query: query,
    );
  }
}

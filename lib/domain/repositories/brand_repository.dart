import 'package:pos_desktop/data/models/brands_model.dart';

abstract class BrandRepository {
  Future<List<BrandModel>> getBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  });

  Future<List<BrandModel>> getBrandsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  });

  Future<BrandModel?> getBrandById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  });

  Future<int> insertBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    String? description,
  });

  Future<void> updateBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
    required String name,
    String? description,
  });

  Future<void> deleteBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  });

  Future<List<BrandModel>> searchBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  });
}

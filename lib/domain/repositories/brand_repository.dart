import 'package:pos_desktop/domain/entities/store/brand_entity.dart';

abstract class BrandRepository {
  Future<List<BrandEntity>> getBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  });

  Future<List<BrandEntity>> getBrandsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  });

  Future<BrandEntity?> getBrandById({
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

  Future<List<BrandEntity>> searchBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  });
}

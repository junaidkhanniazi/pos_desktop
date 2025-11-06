import 'package:pos_desktop/data/local/dao/brand_dao.dart';
import 'package:pos_desktop/data/models/brands_model.dart';
import 'package:pos_desktop/domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandDao _brandDao;

  BrandRepositoryImpl(this._brandDao);

  @override
  Future<List<BrandModel>> getBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    try {
      return await _brandDao.getBrands(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BrandModel>> getBrandsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    try {
      print('🟡 [Repository] getBrandsByCategory called');
      print('   → categoryId: $categoryId');
      print('   → storeId: $storeId');

      final brands = await _brandDao.getBrandsByCategory(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        categoryId: categoryId,
      );

      print(
        '🟢 [Repository] getBrandsByCategory result: ${brands.length} brands',
      );
      for (var brand in brands) {
        print(
          '   → ${brand.name} (ID: ${brand.id}, category: ${brand.categoryId})',
        );
      }

      return brands;
    } catch (e) {
      print('❌ [Repository] Error in getBrandsByCategory: $e');
      rethrow;
    }
  }

  @override
  Future<BrandModel?> getBrandById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    try {
      return await _brandDao.getBrandById(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        brandId: brandId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
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
      return await _brandDao.insertBrand(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        categoryId: categoryId,
        name: name,
        description: description,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
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
      return await _brandDao.updateBrand(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        brandId: brandId,
        name: name,
        description: description,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    try {
      return await _brandDao.deleteBrand(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        brandId: brandId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BrandModel>> searchBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) async {
    try {
      return await _brandDao.searchBrands(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        query: query,
      );
    } catch (e) {
      rethrow;
    }
  }
}

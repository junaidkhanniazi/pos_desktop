import 'package:pos_desktop/data/local/dao/brand_dao.dart';
import 'package:pos_desktop/data/models/brands_model.dart';
import 'package:pos_desktop/domain/entities/store/brand_entity.dart';
import 'package:pos_desktop/domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandDao _brandDao;

  BrandRepositoryImpl(this._brandDao);

  @override
  Future<List<BrandEntity>> getBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    final models = await _brandDao.getAllBrands(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    // BrandModel extends BrandEntity → cast is safe
    return models.cast<BrandEntity>();
  }

  @override
  Future<List<BrandEntity>> getBrandsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    final models = await _brandDao.getAllBrands(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    final filtered = models.where((b) => b.categoryId == categoryId).toList();

    return filtered.cast<BrandEntity>();
  }

  @override
  Future<BrandEntity?> getBrandById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    final models = await _brandDao.getAllBrands(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    try {
      return models.firstWhere((b) => b.id == brandId);
    } catch (_) {
      return null;
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
    final model = BrandModel(
      categoryId: categoryId,
      name: name,
      description: description,
      isSynced: false,
    );

    return _brandDao.insertBrand(ownerId, ownerName, storeId, storeName, model);
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
    // Load existing
    final existing = await getBrandById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      brandId: brandId,
    );

    if (existing == null) return;

    final updated = BrandModel(
      id: existing.id,
      categoryId: existing.categoryId,
      name: name,
      description: description,
      isSynced: false, // mark as needing sync
      createdAt: existing.createdAt,
      lastUpdated: DateTime.now(),
    );

    await _brandDao.updateBrand(
      ownerId,
      ownerName,
      storeId,
      storeName,
      updated,
    );
  }

  @override
  Future<void> deleteBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    await _brandDao.deleteBrand(
      ownerId,
      ownerName,
      storeId,
      storeName,
      brandId,
    );
  }

  @override
  Future<List<BrandEntity>> searchBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) async {
    final models = await _brandDao.getAllBrands(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    final lower = query.toLowerCase();
    final filtered = models
        .where((b) => (b.name).toLowerCase().contains(lower))
        .toList();

    return filtered.cast<BrandEntity>();
  }
}

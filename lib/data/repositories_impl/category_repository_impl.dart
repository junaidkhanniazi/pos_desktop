import 'package:pos_desktop/data/local/dao/category_dao.dart';
import 'package:pos_desktop/data/models/category__model.dart';
import 'package:pos_desktop/domain/entities/store/category_entity.dart';
import 'package:pos_desktop/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDao _categoryDao;

  CategoryRepositoryImpl(this._categoryDao);

  @override
  Future<List<CategoryEntity>> getCategories({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    final models = await _categoryDao.getAllCategories(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );
    return models.cast<CategoryEntity>();
  }

  @override
  Future<CategoryEntity?> getCategoryById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    final models = await _categoryDao.getAllCategories(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    try {
      return models.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String name,
    String? description,
  }) async {
    final model = CategoryModel(
      name: name,
      description: description,
      isSynced: false,
      createdAt: DateTime.now(),
    );

    return _categoryDao.insertCategory(
      ownerId,
      ownerName,
      storeId,
      storeName,
      model,
    );
  }

  @override
  Future<void> updateCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    String? description,
  }) async {
    final existing = await getCategoryById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
    );

    if (existing == null) return;

    final updated = CategoryModel(
      id: existing.id,
      name: name,
      description: description,
      isSynced: false,
      createdAt: existing.createdAt,
      lastUpdated: DateTime.now(),
    );

    await _categoryDao.updateCategory(
      ownerId,
      ownerName,
      storeId,
      storeName,
      updated,
    );
  }

  @override
  Future<void> deleteCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    await _categoryDao.deleteCategory(
      ownerId,
      ownerName,
      storeId,
      storeName,
      categoryId,
    );
  }
}

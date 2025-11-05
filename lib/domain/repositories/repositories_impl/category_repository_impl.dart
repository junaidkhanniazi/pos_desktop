import 'package:pos_desktop/data/local/dao/category_dao.dart';
import 'package:pos_desktop/data/models/category__model.dart';
import 'package:pos_desktop/domain/entities/category_entity.dart';
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
    final categories = await _categoryDao.getCategories(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
    );
    return categories.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    final category = await _categoryDao.getCategoryById(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
    );
    return category?.toEntity();
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
    return await _categoryDao.insertCategory(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      name: name,
      description: description,
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
    await _categoryDao.updateCategory(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
      name: name,
      description: description,
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
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
    );
  }
}

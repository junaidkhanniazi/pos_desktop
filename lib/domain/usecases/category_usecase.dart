import 'package:pos_desktop/domain/entities/store/category_entity.dart';
import 'package:pos_desktop/domain/repositories/category_repository.dart';

class CategoryUseCase {
  final CategoryRepository _repository;
  CategoryUseCase(this._repository);

  Future<List<CategoryEntity>> getAll({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) => _repository.getCategories(
    storeId: storeId,
    ownerName: ownerName,
    ownerId: ownerId,
    storeName: storeName,
  );

  Future<int> add(
    CategoryEntity e,
    int storeId,
    String ownerName,
    int ownerId,
    String storeName,
  ) => _repository.insertCategory(
    storeId: storeId,
    ownerName: ownerName,
    ownerId: ownerId,
    storeName: storeName,
    name: e.name,
    description: e.description,
  );

  Future<void> update(
    CategoryEntity e,
    int storeId,
    String ownerName,
    int ownerId,
    String storeName,
  ) => _repository.updateCategory(
    storeId: storeId,
    ownerName: ownerName,
    ownerId: ownerId,
    storeName: storeName,
    categoryId: e.id!,
    name: e.name,
    description: e.description,
  );

  Future<void> delete(
    int storeId,
    String ownerName,
    int ownerId,
    String storeName,
    int categoryId,
  ) => _repository.deleteCategory(
    storeId: storeId,
    ownerName: ownerName,
    ownerId: ownerId,
    storeName: storeName,
    categoryId: categoryId,
  );
}

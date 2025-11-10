import 'package:pos_desktop/domain/entities/store/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  });

  Future<CategoryEntity?> getCategoryById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  });

  Future<int> insertCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String name,
    String? description,
  });

  Future<void> updateCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    String? description,
  });

  Future<void> deleteCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  });
}

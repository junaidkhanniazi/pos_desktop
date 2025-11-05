import 'package:pos_desktop/domain/entities/category_entity.dart';
import 'package:pos_desktop/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _categoryRepository;

  GetCategoriesUseCase(this._categoryRepository);

  // 🔹 FIXED - Add required parameters
  Future<List<CategoryEntity>> execute({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    return await _categoryRepository.getCategories(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
    );
  }
}

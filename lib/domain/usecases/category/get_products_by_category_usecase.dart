import 'package:pos_desktop/domain/entities/product_entity.dart';
import 'package:pos_desktop/domain/repositories/product_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductRepository _productRepository;

  GetProductsByCategoryUseCase(this._productRepository);

  Future<List<ProductEntity>> execute({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    return await _productRepository.getProductsByCategory(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
    );
  }
}

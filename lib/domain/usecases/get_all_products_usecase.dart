import 'package:pos_desktop/domain/entities/product_entity.dart';
import 'package:pos_desktop/domain/repositories/product_repository.dart';

class GetAllProductsUseCase {
  final ProductRepository _productRepository;

  GetAllProductsUseCase(this._productRepository);

  Future<List<ProductEntity>> execute({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    return await _productRepository.getProducts(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
    );
  }
}

import 'package:pos_desktop/domain/repositories/product_repository.dart';

class UpdateProductStockUseCase {
  final ProductRepository _repository;

  UpdateProductStockUseCase(this._repository);

  Future<void> execute({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int productId,
    required int newQuantity,
  }) async {
    await _repository.updateProductStock(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      productId: productId,
      newQuantity: newQuantity,
    );
  }
}

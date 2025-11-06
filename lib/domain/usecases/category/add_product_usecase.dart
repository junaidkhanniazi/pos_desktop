import 'package:pos_desktop/domain/repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository _productRepository;

  AddProductUseCase(this._productRepository);

  Future<int> execute({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    required double price,
    String? sku,
    double? costPrice,
    int quantity = 0,
    String? barcode,
    String? imageUrl,
    int? brandId, // Include brandId
  }) async {
    return await _productRepository.insertProduct(
      storeId: storeId,
      ownerName: ownerName,
      ownerId: ownerId,
      storeName: storeName,
      categoryId: categoryId,
      name: name,
      price: price,
      sku: sku,
      costPrice: costPrice,
      quantity: quantity,
      barcode: barcode,
      imageUrl: imageUrl,
      brandId: brandId, // Pass brandId
    );
  }
}

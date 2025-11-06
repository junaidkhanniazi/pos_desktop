import 'package:get/get.dart';
import 'package:pos_desktop/domain/entities/product_entity.dart';
import 'package:pos_desktop/domain/usecases/category/add_product_usecase.dart';
import 'package:pos_desktop/domain/usecases/category/get_products_by_category_usecase.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/domain/usecases/category/update_product_stock_usecase.dart';
import 'package:pos_desktop/domain/usecases/category/get_all_products_usecase.dart';

class ProductController extends GetxController {
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final GetAllProductsUseCase _getAllProductsUseCase;
  final UpdateProductStockUseCase _updateProductStockUseCase;
  final AddProductUseCase _addProductUseCase;

  ProductController(
    this._getProductsByCategoryUseCase,
    this._getAllProductsUseCase,
    this._updateProductStockUseCase,
    this._addProductUseCase, // ✅ ADD THIS
  ) {
    print('🧩 ProductController created');
    print('  ▶ _getProductsByCategoryUseCase: $_getProductsByCategoryUseCase');
    print('  ▶ _getAllProductsUseCase: $_getAllProductsUseCase');
    print('  ▶ _updateProductStockUseCase: $_updateProductStockUseCase');
    print('  ▶ _addProductUseCase: $_addProductUseCase'); // ✅ ADD THIS
  }

  final RxList<ProductEntity> products = <ProductEntity>[].obs;
  final RxList<ProductEntity> filteredProducts = <ProductEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt selectedCategoryId = 0.obs;

  // Load products by category with optional brandId
  Future<void> loadProductsByCategory(int categoryId, {int? brandId}) async {
    try {
      isLoading.value = true;
      error.value = '';
      selectedCategoryId.value = categoryId;

      print('🟡 [ProductController] loadProductsByCategory called');
      print('   → categoryId: $categoryId');
      print('   → brandId: $brandId'); // This might be null!

      await AuthStorageHelper.debugCurrentStore();

      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";
      final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
      final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

      print('   → storeId: $currentStoreId');
      print('   → ownerId: $ownerId');

      if (ownerId != null &&
          currentStoreId != null &&
          currentStoreName != null) {
        final loadedProducts = await _getProductsByCategoryUseCase.execute(
          storeId: currentStoreId,
          ownerName: ownerName,
          ownerId: int.parse(ownerId),
          storeName: currentStoreName,
          categoryId: categoryId,
          brandId: brandId, // Pass brandId here
        );

        print(
          '🟢 [ProductController] Successfully loaded ${loadedProducts.length} products',
        );
        products.value = loadedProducts;
        filteredProducts.value = loadedProducts;
      } else {
        error.value = "Missing store information";
        print('❌ [ProductController] Missing store information');
      }
    } catch (e) {
      error.value = 'Failed to load products: $e';
      print('❌ [ProductController] ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load all products with optional brandId
  Future<void> loadAllProducts({int? brandId}) async {
    try {
      isLoading.value = true;
      error.value = '';
      selectedCategoryId.value = 0;

      await AuthStorageHelper.debugCurrentStore();

      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";
      final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
      final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

      if (ownerId != null &&
          currentStoreId != null &&
          currentStoreName != null) {
        final loadedProducts = await _getAllProductsUseCase.execute(
          storeId: currentStoreId,
          ownerName: ownerName,
          ownerId: int.parse(ownerId),
          storeName: currentStoreName,
          brandId: brandId, // Pass brandId here
        );

        products.value = loadedProducts;
        filteredProducts.value = loadedProducts;
      } else {
        error.value = "Missing store information";
      }
    } catch (e) {
      error.value = 'Failed to load products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Search products
  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                (product.sku?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (product.barcode?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    }
  }

  // Filter products by stock status
  void filterByStockStatus(String status) {
    switch (status) {
      case 'In Stock':
        filteredProducts.value = products
            .where((p) => p.quantity > 10)
            .toList();
        break;
      case 'Low Stock':
        filteredProducts.value = products
            .where((p) => p.quantity > 0 && p.quantity <= 10)
            .toList();
        break;
      case 'Out of Stock':
        filteredProducts.value = products
            .where((p) => p.quantity == 0)
            .toList();
        break;
      default:
        filteredProducts.value = products;
    }
  }

  // Refresh products
  void refreshProducts() {
    if (selectedCategoryId.value == 0) {
      loadAllProducts();
    } else {
      loadProductsByCategory(selectedCategoryId.value);
    }
  }

  // Helper methods
  bool get hasProducts => products.isNotEmpty;
  bool get hasFilteredProducts => filteredProducts.isNotEmpty;

  List<ProductEntity> get productsForCurrentCategory => filteredProducts;

  // Get product by ID
  ProductEntity? getProductById(int productId) {
    try {
      return products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStock(int productId, int newQuantity) async {
    try {
      // 🟩 1. Update local list instantly for fast UI feedback
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updated = products[index];
        products[index] = ProductEntity(
          id: updated.id,
          categoryId: updated.categoryId,
          name: updated.name,
          sku: updated.sku,
          price: updated.price,
          costPrice: updated.costPrice,
          quantity: newQuantity,
          barcode: updated.barcode,
          imageUrl: updated.imageUrl,
          isActive: updated.isActive,
          isSynced: updated.isSynced,
          lastUpdated: DateTime.now(),
          createdAt: updated.createdAt,
        );
        filteredProducts.refresh(); // trigger UI rebuild
      }

      // 🟨 2. Run DB update in background
      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";
      final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
      final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

      if (ownerId != null &&
          currentStoreId != null &&
          currentStoreName != null) {
        await _updateProductStockUseCase.execute(
          storeId: currentStoreId,
          ownerName: ownerName,
          ownerId: int.parse(ownerId),
          storeName: currentStoreName,
          productId: productId,
          newQuantity: newQuantity,
        );
        print("✅ Stock updated in DB for productId=$productId");
      }
    } catch (e) {
      print('❌ ERROR updating stock: $e');
    }
  }

  Future<bool> addProduct({
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
    try {
      isLoading.value = true;
      error.value = '';

      print('🟡 [ProductController] addProduct called');
      print('   → categoryId: $categoryId');
      print('   → name: $name');
      print('   → price: $price');
      print('   → brandId: $brandId'); // Debug brandId

      await AuthStorageHelper.debugCurrentStore();

      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";
      final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
      final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

      if (ownerId != null &&
          currentStoreId != null &&
          currentStoreName != null) {
        final productId = await _addProductUseCase.execute(
          storeId: currentStoreId,
          ownerName: ownerName,
          ownerId: int.parse(ownerId),
          storeName: currentStoreName,
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

        print(
          '🟢 [ProductController] Product added successfully with ID: $productId',
        );

        // Refresh the products list
        await loadProductsByCategory(categoryId, brandId: brandId);

        return true;
      } else {
        error.value = "Missing store information";
        return false;
      }
    } catch (e) {
      error.value = 'Failed to add product: $e';
      print('❌ [ProductController] ERROR adding product: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

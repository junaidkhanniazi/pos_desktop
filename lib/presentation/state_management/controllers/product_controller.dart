import 'package:get/get.dart';
import 'package:pos_desktop/domain/entities/product_entity.dart';
import 'package:pos_desktop/domain/usecases/category/get_products_by_category_usecase.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/domain/usecases/get_all_products_usecase.dart';

class ProductController extends GetxController {
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final GetAllProductsUseCase _getAllProductsUseCase;

  ProductController(
    this._getProductsByCategoryUseCase,
    this._getAllProductsUseCase,
  );

  final RxList<ProductEntity> products = <ProductEntity>[].obs;
  final RxList<ProductEntity> filteredProducts = <ProductEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt selectedCategoryId = 0.obs;

  // Load products by category
  Future<void> loadProductsByCategory(int categoryId) async {
    try {
      isLoading.value = true;
      error.value = '';
      selectedCategoryId.value = categoryId;

      await AuthStorageHelper.debugCurrentStore();

      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";
      final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
      final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

      if (ownerId != null &&
          currentStoreId != null &&
          currentStoreName != null) {
        print(
          "Fetching products for category: $categoryId in store: $currentStoreName",
        );

        final loadedProducts = await _getProductsByCategoryUseCase.execute(
          storeId: currentStoreId,
          ownerName: ownerName,
          ownerId: int.parse(ownerId),
          storeName: currentStoreName,
          categoryId: categoryId,
        );

        products.value = loadedProducts;
        filteredProducts.value = loadedProducts; // Initialize filtered products
        print(
          "Products fetched: ${products.length} products for category $categoryId",
        );
      } else {
        print("❌ Missing required data for loading products");
        error.value = "Missing store information";
      }
    } catch (e) {
      error.value = 'Failed to load products: $e';
      print('❌ ERROR loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load all products
  Future<void> loadAllProducts() async {
    try {
      isLoading.value = true;
      error.value = '';
      selectedCategoryId.value = 0; // 0 means all categories

      await AuthStorageHelper.debugCurrentStore();

      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";
      final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
      final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

      if (ownerId != null &&
          currentStoreId != null &&
          currentStoreName != null) {
        print("Fetching all products for store: $currentStoreName");

        final loadedProducts = await _getAllProductsUseCase.execute(
          storeId: currentStoreId,
          ownerName: ownerName,
          ownerId: int.parse(ownerId),
          storeName: currentStoreName,
        );

        products.value = loadedProducts;
        filteredProducts.value = loadedProducts;
        print("All products fetched: ${products.length} products");
      } else {
        print("❌ Missing required data for loading products");
        error.value = "Missing store information";
      }
    } catch (e) {
      error.value = 'Failed to load products: $e';
      print('❌ ERROR loading products: $e');
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
}

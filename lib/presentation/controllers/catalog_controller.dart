// import 'package:get/get.dart';
// import 'package:logger/logger.dart';

// import 'package:pos_desktop/core/errors/exception_handler.dart';
// import 'package:pos_desktop/domain/entities/store/category_entity.dart';
// import 'package:pos_desktop/domain/entities/store/brand_entity.dart';
// import 'package:pos_desktop/domain/entities/store/product_entity.dart';
// import 'package:pos_desktop/domain/usecases/category_usecase.dart';
// import 'package:pos_desktop/domain/usecases/brand_usecase.dart';
// import 'package:pos_desktop/domain/usecases/product_usecase.dart';

// class CatalogController extends GetxController {
//   final CategoryUseCase _categoryUseCase = Get.find<CategoryUseCase>();
//   final BrandUseCase _brandUseCase = Get.find<BrandUseCase>();
//   final ProductUseCase _productUseCase = Get.find<ProductUseCase>();
//   final Logger _logger = Logger();

//   final categories = <CategoryEntity>[].obs;
//   final brands = <BrandEntity>[].obs;
//   final products = <ProductEntity>[].obs;

//   final selectedCategory = Rxn<CategoryEntity>();
//   final selectedBrand = Rxn<BrandEntity>();

//   final isLoading = false.obs;
//   final errorMessage = RxnString();

//   int? _storeId;

//   // =====================================================
//   // INIT & LOADERS
//   // =====================================================
//   Future<void> initForStore(int storeId) async {
//     _storeId = storeId;
//     await Future.wait([loadCategories(), loadBrands(), loadProducts()]);
//   }

//   Future<void> loadCategories() async {
//     if (_storeId == null) return;
//     try {
//       isLoading.value = true;
//       categories.value = await _categoryUseCase.getAll(_storeId!);
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       errorMessage.value = failure.message;
//       _logger.e('❌ loadCategories error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadBrands() async {
//     if (_storeId == null) return;
//     try {
//       isLoading.value = true;
//       brands.value = await _brandUseCase.getBrands(_storeId!);
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       errorMessage.value = failure.message;
//       _logger.e('❌ loadBrands error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadProducts() async {
//     if (_storeId == null) return;
//     try {
//       isLoading.value = true;
//       products.value = await _productUseCase.getProducts(_storeId!);
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       errorMessage.value = failure.message;
//       _logger.e('❌ loadProducts error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // =====================================================
//   // FILTERS
//   // =====================================================
//   void filterByCategory(CategoryEntity? category) {
//     selectedCategory.value = category;
//   }

//   void filterByBrand(BrandEntity? brand) {
//     selectedBrand.value = brand;
//   }

//   // =====================================================
//   // ADD / UPDATE / DELETE
//   // =====================================================

//   Future<void> addCategory({required int storeId, required String name}) async {
//     try {
//       isLoading.value = true;
//       await _categoryUseCase.addCategory(
//         CategoryEntity(storeId: storeId, name: name),
//       );
//       Get.snackbar('Success', 'Category added successfully');
//       await loadCategories();
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       _logger.e('❌ addCategory error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> addBrand({required int storeId, required String name}) async {
//     try {
//       isLoading.value = true;
//       await _brandUseCase.addBrand(BrandEntity(storeId: storeId, name: name));
//       Get.snackbar('Success', 'Brand added successfully');
//       await loadBrands();
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       _logger.e('❌ addBrand error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> addProduct({
//     required int storeId,
//     required int categoryId,
//     required int brandId,
//     required String name,
//     required double price,
//     int stock = 0,
//   }) async {
//     try {
//       isLoading.value = true;
//       await _productUseCase.addProduct(
//         ProductEntity(
//           storeId: storeId,
//           categoryId: categoryId,
//           brandId: brandId,
//           name: name,
//           price: price,
//           stock: stock,
//         ),
//       );
//       Get.snackbar('Success', 'Product added successfully');
//       await loadProducts();
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       _logger.e('❌ addProduct error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

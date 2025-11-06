import 'package:get/get.dart';

// DAOs
import 'package:pos_desktop/data/local/dao/category_dao.dart';
import 'package:pos_desktop/data/local/dao/product_dao.dart';
import 'package:pos_desktop/data/local/dao/brand_dao.dart'; // ✅ ADD THIS

// Repositories
import 'package:pos_desktop/domain/repositories/category_repository.dart';
import 'package:pos_desktop/domain/repositories/product_repository.dart';
import 'package:pos_desktop/domain/repositories/brand_repository.dart'; // ✅ ADD THIS
import 'package:pos_desktop/domain/repositories/repositories_impl/category_repository_impl.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/product_repository_impl.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/brand_repository_impl.dart'; // ✅ ADD THIS
import 'package:pos_desktop/domain/usecases/category/add_product_usecase.dart';

// UseCases
import 'package:pos_desktop/domain/usecases/category/get_categories_usecase.dart';
import 'package:pos_desktop/domain/usecases/category/get_products_by_category_usecase.dart';
import 'package:pos_desktop/domain/usecases/category/update_product_stock_usecase.dart';
import 'package:pos_desktop/domain/usecases/category/get_all_products_usecase.dart';

// ✅ SINGLE BRAND USE CASE FILE
import 'package:pos_desktop/domain/usecases/brand_use_case.dart';

// Controllers
import 'package:pos_desktop/presentation/state_management/controllers/category_controller.dart';
import 'package:pos_desktop/presentation/state_management/controllers/product_controller.dart';
import 'package:pos_desktop/presentation/state_management/controllers/brand_controller.dart'; // ✅ ADD THIS

void setupDependencies() {
  print('🔄 Setting up dependencies...');

  // ========== DAOs ==========
  Get.lazyPut<CategoryDao>(() => CategoryDao(), fenix: true);
  Get.lazyPut<ProductDao>(() => ProductDao(), fenix: true);
  Get.lazyPut<BrandDao>(() => BrandDao(), fenix: true); // ✅ ADD THIS
  print('✅ CategoryDao registered');
  print('✅ ProductDao registered');
  print('✅ BrandDao registered'); // ✅ ADD THIS

  // ========== REPOSITORIES ==========
  Get.lazyPut<CategoryRepository>(
    () => CategoryRepositoryImpl(Get.find<CategoryDao>()),
    fenix: true,
  );
  Get.lazyPut<ProductRepository>(
    () => ProductRepositoryImpl(Get.find<ProductDao>()),
    fenix: true,
  );
  Get.lazyPut<BrandRepository>(
    () => BrandRepositoryImpl(Get.find<BrandDao>()), // ✅ ADD THIS
    fenix: true,
  );
  Get.lazyPut<AddProductUseCase>(
    () => AddProductUseCase(Get.find<ProductRepository>()),
    fenix: true,
  );

  print('✅ AddProductUseCase registered');
  print('✅ CategoryRepository registered');
  print('✅ ProductRepository registered');
  print('✅ BrandRepository registered'); // ✅ ADD THIS

  // ========== USE CASES ==========
  // Category UseCases
  Get.lazyPut<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(Get.find<CategoryRepository>()),
    fenix: true,
  );
  Get.lazyPut<GetProductsByCategoryUseCase>(
    () => GetProductsByCategoryUseCase(Get.find<ProductRepository>()),
    fenix: true,
  );
  Get.lazyPut<GetAllProductsUseCase>(
    () => GetAllProductsUseCase(Get.find<ProductRepository>()),
    fenix: true,
  );
  Get.lazyPut<UpdateProductStockUseCase>(
    () => UpdateProductStockUseCase(Get.find<ProductRepository>()),
    fenix: true,
  );

  // ✅ SINGLE BRAND USE CASE
  Get.lazyPut<BrandUseCase>(
    () => BrandUseCase(Get.find<BrandRepository>()),
    fenix: true,
  );

  print('✅ GetCategoriesUseCase registered');
  print('✅ GetProductsByCategoryUseCase registered');
  print('✅ GetAllProductsUseCase registered');
  print('✅ UpdateProductStockUseCase registered');
  print('✅ BrandUseCase registered'); // ✅ ADD THIS

  // ========== CONTROLLERS ==========
  Get.lazyPut<CategoryController>(
    () => CategoryController(Get.find<GetCategoriesUseCase>()),
    fenix: true,
  );
  Get.lazyPut<ProductController>(
    () => ProductController(
      Get.find<GetProductsByCategoryUseCase>(),
      Get.find<GetAllProductsUseCase>(),
      Get.find<UpdateProductStockUseCase>(),
      Get.find<AddProductUseCase>(), // ✅ ADD THIS
    ),
    fenix: true,
  );
  Get.lazyPut<BrandController>(
    () => BrandController(Get.find<BrandUseCase>()), // ✅ SIMPLE CONSTRUCTOR
    fenix: true,
  );
  print('✅ CategoryController registered');
  print('✅ ProductController registered');
  print('✅ BrandController registered'); // ✅ ADD THIS

  print('🎉 All dependencies setup complete!');
}

import 'package:get/get.dart';

// DAOs
import 'package:pos_desktop/data/local/dao/category_dao.dart';
import 'package:pos_desktop/data/local/dao/product_dao.dart';

// Repositories
import 'package:pos_desktop/domain/repositories/category_repository.dart';
import 'package:pos_desktop/domain/repositories/product_repository.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/category_repository_impl.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/product_repository_impl.dart';
import 'package:pos_desktop/domain/usecases/category/get_categories_usecase.dart';
import 'package:pos_desktop/domain/usecases/category/get_products_by_category_usecase.dart';

// UseCases
import 'package:pos_desktop/domain/usecases/get_all_products_usecase.dart';

// Controllers
import 'package:pos_desktop/presentation/state_management/controllers/category_controller.dart';
import 'package:pos_desktop/presentation/state_management/controllers/product_controller.dart';

void setupDependencies() {
  print('🔄 Setting up dependencies...');

  // ========== DAOs ==========
  Get.lazyPut<CategoryDao>(() => CategoryDao(), fenix: true);
  Get.lazyPut<ProductDao>(() => ProductDao(), fenix: true);
  print('✅ CategoryDao registered');
  print('✅ ProductDao registered');

  // ========== REPOSITORIES ==========
  Get.lazyPut<CategoryRepository>(
    () => CategoryRepositoryImpl(Get.find<CategoryDao>()),
    fenix: true,
  );
  Get.lazyPut<ProductRepository>(
    () => ProductRepositoryImpl(Get.find<ProductDao>()),
    fenix: true,
  );
  print('✅ CategoryRepository registered');
  print('✅ ProductRepository registered');

  // ========== USE CASES ==========
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
  print('✅ GetCategoriesUseCase registered');
  print('✅ GetProductsByCategoryUseCase registered');
  print('✅ GetAllProductsUseCase registered');

  // ========== CONTROLLERS ==========
  Get.lazyPut<CategoryController>(
    () => CategoryController(Get.find<GetCategoriesUseCase>()),
    fenix: true,
  );
  Get.lazyPut<ProductController>(
    () => ProductController(
      Get.find<GetProductsByCategoryUseCase>(),
      Get.find<GetAllProductsUseCase>(),
    ),
    fenix: true,
  );
  print('✅ CategoryController registered');
  print('✅ ProductController registered');

  print('🎉 All dependencies setup complete!');
}

import 'package:get/get.dart';

// ======================================================
// 🧠 CORE LAYER
// ======================================================
import 'package:pos_desktop/core/storage/shared_prefs_storage.dart';
import 'package:pos_desktop/core/storage/storage_service.dart';

// ======================================================
// 🧩 LOCAL DATABASE (DAO) LAYER
// ======================================================
import 'package:pos_desktop/data/local/dao/brand_dao.dart';
import 'package:pos_desktop/data/local/dao/category_dao.dart';
import 'package:pos_desktop/data/local/dao/product_dao.dart';
import 'package:pos_desktop/data/local/dao/store_dao.dart';
import 'package:pos_desktop/data/local/dao/supplier_dao.dart';
import 'package:pos_desktop/data/local/dao/sync_metadata_dao.dart';

// ======================================================
// 🧱 DATA LAYER - REPOSITORY IMPLEMENTATIONS
// ======================================================
import 'package:pos_desktop/data/repositories_impl/auth_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/owner_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/subscription_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/subscription_plan_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/store_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/category_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/brand_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/product_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/sale_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/customer_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/supplier_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/expense_repository_impl.dart';
import 'package:pos_desktop/data/repositories_impl/sync_repository_impl.dart';

// ======================================================
// 🧠 DOMAIN LAYER - REPOSITORY INTERFACES
// ======================================================
import 'package:pos_desktop/domain/repositories/auth_repository.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';
import 'package:pos_desktop/domain/repositories/subscription_repository.dart';
import 'package:pos_desktop/domain/repositories/subscription_plan_repository.dart';
import 'package:pos_desktop/domain/repositories/store_repository.dart';
import 'package:pos_desktop/domain/repositories/category_repository.dart';
import 'package:pos_desktop/domain/repositories/brand_repository.dart';
import 'package:pos_desktop/domain/repositories/product_repository.dart';
import 'package:pos_desktop/domain/repositories/sale_repository.dart';
import 'package:pos_desktop/domain/repositories/customer_repository.dart';
import 'package:pos_desktop/domain/repositories/supplier_repository.dart';
import 'package:pos_desktop/domain/repositories/expense_repository.dart';
import 'package:pos_desktop/domain/repositories/sync_repository.dart';

// ======================================================
// ⚙️ DOMAIN LAYER - USECASES
// ======================================================
import 'package:pos_desktop/domain/usecases/auth_usecase.dart';
import 'package:pos_desktop/domain/usecases/owner_usecase.dart';
import 'package:pos_desktop/domain/usecases/subscription_usecase.dart';
import 'package:pos_desktop/domain/usecases/store_usecase.dart';
import 'package:pos_desktop/domain/usecases/category_usecase.dart';
import 'package:pos_desktop/domain/usecases/brand_usecase.dart';
import 'package:pos_desktop/domain/usecases/product_usecase.dart';
import 'package:pos_desktop/domain/usecases/sale_usecase.dart';
import 'package:pos_desktop/domain/usecases/customer_usecase.dart';
import 'package:pos_desktop/domain/usecases/supplier_usecase.dart';
import 'package:pos_desktop/domain/usecases/expense_usecase.dart';
import 'package:pos_desktop/domain/usecases/sync_usecase.dart';

Future<void> setupDependencies() async {
  print('🔄 Setting up dependencies...');

  // ======================================================
  // CORE LAYER
  // ======================================================

  // 1️⃣ Initialize SharedPrefs storage first
  final sharedPrefs = SharedPrefsStorage();
  await sharedPrefs.init(); // ✅ this line is critical

  // 2️⃣ Register it with GetX
  Get.put<StorageService>(sharedPrefs, permanent: true);

  // ======================================================
  // LOCAL DATABASE (DAO)
  // ======================================================
  Get.lazyPut<CategoryDao>(() => CategoryDao(), fenix: true);
  Get.lazyPut<BrandDao>(() => BrandDao(), fenix: true);
  Get.lazyPut<ProductDao>(() => ProductDao(), fenix: true);
  Get.lazyPut<StoreDao>(() => StoreDao(), fenix: true);
  Get.lazyPut<SupplierDao>(() => SupplierDao(), fenix: true);
  Get.lazyPut<SyncMetadataDao>(() => SyncMetadataDao(), fenix: true);

  // ======================================================
  // DATA LAYER – REPOSITORY IMPLEMENTATIONS
  // ======================================================
  Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(), fenix: true);
  Get.lazyPut<OwnerRepository>(() => OwnerRepositoryImpl(), fenix: true);
  Get.lazyPut<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(),
    fenix: true,
  );
  Get.lazyPut<SubscriptionPlanRepository>(
    () => SubscriptionPlanRepositoryImpl(),
    fenix: true,
  );

  Get.lazyPut<StoreRepository>(() => StoreRepositoryImpl());
  Get.lazyPut<CategoryRepository>(
    () => CategoryRepositoryImpl(Get.find<CategoryDao>()),
    fenix: true,
  );
  Get.lazyPut<BrandRepository>(
    () => BrandRepositoryImpl(Get.find<BrandDao>()),
    fenix: true,
  );
  Get.lazyPut<ProductRepository>(
    () => ProductRepositoryImpl(Get.find<ProductDao>()),
    fenix: true,
  );
  Get.lazyPut<SupplierRepository>(() => SupplierRepositoryImpl(), fenix: true);
  Get.lazyPut<ExpenseRepository>(() => ExpenseRepositoryImpl(), fenix: true);
  Get.lazyPut<SaleRepository>(() => SaleRepositoryImpl(), fenix: true);
  Get.lazyPut<CustomerRepository>(() => CustomerRepositoryImpl(), fenix: true);
  Get.lazyPut<SyncRepository>(() => SyncRepositoryImpl(), fenix: true);

  // ======================================================
  // DOMAIN LAYER – USECASES
  // ======================================================
  Get.lazyPut<AuthUseCase>(
    () => AuthUseCase(Get.find<AuthRepository>()),
    fenix: true,
  );

  Get.lazyPut<OwnerUseCase>(
    () => OwnerUseCase(Get.find<OwnerRepository>()),
    fenix: true,
  );

  Get.lazyPut<SubscriptionUseCase>(
    () => SubscriptionUseCase(
      Get.find<SubscriptionRepository>(),
      Get.find<SubscriptionPlanRepository>(),
    ),
    fenix: true,
  );

  Get.lazyPut<StoreUseCase>(
    () => StoreUseCase(Get.find<StoreRepository>()),
    fenix: true,
  );

  Get.lazyPut<CategoryUseCase>(
    () => CategoryUseCase(Get.find<CategoryRepository>()),
    fenix: true,
  );

  Get.lazyPut<BrandUseCase>(
    () => BrandUseCase(Get.find<BrandRepository>()),
    fenix: true,
  );

  Get.lazyPut<ProductUseCase>(
    () => ProductUseCase(Get.find<ProductRepository>()),
    fenix: true,
  );

  Get.lazyPut<SaleUseCase>(
    () => SaleUseCase(Get.find<SaleRepository>()),
    fenix: true,
  );

  Get.lazyPut<CustomerUseCase>(
    () => CustomerUseCase(Get.find<CustomerRepository>()),
    fenix: true,
  );

  Get.lazyPut<SupplierUseCase>(
    () => SupplierUseCase(Get.find<SupplierRepository>()),
    fenix: true,
  );

  Get.lazyPut<ExpenseUseCase>(
    () => ExpenseUseCase(Get.find<ExpenseRepository>()),
    fenix: true,
  );

  Get.lazyPut<SyncUseCase>(
    () => SyncUseCase(Get.find<SyncRepository>()),
    fenix: true,
  );

  print('🎉 All dependencies registered successfully!');
  print('✅ Core + DAO + Data + Domain layers fully initialized.');
}

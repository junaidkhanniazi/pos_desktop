import 'package:get/get.dart';
import 'package:pos_desktop/domain/entities/category_entity.dart';
import 'package:pos_desktop/domain/usecases/category/get_categories_usecase.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';

class CategoryController extends GetxController {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoryController(this._getCategoriesUseCase);

  final RxList<CategoryEntity> categories = <CategoryEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      error.value = '';

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
          "Fetching categories for store: $currentStoreName (ID: $currentStoreId)",
        );

        final loadedCategories = await _getCategoriesUseCase.execute(
          storeId: currentStoreId,
          ownerName: ownerName,
          ownerId: int.parse(ownerId),
          storeName: currentStoreName,
        );

        categories.value = loadedCategories;
        print("Categories fetched: ${categories.length} categories");
      } else {
        print("❌ Missing required data for loading categories");
        error.value = "Missing store information";
      }
    } catch (e) {
      error.value = 'Failed to load categories: $e';
      print('❌ ERROR loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 FIXED - Get category ID by index (handle null case)
  int getCategoryId(int index) {
    if (categories.isEmpty || index < 0 || index >= categories.length) {
      return 0; // Return 0 for "All Categories" or invalid index
    }
    return categories[index].id ?? 0; // Handle null case
  }

  // Helper methods for UI
  List<String> get categoryNames {
    List<String> names = ["All Categories"];
    names.addAll(categories.map((cat) => cat.name).toList());
    return names;
  }

  String getCategoryName(int index) {
    if (index == 0) return "All Categories";
    if (categories.isEmpty || index - 1 >= categories.length) {
      return "No Categories";
    }
    return categories[index - 1].name;
  }

  // Refresh method for store switching
  void refreshCategories() {
    loadCategories();
  }

  // Force refresh method
  void forceRefresh() {
    loadCategories();
    update(); // Force UI update
  }

  bool get hasCategories => categories.isNotEmpty;
}

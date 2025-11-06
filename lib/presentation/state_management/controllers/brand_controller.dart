import 'package:get/get.dart';
import 'package:pos_desktop/data/models/brands_model.dart';
import 'package:pos_desktop/domain/usecases/brand_use_case.dart';

class BrandController extends GetxController {
  final BrandUseCase _brandUseCase;

  BrandController(this._brandUseCase);

  // Observables
  var brands = <BrandModel>[].obs;
  var selectedBrand = Rxn<BrandModel>();
  var isLoading = false.obs;
  var error = ''.obs;

  // Fetch all brands
  Future<void> fetchBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final fetchedBrands = await _brandUseCase.getBrands(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
      );
      brands.value = fetchedBrands;
      print('🟢 Loaded ${fetchedBrands.length} brands:');
      for (var b in fetchedBrands) {
        print('   → ${b.name} (category: ${b.categoryId})');
      }
    } catch (e) {
      error.value = 'Error fetching brands: $e';
      print('❌ Error fetching brands: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch brands by category
  Future<void> fetchBrandsByCategory({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      brands.clear();
      final fetchedBrands = await _brandUseCase.getBrandsByCategory(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        categoryId: categoryId,
      );
      brands.value = fetchedBrands;
      print('🟢 Loaded ${fetchedBrands.length} brands:');
      for (var b in fetchedBrands) {
        print('   → ${b.name} (category: ${b.categoryId})');
      }
    } catch (e) {
      error.value = 'Error fetching brands by category: $e';
      print('❌ Error fetching brands by category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new brand
  Future<void> addBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int categoryId,
    required String name,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      final brandId = await _brandUseCase.insertBrand(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        categoryId: categoryId,
        name: name,
        description: description,
      );
      fetchBrands(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
      );
    } catch (e) {
      error.value = 'Error adding brand: $e';
      print('❌ Error adding brand: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update brand
  Future<void> updateBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
    required String name,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _brandUseCase.updateBrand(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        brandId: brandId,
        name: name,
        description: description,
      );
      fetchBrands(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
      );
    } catch (e) {
      error.value = 'Error updating brand: $e';
      print('❌ Error updating brand: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete brand (soft delete)
  Future<void> deleteBrand({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int brandId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _brandUseCase.deleteBrand(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        brandId: brandId,
      );
      fetchBrands(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
      );
    } catch (e) {
      error.value = 'Error deleting brand: $e';
      print('❌ Error deleting brand: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search brands
  Future<void> searchBrands({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String query,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      final searchedBrands = await _brandUseCase.searchBrands(
        storeId: storeId,
        ownerName: ownerName,
        ownerId: ownerId,
        storeName: storeName,
        query: query,
      );
      brands.value = searchedBrands;
    } catch (e) {
      error.value = 'Error searching brands: $e';
      print('❌ Error searching brands: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

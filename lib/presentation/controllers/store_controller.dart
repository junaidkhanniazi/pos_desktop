import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/store/store_entity.dart';
import 'package:pos_desktop/domain/usecases/store_usecase.dart';

class StoreController extends GetxController {
  final StoreUseCase _useCase = Get.find<StoreUseCase>();
  final Logger _logger = Logger();

  final stores = <StoreEntity>[].obs;
  final selectedStore = Rxn<StoreEntity>();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadStoresForOwner(int ownerId) async {
    try {
      isLoading.value = true;
      stores.value = await _useCase.getAll(ownerId);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ loadStoresForOwner error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  void selectStore(StoreEntity store) {
    selectedStore.value = store;
  }

  Future<void> addStore(StoreEntity store) async {
    try {
      isLoading.value = true;
      await _useCase.add(store);
      Get.snackbar('Store Added', 'Store created successfully');
      await loadStoresForOwner(store.ownerId);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ addStore error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStore(int storeId, int ownerId) async {
    try {
      isLoading.value = true;
      await _useCase.delete(storeId);
      Get.snackbar('Store Deleted', 'Store removed successfully');
      await loadStoresForOwner(ownerId);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ deleteStore error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }
}

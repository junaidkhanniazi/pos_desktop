// lib/presentation/state_management/controllers/store_controller.dart
import 'package:get/get.dart';
import 'package:pos_desktop/data/local/dao/store_dao.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';

class StoreController extends GetxController {
  final Rx<StoreModel?> currentStore = Rx<StoreModel?>(null);
  final RxList<StoreModel> allStores = <StoreModel>[].obs;
  final StoreDao _storeDao = StoreDao();

  bool get hasStores => allStores.isNotEmpty;
  bool get hasMultipleStores => allStores.length > 1;

  @override
  void onInit() {
    super.onInit();
    loadStores();
  }

  // CORRECTED VERSION
  Future<void> loadStores() async {
    try {
      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";

      if (ownerId != null) {
        allStores.value = await _storeDao.getAllStores(
          int.parse(ownerId),
          ownerName,
        );
        await _loadCurrentStore();
      }
    } catch (e) {
      print('❌ Error loading stores: $e');
    }
  }

  Future<void> _loadCurrentStore() async {
    final currentStoreId = await AuthStorageHelper.getCurrentStoreId();

    if (currentStoreId != null && allStores.isNotEmpty) {
      final store = allStores.firstWhere(
        (store) => store.id == currentStoreId,
        orElse: () => allStores.first,
      );
      currentStore.value = store;
    } else if (allStores.isNotEmpty) {
      // Set first store as default if none selected
      currentStore.value = allStores.first;
      await AuthStorageHelper.setCurrentStore(allStores.first);
    }
  }

  Future<void> switchStore(StoreModel newStore) async {
    try {
      await AuthStorageHelper.setCurrentStore(newStore);
      currentStore.value = newStore;

      // Notify other parts of the app about store change
      // You can add listeners here for other controllers

      print('✅ Switched to store: ${newStore.storeName}');
    } catch (e) {
      print('❌ Error switching store: $e');
      rethrow;
    }
  }
}

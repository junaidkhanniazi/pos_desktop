import 'package:pos_desktop/domain/entities/store/store_entity.dart';

abstract class StoreRepository {
  Future<List<StoreEntity>> getAllStores(int ownerId);
  Future<StoreEntity?> getStoreById(int storeId);
  Future<int> addStore(StoreEntity store);
  Future<void> updateStore(StoreEntity store);
  Future<void> deleteStore(int storeId);
}

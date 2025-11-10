import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/dao/store_dao.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:pos_desktop/domain/entities/store/store_entity.dart';
import 'package:pos_desktop/domain/repositories/store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  final Logger _logger = Logger();
  final StoreDao _storeDao = StoreDao();

  @override
  Future<List<StoreEntity>> getAllStores(int ownerId) async {
    try {
      final models = await _storeDao.getAllStores(ownerId);
      return models.cast<StoreEntity>();
    } catch (e) {
      _logger.e("❌ Error getting all stores: $e");
      return [];
    }
  }

  @override
  Future<StoreEntity?> getStoreById(int storeId) async {
    try {
      return await _storeDao.getStoreById(storeId);
    } catch (e) {
      _logger.e("❌ Error getting store by ID: $e");
      return null;
    }
  }

  @override
  Future<int> addStore(StoreEntity store) async {
    try {
      final model = StoreModel.fromEntity(store);
      return await _storeDao.insertStore(model);
    } catch (e) {
      _logger.e("❌ Error adding store: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateStore(StoreEntity store) async {
    try {
      final model = StoreModel.fromEntity(store);
      await _storeDao.updateStore(model);
    } catch (e) {
      _logger.e("❌ Error updating store: $e");
    }
  }

  @override
  Future<void> deleteStore(int storeId) async {
    try {
      await _storeDao.deleteStore(storeId);
    } catch (e) {
      _logger.e("❌ Error deleting store: $e");
    }
  }
}

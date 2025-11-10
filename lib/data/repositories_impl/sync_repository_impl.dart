import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/dao/sync_metadata_dao.dart';
import 'package:pos_desktop/data/remote/sync/sync_service.dart';
import 'package:pos_desktop/domain/entities/store/sync_metadata_entity.dart';
import 'package:pos_desktop/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  final Logger _logger = Logger();
  final SyncMetadataDao _metadataDao = SyncMetadataDao();
  final SyncService _syncService = SyncService();

  @override
  Future<SyncMetadataEntity?> getSyncMetadata(int storeId) async {
    try {
      return await _metadataDao.getMetadata(storeId);
    } catch (e) {
      _logger.e("❌ Error fetching sync metadata: $e");
      return null;
    }
  }

  @override
  Future<void> updateLastPush(int storeId, DateTime time) async {
    try {
      await _metadataDao.updateLastPush(storeId, time);
    } catch (e) {
      _logger.e("❌ Error updating last push time: $e");
    }
  }

  @override
  Future<void> updateLastPull(int storeId, DateTime time) async {
    try {
      await _metadataDao.updateLastPull(storeId, time);
    } catch (e) {
      _logger.e("❌ Error updating last pull time: $e");
    }
  }

  @override
  Future<void> pushLocalChanges(int storeId) async {
    try {
      await _syncService.syncAllData();
      await updateLastPush(storeId, DateTime.now());
    } catch (e) {
      _logger.e("❌ Push sync failed: $e");
    }
  }

  @override
  Future<void> pullRemoteChanges(int storeId) async {
    try {
      await _syncService.syncAllData();
      await updateLastPull(storeId, DateTime.now());
    } catch (e) {
      _logger.e("❌ Pull sync failed: $e");
    }
  }
}

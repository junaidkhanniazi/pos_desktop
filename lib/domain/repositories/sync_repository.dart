import 'package:pos_desktop/domain/entities/store/sync_metadata_entity.dart';

abstract class SyncRepository {
  Future<SyncMetadataEntity?> getSyncMetadata(int storeId);
  Future<void> updateLastPush(int storeId, DateTime time);
  Future<void> updateLastPull(int storeId, DateTime time);

  /// Push unsynced local data to the server
  Future<void> pushLocalChanges(int storeId);

  /// Pull remote changes from server to local DB
  Future<void> pullRemoteChanges(int storeId);
}

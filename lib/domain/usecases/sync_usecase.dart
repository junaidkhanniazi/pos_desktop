import 'package:pos_desktop/domain/entities/store/sync_metadata_entity.dart';
import 'package:pos_desktop/domain/repositories/sync_repository.dart';

class SyncUseCase {
  final SyncRepository _repo;
  SyncUseCase(this._repo);

  Future<SyncMetadataEntity?> getMetadata(int storeId) =>
      _repo.getSyncMetadata(storeId);

  Future<void> pushLocalChanges(int storeId) => _repo.pushLocalChanges(storeId);

  Future<void> pullRemoteChanges(int storeId) =>
      _repo.pullRemoteChanges(storeId);
}

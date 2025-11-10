import 'package:pos_desktop/domain/entities/store/store_entity.dart';
import 'package:pos_desktop/domain/repositories/store_repository.dart';

class StoreUseCase {
  final StoreRepository _repository;
  StoreUseCase(this._repository);

  Future<List<StoreEntity>> getAll(int ownerId) =>
      _repository.getAllStores(ownerId);
  Future<int> add(StoreEntity store) => _repository.addStore(store);
  Future<void> update(StoreEntity store) => _repository.updateStore(store);
  Future<void> delete(int id) => _repository.deleteStore(id);
}

import 'package:pos_desktop/domain/entities/store/supplier_entity.dart';
import 'package:pos_desktop/domain/repositories/supplier_repository.dart';

class SupplierUseCase {
  final SupplierRepository _repository;
  SupplierUseCase(this._repository);

  Future<List<SupplierEntity>> getAll(int storeId) =>
      _repository.getAllSuppliers(storeId);
  Future<int> add(SupplierEntity e) => _repository.addSupplier(e);
  Future<void> update(SupplierEntity e) => _repository.updateSupplier(e);
  Future<void> delete(int id) => _repository.deleteSupplier(id);
}

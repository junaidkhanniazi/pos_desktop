import 'package:pos_desktop/domain/entities/store/customer_entity.dart';
import 'package:pos_desktop/domain/repositories/customer_repository.dart';

class CustomerUseCase {
  final CustomerRepository _repository;
  CustomerUseCase(this._repository);

  Future<List<CustomerEntity>> getAll(int storeId) =>
      _repository.getAllCustomers(storeId);
  Future<int> add(CustomerEntity e) => _repository.addCustomer(e);
  Future<void> update(CustomerEntity e) => _repository.updateCustomer(e);
  Future<void> delete(int id) => _repository.deleteCustomer(id);
}

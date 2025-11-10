import 'package:pos_desktop/domain/entities/store/customer_entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getAllCustomers(int storeId);
  Future<CustomerEntity?> getCustomerById(int id);
  Future<int> addCustomer(CustomerEntity customer);
  Future<void> updateCustomer(CustomerEntity customer);
  Future<void> deleteCustomer(int id);
  Future<List<CustomerEntity>> searchCustomers(String query);
}

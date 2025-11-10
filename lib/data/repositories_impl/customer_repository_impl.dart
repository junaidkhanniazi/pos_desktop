import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/dao/customer_dao.dart';
import 'package:pos_desktop/data/models/customer_model.dart';
import 'package:pos_desktop/domain/entities/store/customer_entity.dart';
import 'package:pos_desktop/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final Logger _logger = Logger();
  final CustomerDao _dao = CustomerDao();

  @override
  Future<List<CustomerEntity>> getAllCustomers(int storeId) async {
    try {
      final models = await _dao.getAllCustomers(storeId);
      return models.cast<CustomerEntity>();
    } catch (e) {
      _logger.e("❌ Error fetching customers: $e");
      return [];
    }
  }

  @override
  Future<CustomerEntity?> getCustomerById(int id) async {
    try {
      return await _dao.getCustomerById(id);
    } catch (e) {
      _logger.e("❌ Error fetching customer by ID: $e");
      return null;
    }
  }

  @override
  Future<int> addCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      return await _dao.insertCustomer(model);
    } catch (e) {
      _logger.e("❌ Error adding customer: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      await _dao.updateCustomer(model);
    } catch (e) {
      _logger.e("❌ Error updating customer: $e");
    }
  }

  @override
  Future<void> deleteCustomer(int id) async {
    try {
      await _dao.deleteCustomer(id);
    } catch (e) {
      _logger.e("❌ Error deleting customer: $e");
    }
  }

  @override
  Future<List<CustomerEntity>> searchCustomers(String query) async {
    try {
      final models = await _dao.searchCustomers(query);
      return models.cast<CustomerEntity>();
    } catch (e) {
      _logger.e("❌ Error searching customers: $e");
      return [];
    }
  }
}

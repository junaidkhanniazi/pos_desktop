import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/customer_model.dart';

class CustomerDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 GET ALL CUSTOMERS
  Future<List<CustomerModel>> getCustomers({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query('customers', orderBy: 'name ASC');
      await db.close();
      return data.map((e) => CustomerModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting customers: $e');
      rethrow;
    }
  }

  // 🔹 INSERT CUSTOMER
  Future<int> insertCustomer({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final id = await db.insert('customers', {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      });
      await db.close();
      return id;
    } catch (e) {
      print('❌ ERROR inserting customer: $e');
      rethrow;
    }
  }

  // 🔹 UPDATE CUSTOMER
  Future<void> updateCustomer({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int customerId,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'customers',
        {
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [customerId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR updating customer: $e');
      rethrow;
    }
  }

  // 🔹 DELETE CUSTOMER
  Future<void> deleteCustomer({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int customerId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.delete('customers', where: 'id = ?', whereArgs: [customerId]);
      await db.close();
    } catch (e) {
      print('❌ ERROR deleting customer: $e');
      rethrow;
    }
  }
}

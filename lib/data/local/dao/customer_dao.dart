import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/customer_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CustomerDao {
  final _dbHelper = DatabaseHelper();

  Future<List<CustomerModel>> getAllCustomers(int storeId) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
    final result = await db.query('customers', orderBy: 'id DESC');
    return result.map((e) => CustomerModel.fromMap(e)).toList();
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return CustomerModel.fromMap(result.first);
  }

  Future<int> insertCustomer(CustomerModel model) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    return await db.insert(
      'customers',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCustomer(CustomerModel model) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.update(
      'customers',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteCustomer(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    final result = await db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((e) => CustomerModel.fromMap(e)).toList();
  }
}

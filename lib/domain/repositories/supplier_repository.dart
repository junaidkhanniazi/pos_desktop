import 'package:pos_desktop/domain/entities/store/supplier_entity.dart';

abstract class SupplierRepository {
  Future<List<SupplierEntity>> getAllSuppliers(int storeId);
  Future<SupplierEntity?> getSupplierById(int id);
  Future<int> addSupplier(SupplierEntity supplier);
  Future<void> updateSupplier(SupplierEntity supplier);
  Future<void> deleteSupplier(int id);
}

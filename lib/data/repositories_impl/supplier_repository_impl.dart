import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/dao/supplier_dao.dart';
import 'package:pos_desktop/data/models/supplier_model.dart';
import 'package:pos_desktop/domain/entities/store/supplier_entity.dart';
import 'package:pos_desktop/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final Logger _logger = Logger();
  final SupplierDao _dao = SupplierDao();

  @override
  Future<List<SupplierEntity>> getAllSuppliers(int storeId) async {
    try {
      final models = await _dao.getAllSuppliers(storeId);
      return models.cast<SupplierEntity>();
    } catch (e) {
      _logger.e("❌ Error fetching suppliers: $e");
      return [];
    }
  }

  @override
  Future<SupplierEntity?> getSupplierById(int id) async {
    try {
      return await _dao.getSupplierById(id);
    } catch (e) {
      _logger.e("❌ Error fetching supplier by ID: $e");
      return null;
    }
  }

  @override
  Future<int> addSupplier(SupplierEntity supplier) async {
    try {
      final model = SupplierModel.fromEntity(supplier);
      return await _dao.insertSupplier(model);
    } catch (e) {
      _logger.e("❌ Error adding supplier: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateSupplier(SupplierEntity supplier) async {
    try {
      final model = SupplierModel.fromEntity(supplier);
      await _dao.updateSupplier(model);
    } catch (e) {
      _logger.e("❌ Error updating supplier: $e");
    }
  }

  @override
  Future<void> deleteSupplier(int id) async {
    try {
      await _dao.deleteSupplier(id);
    } catch (e) {
      _logger.e("❌ Error deleting supplier: $e");
    }
  }
}

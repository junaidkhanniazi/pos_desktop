import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/dao/sale_dao.dart';
import 'package:pos_desktop/data/models/sale_model.dart';
import 'package:pos_desktop/data/models/sale_item_model.dart';
import 'package:pos_desktop/domain/entities/store/sale_entity.dart';
import 'package:pos_desktop/domain/entities/store/sale_item_entity.dart';
import 'package:pos_desktop/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Logger _logger = Logger();
  final SaleDao _dao = SaleDao();

  @override
  Future<int> insertSale(SaleEntity sale, List<SaleItemEntity> items) async {
    try {
      final saleModel = SaleModel.fromEntity(sale);
      final itemModels = items.map((e) => SaleItemModel.fromEntity(e)).toList();
      return await _dao.insertSale(saleModel, itemModels);
    } catch (e) {
      _logger.e("❌ Error inserting sale: $e");
      rethrow;
    }
  }

  @override
  Future<List<SaleEntity>> getAllSales(int storeId) async {
    try {
      final models = await _dao.getAllSales(storeId);
      return models.cast<SaleEntity>();
    } catch (e) {
      _logger.e("❌ Error getting all sales: $e");
      return [];
    }
  }

  @override
  Future<SaleEntity?> getSaleById(int saleId) async {
    try {
      return await _dao.getSaleById(saleId);
    } catch (e) {
      _logger.e("❌ Error fetching sale by ID: $e");
      return null;
    }
  }

  @override
  Future<List<SaleItemEntity>> getItemsBySale(int saleId) async {
    try {
      final models = await _dao.getItemsBySale(saleId);
      return models.cast<SaleItemEntity>();
    } catch (e) {
      _logger.e("❌ Error fetching sale items: $e");
      return [];
    }
  }

  @override
  Future<void> deleteSale(int saleId) async {
    try {
      await _dao.deleteSale(saleId);
    } catch (e) {
      _logger.e("❌ Error deleting sale: $e");
    }
  }

  @override
  Future<void> markSaleSynced(int saleId) async {
    try {
      await _dao.markSaleSynced(saleId);
    } catch (e) {
      _logger.e("❌ Error marking sale as synced: $e");
    }
  }

  @override
  Future<List<SaleEntity>> getUnsyncedSales(int storeId) async {
    try {
      final models = await _dao.getUnsyncedSales(storeId);
      return models.cast<SaleEntity>();
    } catch (e) {
      _logger.e("❌ Error getting unsynced sales: $e");
      return [];
    }
  }
}

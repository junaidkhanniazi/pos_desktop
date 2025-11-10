import 'package:pos_desktop/domain/entities/store/sale_entity.dart';
import 'package:pos_desktop/domain/entities/store/sale_item_entity.dart';

abstract class SaleRepository {
  Future<int> insertSale(SaleEntity sale, List<SaleItemEntity> items);
  Future<List<SaleEntity>> getAllSales(int storeId);
  Future<SaleEntity?> getSaleById(int saleId);
  Future<List<SaleItemEntity>> getItemsBySale(int saleId);
  Future<void> deleteSale(int saleId);
  Future<void> markSaleSynced(int saleId);
  Future<List<SaleEntity>> getUnsyncedSales(int storeId);
}

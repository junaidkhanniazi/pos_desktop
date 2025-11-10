import 'package:pos_desktop/domain/entities/store/sale_entity.dart';
import 'package:pos_desktop/domain/entities/store/sale_item_entity.dart';
import 'package:pos_desktop/domain/repositories/sale_repository.dart';

class SaleUseCase {
  final SaleRepository _repository;
  SaleUseCase(this._repository);

  Future<int> add(SaleEntity sale, List<SaleItemEntity> items) =>
      _repository.insertSale(sale, items);

  Future<List<SaleEntity>> getAll(int storeId) =>
      _repository.getAllSales(storeId);

  Future<void> delete(int id) => _repository.deleteSale(id);
}

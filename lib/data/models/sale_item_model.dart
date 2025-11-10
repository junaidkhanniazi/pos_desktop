import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/sale_item_entity.dart';

class SaleItemModel extends SaleItemEntity {
  const SaleItemModel({
    int? id,
    required int saleId,
    required int productId,
    required int quantity,
    required double price,
    required double total,
    bool isSynced = false,
    DateTime? lastUpdated,
  }) : super(
         id: id,
         saleId: saleId,
         productId: productId,
         quantity: quantity,
         price: price,
         total: total,
         isSynced: isSynced,
         lastUpdated: lastUpdated,
       );

  factory SaleItemModel.fromEntity(SaleItemEntity e) => SaleItemModel(
    id: e.id,
    saleId: e.saleId,
    productId: e.productId,
    quantity: e.quantity,
    price: e.price,
    total: e.total,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
  );

  factory SaleItemModel.fromMap(Map<String, dynamic> map) => SaleItemModel(
    id: map['id'] as int?,
    saleId: map['sale_id'] ?? 0,
    productId: map['product_id'] ?? 0,
    quantity: map['quantity'] ?? 0,
    price: (map['price'] ?? 0).toDouble(),
    total: (map['total'] ?? 0).toDouble(),
    isSynced: (map['is_synced'] ?? 0) == 1,
    lastUpdated: map['last_updated'] != null
        ? DateTime.tryParse(map['last_updated'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'sale_id': saleId,
    'product_id': productId,
    'quantity': quantity,
    'price': price,
    'total': total,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
  };

  factory SaleItemModel.fromJson(String source) =>
      SaleItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/sale_entity.dart';

class SaleModel extends SaleEntity {
  const SaleModel({
    int? id,
    required double total,
    required String paymentMethod,
    bool isSynced = false,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : super(
         id: id,
         total: total,
         paymentMethod: paymentMethod,
         isSynced: isSynced,
         lastUpdated: lastUpdated,
         createdAt: createdAt,
       );

  factory SaleModel.fromEntity(SaleEntity e) => SaleModel(
    id: e.id,
    total: e.total,
    paymentMethod: e.paymentMethod,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
    createdAt: e.createdAt,
  );

  factory SaleModel.fromMap(Map<String, dynamic> map) => SaleModel(
    id: map['id'] as int?,
    total: (map['total'] ?? 0).toDouble(),
    paymentMethod: map['payment_method'] ?? '',
    isSynced: (map['is_synced'] ?? 0) == 1,
    lastUpdated: map['last_updated'] != null
        ? DateTime.tryParse(map['last_updated'])
        : null,
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'total': total,
    'payment_method': paymentMethod,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  factory SaleModel.fromJson(String source) =>
      SaleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

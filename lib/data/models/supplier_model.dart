import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/supplier_entity.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    int? id,
    String? name,
    String? contact,
    bool isSynced = false,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : super(
         id: id,
         name: name,
         contact: contact,
         isSynced: isSynced,
         lastUpdated: lastUpdated,
         createdAt: createdAt,
       );

  factory SupplierModel.fromEntity(SupplierEntity e) => SupplierModel(
    id: e.id,
    name: e.name,
    contact: e.contact,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
    createdAt: e.createdAt,
  );

  factory SupplierModel.fromMap(Map<String, dynamic> map) => SupplierModel(
    id: map['id'] as int?,
    name: map['name'],
    contact: map['contact'],
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
    'name': name,
    'contact': contact,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  factory SupplierModel.fromJson(String source) =>
      SupplierModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

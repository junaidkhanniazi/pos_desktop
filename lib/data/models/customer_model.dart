import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    bool isSynced = false,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : super(
         id: id,
         name: name,
         phone: phone,
         email: email,
         address: address,
         isSynced: isSynced,
         lastUpdated: lastUpdated,
         createdAt: createdAt,
       );

  factory CustomerModel.fromEntity(CustomerEntity e) => CustomerModel(
    id: e.id,
    name: e.name,
    phone: e.phone,
    email: e.email,
    address: e.address,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
    createdAt: e.createdAt,
  );

  factory CustomerModel.fromMap(Map<String, dynamic> map) => CustomerModel(
    id: map['id'] as int?,
    name: map['name'],
    phone: map['phone'],
    email: map['email'],
    address: map['address'],
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
    'phone': phone,
    'email': email,
    'address': address,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  factory CustomerModel.fromJson(String source) =>
      CustomerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

import 'dart:convert';
import 'package:pos_desktop/domain/entities/online/owner_entity.dart';

class OwnerModel extends OwnerEntity {
  const OwnerModel({
    required int id,
    required String ownerName,
    required String email,
    required String password,
    required String contact,
    required String status,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
         id: id,
         ownerName: ownerName,
         email: email,
         password: password,
         contact: contact,
         status: status,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory OwnerModel.fromEntity(OwnerEntity e) => OwnerModel(
    id: e.id,
    ownerName: e.ownerName,
    email: e.email,
    password: e.password,
    contact: e.contact,
    status: e.status,
    isActive: e.isActive,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  factory OwnerModel.fromMap(Map<String, dynamic> map) => OwnerModel(
    id: map['id'] ?? 0,
    ownerName: map['owner_name'] ?? '',
    email: map['email'] ?? '',
    password: map['password'] ?? '',
    contact: map['contact'] ?? '',
    status: map['status'] ?? '',
    isActive: (map['is_active'] ?? 0) == 1,
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'])
        : null,
    updatedAt: map['updated_at'] != null
        ? DateTime.tryParse(map['updated_at'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_name': ownerName,
    'email': email,
    'password': password,
    'contact': contact,
    'status': status,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory OwnerModel.fromJson(String source) =>
      OwnerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

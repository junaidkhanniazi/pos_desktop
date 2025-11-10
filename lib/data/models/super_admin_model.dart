import 'dart:convert';
import 'package:pos_desktop/domain/entities/online/super_admin_entity.dart';

class SuperAdminModel extends SuperAdminEntity {
  const SuperAdminModel({
    required int id,
    required String name,
    required String email,
    required String password,
    DateTime? createdAt,
  }) : super(
         id: id,
         name: name,
         email: email,
         password: password,
         createdAt: createdAt,
       );

  factory SuperAdminModel.fromEntity(SuperAdminEntity e) => SuperAdminModel(
    id: e.id,
    name: e.name,
    email: e.email,
    password: e.password,
    createdAt: e.createdAt,
  );

  factory SuperAdminModel.fromMap(Map<String, dynamic> map) => SuperAdminModel(
    id: map['id'] ?? 0,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    password: map['password'] ?? '',
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'created_at': createdAt?.toIso8601String(),
  };

  factory SuperAdminModel.fromJson(String source) =>
      SuperAdminModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

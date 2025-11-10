import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    int? id,
    required String name,
    String? description,
    bool isSynced = false,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : super(
         id: id,
         name: name,
         description: description,
         isSynced: isSynced,
         lastUpdated: lastUpdated,
         createdAt: createdAt,
       );

  factory CategoryModel.fromEntity(CategoryEntity e) => CategoryModel(
    id: e.id,
    name: e.name,
    description: e.description,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
    createdAt: e.createdAt,
  );

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
    id: map['id'] as int?,
    name: map['name'] ?? '',
    description: map['description'],
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
    'description': description,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

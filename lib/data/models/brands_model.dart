import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/brand_entity.dart';

class BrandModel extends BrandEntity {
  const BrandModel({
    int? id,
    int? categoryId,
    required String name,
    String? description,
    bool isSynced = false,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : super(
         id: id,
         categoryId: categoryId,
         name: name,
         description: description,
         isSynced: isSynced,
         lastUpdated: lastUpdated,
         createdAt: createdAt,
       );

  factory BrandModel.fromEntity(BrandEntity e) => BrandModel(
    id: e.id,
    categoryId: e.categoryId,
    name: e.name,
    description: e.description,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
    createdAt: e.createdAt,
  );

  factory BrandModel.fromMap(Map<String, dynamic> map) => BrandModel(
    id: map['id'] as int?,
    categoryId: map['category_id'] as int?,
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
    'category_id': categoryId,
    'name': name,
    'description': description,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  factory BrandModel.fromJson(String source) =>
      BrandModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

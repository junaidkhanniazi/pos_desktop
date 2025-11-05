import 'package:pos_desktop/domain/entities/category_entity.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String? description;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  CategoryModel({
    this.id,
    required this.name,
    this.description,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      isSynced: isSynced,
      lastUpdated: lastUpdated,
      createdAt: createdAt,
    );
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      isSynced: map['is_synced'] ?? 0,
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

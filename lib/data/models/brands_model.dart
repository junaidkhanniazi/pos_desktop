import 'package:pos_desktop/domain/entities/brand_entity.dart';

class BrandModel {
  final int? id;
  final int categoryId;
  final String name;
  final String? description;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  BrandModel({
    this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });

  // Convert BrandModel to Entity
  BrandEntity toEntity() {
    return BrandEntity(
      id: id,
      categoryId: categoryId,
      name: name,
      description: description,
      isSynced: isSynced,
      lastUpdated: lastUpdated,
      createdAt: createdAt,
    );
  }

  // Convert Map to BrandModel (used when reading from DB)
  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'],
      categoryId: map['category_id'],
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

  // Convert BrandModel to Map (used when writing to DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

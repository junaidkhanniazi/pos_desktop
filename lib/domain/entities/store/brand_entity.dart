class BrandEntity {
  final int? id;
  final int? categoryId;
  final String name;
  final String? description;
  final bool isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  const BrandEntity({
    this.id,
    this.categoryId,
    required this.name,
    this.description,
    this.isSynced = false,
    this.lastUpdated,
    this.createdAt,
  });

  factory BrandEntity.fromMap(Map<String, dynamic> map) {
    return BrandEntity(
      id: map['id'],
      categoryId: map['category_id'],
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
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'description': description,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}

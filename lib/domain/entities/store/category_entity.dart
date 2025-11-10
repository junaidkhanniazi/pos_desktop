class CategoryEntity {
  final int? id;
  final String name;
  final String? description;
  final bool isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  const CategoryEntity({
    this.id,
    required this.name,
    this.description,
    this.isSynced = false,
    this.lastUpdated,
    this.createdAt,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? description,
    bool? isSynced,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map['id'],
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
    'name': name,
    'description': description,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}

class CategoryEntity {
  final int? id;
  final String name;
  final String? description;
  final int isActive;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  CategoryEntity({
    this.id,
    required this.name,
    this.description,
    this.isActive = 1,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryEntity &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.isActive == isActive &&
        other.isSynced == isSynced &&
        other.lastUpdated == lastUpdated &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        isActive.hashCode ^
        isSynced.hashCode ^
        lastUpdated.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, description: $description, isActive: $isActive, isSynced: $isSynced, lastUpdated: $lastUpdated, createdAt: $createdAt)';
  }
}

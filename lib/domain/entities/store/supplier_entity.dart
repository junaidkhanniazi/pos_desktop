class SupplierEntity {
  final int? id;
  final String? name;
  final String? contact;
  final bool isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  const SupplierEntity({
    this.id,
    this.name,
    this.contact,
    this.isSynced = false,
    this.lastUpdated,
    this.createdAt,
  });

  factory SupplierEntity.fromMap(Map<String, dynamic> map) {
    return SupplierEntity(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
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
    'contact': contact,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}

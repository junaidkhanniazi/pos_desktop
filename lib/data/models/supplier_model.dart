class SupplierModel {
  final int? id;
  final String name;
  final String? contact;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  SupplierModel({
    this.id,
    required this.name,
    this.contact,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
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
      'contact': contact,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

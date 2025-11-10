class CustomerEntity {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final bool isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  const CustomerEntity({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.isSynced = false,
    this.lastUpdated,
    this.createdAt,
  });

  factory CustomerEntity.fromMap(Map<String, dynamic> map) {
    return CustomerEntity(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
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
    'phone': phone,
    'email': email,
    'address': address,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}

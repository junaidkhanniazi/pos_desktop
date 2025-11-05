class CustomerModel {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  CustomerModel({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
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
      'phone': phone,
      'email': email,
      'address': address,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

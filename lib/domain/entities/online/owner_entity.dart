class OwnerEntity {
  final int id;
  final String ownerName;
  final String email;
  final String password;
  final String contact;
  final String status;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OwnerEntity({
    required this.id,
    required this.ownerName,
    required this.email,
    required this.password,
    required this.contact,
    required this.status,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  OwnerEntity copyWith({
    int? id,
    int? superAdminId,
    String? shopName,
    String? ownerName,
    String? email,
    String? password,
    String? contact,
    String? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OwnerEntity(
      id: id ?? this.id,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      password: password ?? this.password,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory OwnerEntity.fromMap(Map<String, dynamic> map) {
    return OwnerEntity(
      id: map['id'] ?? 0,
      ownerName: map['owner_name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      contact: map['contact'] ?? '',
      status: map['status'] ?? '',
      isActive: (map['is_active'] ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_name': ownerName,
    'email': email,
    'password': password,
    'contact': contact,
    'status': status,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

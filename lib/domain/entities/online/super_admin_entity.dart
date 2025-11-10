class SuperAdminEntity {
  final int id;
  final String name;
  final String email;
  final String password;
  final DateTime? createdAt;

  const SuperAdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.createdAt,
  });

  SuperAdminEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return SuperAdminEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SuperAdminEntity.fromMap(Map<String, dynamic> map) {
    return SuperAdminEntity(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'created_at': createdAt?.toIso8601String(),
  };
}

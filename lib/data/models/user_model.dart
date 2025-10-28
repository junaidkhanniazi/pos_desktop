import 'dart:convert';

class UserModel {
  final int? id;
  final int ownerId;
  final String fullName;
  final String username;
  final String password;
  final String role;
  final String? permissions; // JSON string for role-based permissions
  final bool isActive;
  final String? createdAt;

  UserModel({
    this.id,
    required this.ownerId,
    required this.fullName,
    required this.username,
    required this.password,
    required this.role,
    this.permissions,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int?,
    ownerId: map['owner_id'] as int,
    fullName: map['full_name'] ?? '',
    username: map['username'] ?? '',
    password: map['password'] ?? '',
    role: map['role'] ?? '',
    permissions: map['permissions'],
    isActive: (map['is_active'] ?? 0) == 1,
    createdAt: map['created_at']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'full_name': fullName,
    'username': username,
    'password': password,
    'role': role,
    'permissions': permissions,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt,
  };

  /// Decode permissions JSON → Map
  Map<String, bool> get permissionsMap {
    if (permissions == null || permissions!.isEmpty) return {};
    try {
      final map = json.decode(permissions!) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v == true));
    } catch (_) {
      return {};
    }
  }

  /// Create copy with updated permissions
  UserModel copyWithPermissions(Map<String, bool> map) => UserModel(
    id: id,
    ownerId: ownerId,
    fullName: fullName,
    username: username,
    password: password,
    role: role,
    permissions: json.encode(map),
    isActive: isActive,
    createdAt: createdAt,
  );
}

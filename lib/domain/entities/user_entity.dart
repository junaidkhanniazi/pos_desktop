// Pure domain entity for staff (owner's team)
// No JSON/DB imports here.
class UserEntity {
  final String id;
  final String ownerId;
  final String name;
  final String email;
  final String role; // cashier / accountant / manager ...
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  UserEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? email,
    String? role,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == id &&
          other.ownerId == ownerId &&
          other.name == name &&
          other.email == email &&
          other.role == role &&
          other.isActive == isActive);

  @override
  int get hashCode => Object.hash(id, ownerId, name, email, role, isActive);
}

import 'package:pos_desktop/domain/entities/owner_entity.dart';

class OwnerModel {
  final int? id;
  final int? superAdminId;
  final String shopName;
  final String ownerName;
  final String email;
  final String password;
  final String contact;
  final String? status;
  final bool isActive;
  final String? createdAt;

  OwnerModel({
    this.id,
    this.superAdminId,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.password,
    required this.contact,
    this.status = 'pending',
    this.isActive = false,
    this.createdAt,
  });

  // ------------------------------
  // 🔹 Map <-> Model converters
  // ------------------------------
  factory OwnerModel.fromMap(Map<String, dynamic> map) => OwnerModel(
    id: map['id'] as int?,
    superAdminId: map['super_admin_id'] as int?,
    shopName: map['shop_name'] ?? '',
    ownerName: map['owner_name'] ?? '',
    email: map['email'] ?? '',
    password: map['password'] ?? '',
    contact: map['contact']?.toString() ?? '',
    status: map['status'] ?? 'pending',
    isActive: (map['is_active'] ?? 0) == 1,
    createdAt: map['created_at']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'super_admin_id': superAdminId,
    'shop_name': shopName,
    'owner_name': ownerName,
    'email': email,
    'password': password,
    'contact': contact,
    'status': status,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt,
  };

  // ------------------------------
  // 🔹 Status helpers
  // ------------------------------
  bool get isApproved => status == 'approved' && isActive;
  bool get isPending => status == 'pending';

  // ------------------------------
  // 🔹 Entity mapper
  // ------------------------------
  OwnerEntity toEntity() {
    return OwnerEntity(
      id: id?.toString() ?? '',
      name: ownerName,
      email: email,
      storeName: shopName,
      password: password,
      contact: contact,
      superAdminId: superAdminId?.toString(),
      status: _mapStatus(status),
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
    );
  }

  static OwnerModel fromEntity(OwnerEntity e) {
    return OwnerModel(
      id: int.tryParse(e.id),
      shopName: e.storeName,
      ownerName: e.name,
      email: e.email,
      password: e.password,
      contact: e.contact,
      superAdminId: e.superAdminId != null
          ? int.tryParse(e.superAdminId!)
          : null,
      status: e.status.name,
      isActive: e.status == OwnerStatus.active,
      createdAt: e.createdAt.toIso8601String(),
    );
  }

  static OwnerStatus _mapStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'active':
      case 'approved':
        return OwnerStatus.active;
      case 'suspended':
        return OwnerStatus.suspended;
      case 'rejected':
        return OwnerStatus.rejected;
      default:
        return OwnerStatus.pending;
    }
  }
}

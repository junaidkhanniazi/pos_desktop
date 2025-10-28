class OwnerModel {
  final int? id;
  final int? superAdminId;
  final String shopName;
  final String ownerName;
  final String email;
  final String password;
  final String? contact;
  String? activationCode;
  String? status;
  final bool isActive;
  final String? createdAt;

  OwnerModel({
    this.id,
    this.superAdminId,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.password,
    this.contact,
    this.activationCode,
    this.status = 'pending',
    this.isActive = false,
    this.createdAt,
  });

  factory OwnerModel.fromMap(Map<String, dynamic> map) => OwnerModel(
    id: map['id'] as int?,
    superAdminId: map['super_admin_id'] as int?,
    shopName: map['shop_name'] ?? '',
    ownerName: map['owner_name'] ?? '',
    email: map['email'] ?? '',
    password: map['password'] ?? '',
    contact: map['contact']?.toString(),
    activationCode: map['activation_code']?.toString(),
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
    'activation_code': activationCode,
    'status': status,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt,
  };

  // Helper methods
  bool get isApproved => status == 'approved' && isActive;
  bool get isPending => status == 'pending';
}

import 'package:pos_desktop/domain/entities/owner_entity.dart';

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
  // NEW SUBSCRIPTION FIELDS
  final String? subscriptionPlan;
  final String? receiptImage;
  final String? paymentDate;
  final double? subscriptionAmount;

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
    // NEW SUBSCRIPTION FIELDS
    this.subscriptionPlan,
    this.receiptImage,
    this.paymentDate,
    this.subscriptionAmount,
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
    // NEW SUBSCRIPTION FIELDS
    subscriptionPlan: map['subscription_plan']?.toString(),
    receiptImage: map['receipt_image']?.toString(),
    paymentDate: map['payment_date']?.toString(),
    subscriptionAmount: map['subscription_amount'] != null
        ? double.tryParse(map['subscription_amount'].toString())
        : null,
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
    // NEW SUBSCRIPTION FIELDS
    'subscription_plan': subscriptionPlan,
    'receipt_image': receiptImage,
    'payment_date': paymentDate,
    'subscription_amount': subscriptionAmount,
  };

  // Helper methods
  bool get isApproved => status == 'approved' && isActive;
  bool get isPending => status == 'pending';

  // NEW: Subscription helper
  bool get hasSubscription =>
      subscriptionPlan != null && subscriptionPlan!.isNotEmpty;
  bool get hasReceipt => receiptImage != null && receiptImage!.isNotEmpty;
}

extension OwnerModelMapper on OwnerModel {
  /// Convert DB model → pure domain entity
  OwnerEntity toEntity() {
    return OwnerEntity(
      id: id?.toString() ?? '',
      name: ownerName,
      email: email,
      storeName: shopName,
      status: _mapStatus(status),
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
      // NEW SUBSCRIPTION FIELDS
      subscriptionPlan: subscriptionPlan,
      receiptImage: receiptImage,
      paymentDate: paymentDate != null ? DateTime.tryParse(paymentDate!) : null,
      subscriptionAmount: subscriptionAmount,
    );
  }

  /// Convert domain entity → DB model
  static OwnerModel fromEntity(OwnerEntity e) {
    return OwnerModel(
      id: int.tryParse(e.id),
      shopName: e.storeName,
      ownerName: e.name,
      email: e.email,
      password: '', // domain shouldn't carry password
      status: e.status.name,
      isActive: e.status == OwnerStatus.active,
      createdAt: e.createdAt.toIso8601String(),
      // NEW SUBSCRIPTION FIELDS
      subscriptionPlan: e.subscriptionPlan,
      receiptImage: e.receiptImage,
      paymentDate: e.paymentDate?.toIso8601String(),
      subscriptionAmount: e.subscriptionAmount,
    );
  }

  /// Local helper for converting status text to enum
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

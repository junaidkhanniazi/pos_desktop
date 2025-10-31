import 'package:pos_desktop/domain/entities/owner_entity.dart';

class OwnerModel {
  final int? id;
  final int? superAdminId;
  final String shopName;
  final String ownerName;
  final String email;
  final String password;
  final String contact; // ✅ CHANGED: from String? to String (required)
  String? activationCode;
  String? status;
  final bool isActive;
  final String? createdAt;

  // 🔹 Subscription fields
  final String? subscriptionPlan;
  final String? receiptImage;
  final String? paymentDate;
  final double? subscriptionAmount;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;

  OwnerModel({
    this.id,
    this.superAdminId,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.password,
    required this.contact, // ✅ CHANGED: from optional to required
    this.activationCode,
    this.status = 'pending',
    this.isActive = false,
    this.createdAt,
    this.subscriptionPlan,
    this.receiptImage,
    this.paymentDate,
    this.subscriptionAmount,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
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
    contact: map['contact']?.toString() ?? '', // ✅ FIXED: default empty string
    activationCode: map['activation_code']?.toString(),
    status: map['status'] ?? 'pending',
    isActive: (map['is_active'] ?? 0) == 1,
    createdAt: map['created_at']?.toString(),
    subscriptionPlan: map['subscription_plan']?.toString(),
    receiptImage: map['receipt_image']?.toString(),
    paymentDate: map['payment_date']?.toString(),
    subscriptionAmount: map['subscription_amount'] != null
        ? double.tryParse(map['subscription_amount'].toString())
        : null,
    subscriptionStartDate: map['subscription_start_date']?.toString(),
    subscriptionEndDate: map['subscription_end_date']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'super_admin_id': superAdminId,
    'shop_name': shopName,
    'owner_name': ownerName,
    'email': email,
    'password': password,
    'contact': contact, // ✅ INCLUDED: now this won't be NULL
    'activation_code': activationCode,
    'status': status,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt,
    'subscription_plan': subscriptionPlan,
    'receipt_image': receiptImage,
    'payment_date': paymentDate,
    'subscription_amount': subscriptionAmount,
    'subscription_start_date': subscriptionStartDate,
    'subscription_end_date': subscriptionEndDate,
  };

  // ------------------------------
  // 🔹 Status helpers
  // ------------------------------
  bool get isApproved => status == 'approved' && isActive;
  bool get isPending => status == 'pending';

  // ------------------------------
  // 🔹 Subscription helpers
  // ------------------------------
  bool get hasSubscription =>
      subscriptionPlan != null && subscriptionPlan!.isNotEmpty;
  bool get hasReceipt => receiptImage != null && receiptImage!.isNotEmpty;

  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return false;
    final end = DateTime.tryParse(subscriptionEndDate!);
    if (end == null) return false;
    return DateTime.now().isBefore(end);
  }

  bool get isSubscriptionExpired {
    if (subscriptionEndDate == null) return true;
    final end = DateTime.tryParse(subscriptionEndDate!);
    if (end == null) return true;
    return DateTime.now().isAfter(end);
  }

  bool get isSubscriptionExpiringSoon {
    if (subscriptionEndDate == null) return false;
    final end = DateTime.tryParse(subscriptionEndDate!);
    if (end == null) return false;
    final days = end.difference(DateTime.now()).inDays;
    return days <= 7 && days > 0;
  }
}

extension OwnerModelMapper on OwnerModel {
  OwnerEntity toEntity() {
    return OwnerEntity(
      id: id?.toString() ?? '',
      name: ownerName,
      email: email,
      storeName: shopName,
      password: password, // ✅ ADDED: Missing field
      contact: contact, // ✅ ADDED: Missing field
      superAdminId: superAdminId?.toString(), // ✅ ADDED: Missing field
      status: _mapStatus(status),
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
      activationCode: activationCode, // ✅ ADDED: Missing field
      subscriptionPlan: subscriptionPlan,
      receiptImage: receiptImage,
      paymentDate: paymentDate != null ? DateTime.tryParse(paymentDate!) : null,
      subscriptionAmount: subscriptionAmount,
      subscriptionStartDate:
          subscriptionStartDate !=
              null // ✅ ADDED: Missing field
          ? DateTime.tryParse(subscriptionStartDate!)
          : null,
      subscriptionEndDate: subscriptionEndDate != null
          ? DateTime.tryParse(subscriptionEndDate!)
          : null,
    );
  }

  static OwnerModel fromEntity(OwnerEntity e) {
    return OwnerModel(
      id: int.tryParse(e.id),
      shopName: e.storeName,
      ownerName: e.name,
      email: e.email,
      password: e.password, // ✅ ADDED: Missing field
      contact: e.contact, // ✅ ADDED: Missing field
      superAdminId: e.superAdminId != null
          ? int.tryParse(e.superAdminId!)
          : null, // ✅ ADDED: Missing field
      activationCode: e.activationCode, // ✅ ADDED: Missing field
      status: e.status.name,
      isActive: e.status == OwnerStatus.active,
      createdAt: e.createdAt.toIso8601String(),
      subscriptionPlan: e.subscriptionPlan,
      receiptImage: e.receiptImage,
      paymentDate: e.paymentDate?.toIso8601String(),
      subscriptionAmount: e.subscriptionAmount,
      subscriptionStartDate: e.subscriptionStartDate
          ?.toIso8601String(), // ✅ ADDED: Missing field
      subscriptionEndDate: e.subscriptionEndDate?.toIso8601String(),
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

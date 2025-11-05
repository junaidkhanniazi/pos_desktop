import 'package:pos_desktop/domain/entities/subscription_entity.dart';

class SubscriptionModel {
  final int? id;
  final int ownerId;
  final int? subscriptionPlanId;
  final String? subscriptionPlanName;
  final String status; // inactive, active, expired, cancelled
  final String? receiptImage;
  final String? paymentDate;
  final double? subscriptionAmount;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final String? createdAt;
  final String? updatedAt;

  SubscriptionModel({
    this.id,
    required this.ownerId,
    this.subscriptionPlanId,
    this.subscriptionPlanName,
    this.status = 'inactive',
    this.receiptImage,
    this.paymentDate,
    this.subscriptionAmount,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.createdAt,
    this.updatedAt,
  });

  // ------------------------------
  // 🔹 Map <-> Model converters
  // ------------------------------
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int,
      subscriptionPlanId: map['subscription_plan_id'] as int?,
      subscriptionPlanName: map['subscription_plan_name']?.toString(),
      status: map['status'] ?? 'inactive',
      receiptImage: map['receipt_image']?.toString(),
      paymentDate: map['payment_date']?.toString(),
      subscriptionAmount: map['subscription_amount'] != null
          ? double.tryParse(map['subscription_amount'].toString())
          : null,
      subscriptionStartDate: map['subscription_start_date']?.toString(),
      subscriptionEndDate: map['subscription_end_date']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'subscription_plan_id': subscriptionPlanId,
    'subscription_plan_name': subscriptionPlanName,
    'status': status,
    'receipt_image': receiptImage,
    'payment_date': paymentDate,
    'subscription_amount': subscriptionAmount,
    'subscription_start_date': subscriptionStartDate,
    'subscription_end_date': subscriptionEndDate,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  // ------------------------------
  // 🔹 Status Helpers
  // ------------------------------
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isExpired {
    if (subscriptionEndDate == null) return false;
    final end = DateTime.tryParse(subscriptionEndDate!);
    if (end == null) return false;
    return end.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (subscriptionEndDate == null) return false;
    final end = DateTime.tryParse(subscriptionEndDate!);
    if (end == null) return false;
    final days = end.difference(DateTime.now()).inDays;
    return days <= 7 && days > 0;
  }

  // ------------------------------
  // 🔹 Convert to SubscriptionEntity
  // ------------------------------
  SubscriptionEntity toEntity() {
    return SubscriptionEntity(
      id: id?.toString() ?? '',
      ownerId: ownerId.toString(),
      subscriptionPlanId: subscriptionPlanId?.toString(),
      subscriptionPlanName: subscriptionPlanName,
      status: status,
      receiptImage: receiptImage,
      paymentDate: paymentDate != null ? DateTime.tryParse(paymentDate!) : null,
      subscriptionAmount: subscriptionAmount,
      subscriptionStartDate: subscriptionStartDate != null
          ? DateTime.tryParse(subscriptionStartDate!)
          : null,
      subscriptionEndDate: subscriptionEndDate != null
          ? DateTime.tryParse(subscriptionEndDate!)
          : null,
      createdAt: createdAt != null
          ? DateTime.tryParse(createdAt!)
          : DateTime.now(),
      updatedAt: updatedAt != null
          ? DateTime.tryParse(updatedAt!)
          : DateTime.now(),
    );
  }

  // ------------------------------
  // 🔹 Create from Entity
  // ------------------------------
  static SubscriptionModel fromEntity(SubscriptionEntity e) {
    return SubscriptionModel(
      id: int.tryParse(e.id),
      ownerId: int.tryParse(e.ownerId) ?? 0,
      subscriptionPlanId: e.subscriptionPlanId != null
          ? int.tryParse(e.subscriptionPlanId!)
          : null,
      subscriptionPlanName: e.subscriptionPlanName,
      status: e.status,
      receiptImage: e.receiptImage,
      paymentDate: e.paymentDate?.toIso8601String(),
      subscriptionAmount: e.subscriptionAmount,
      subscriptionStartDate: e.subscriptionStartDate?.toIso8601String(),
      subscriptionEndDate: e.subscriptionEndDate?.toIso8601String(),
      createdAt: e.createdAt?.toIso8601String(),
      updatedAt: e.updatedAt?.toIso8601String(),
    );
  }
}

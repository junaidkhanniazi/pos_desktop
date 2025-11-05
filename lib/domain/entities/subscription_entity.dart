class SubscriptionEntity {
  final String id;
  final String ownerId;
  final String? subscriptionPlanId;
  final String? subscriptionPlanName;
  final String status; // inactive, active, expired, cancelled
  final String? receiptImage;
  final DateTime? paymentDate;
  final double? subscriptionAmount;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubscriptionEntity({
    required this.id,
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

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isExpired => status == 'expired';

  bool get isExpiringSoon {
    if (subscriptionEndDate == null) return false;
    final end = subscriptionEndDate!;
    final days = end.difference(DateTime.now()).inDays;
    return days <= 7 && days > 0;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'subscription_plan_id': subscriptionPlanId,
    'subscription_plan_name': subscriptionPlanName,
    'status': status,
    'receipt_image': receiptImage,
    'payment_date': paymentDate?.toIso8601String(),
    'subscription_amount': subscriptionAmount,
    'subscription_start_date': subscriptionStartDate?.toIso8601String(),
    'subscription_end_date': subscriptionEndDate?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory SubscriptionEntity.fromMap(Map<String, dynamic> map) {
    return SubscriptionEntity(
      id: map['id'].toString(),
      ownerId: map['owner_id'].toString(),
      subscriptionPlanId: map['subscription_plan_id']?.toString(),
      subscriptionPlanName: map['subscription_plan_name']?.toString(),
      status: map['status'] ?? 'inactive',
      receiptImage: map['receipt_image']?.toString(),
      paymentDate: map['payment_date'] != null
          ? DateTime.tryParse(map['payment_date'])
          : null,
      subscriptionAmount: map['subscription_amount'] != null
          ? double.tryParse(map['subscription_amount'].toString())
          : null,
      subscriptionStartDate: map['subscription_start_date'] != null
          ? DateTime.tryParse(map['subscription_start_date'])
          : null,
      subscriptionEndDate: map['subscription_end_date'] != null
          ? DateTime.tryParse(map['subscription_end_date'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }
}

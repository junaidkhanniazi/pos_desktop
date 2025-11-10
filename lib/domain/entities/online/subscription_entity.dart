class SubscriptionEntity {
  final int id;
  final int ownerId;
  final int subscriptionPlanId;
  final String subscriptionPlanName;
  final String status;
  final String? receiptImage;
  final DateTime? paymentDate;
  final double subscriptionAmount;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubscriptionEntity({
    required this.id,
    required this.ownerId,
    required this.subscriptionPlanId,
    required this.subscriptionPlanName,
    required this.status,
    this.receiptImage,
    this.paymentDate,
    required this.subscriptionAmount,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.createdAt,
    this.updatedAt,
  });

  bool get isExpired =>
      subscriptionEndDate != null &&
      DateTime.now().isAfter(subscriptionEndDate!);

  bool get isExpiringSoon =>
      subscriptionEndDate != null &&
      subscriptionEndDate!.difference(DateTime.now()).inDays <= 5;

  factory SubscriptionEntity.fromMap(Map<String, dynamic> map) {
    return SubscriptionEntity(
      id: map['id'] ?? 0,
      ownerId: map['owner_id'] ?? 0,
      subscriptionPlanId: map['subscription_plan_id'] ?? 0,
      subscriptionPlanName: map['subscription_plan_name'] ?? '',
      status: map['status'] ?? '',
      receiptImage: map['receipt_image'],
      paymentDate: map['payment_date'] != null
          ? DateTime.tryParse(map['payment_date'])
          : null,
      subscriptionAmount:
          double.tryParse(map['subscription_amount'].toString()) ?? 0.0,
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
}

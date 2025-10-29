enum OwnerStatus { pending, active, suspended, rejected }

class OwnerEntity {
  final String id;
  final String name;
  final String email;
  final String storeName;
  final OwnerStatus status;
  final DateTime createdAt;
  // NEW SUBSCRIPTION FIELDS
  final String? subscriptionPlan;
  final String? receiptImage;
  final DateTime? paymentDate;
  final double? subscriptionAmount;

  const OwnerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.storeName,
    required this.status,
    required this.createdAt,
    // NEW SUBSCRIPTION FIELDS
    this.subscriptionPlan,
    this.receiptImage,
    this.paymentDate,
    this.subscriptionAmount,
  });

  OwnerEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? storeName,
    OwnerStatus? status,
    DateTime? createdAt,
    // NEW SUBSCRIPTION FIELDS
    String? subscriptionPlan,
    String? receiptImage,
    DateTime? paymentDate,
    double? subscriptionAmount,
  }) {
    return OwnerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      storeName: storeName ?? this.storeName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      // NEW SUBSCRIPTION FIELDS
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      receiptImage: receiptImage ?? this.receiptImage,
      paymentDate: paymentDate ?? this.paymentDate,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
    );
  }

  /// ✅ Small helper to check approval state
  bool get isApproved => status == OwnerStatus.active;

  /// ✅ NEW: Subscription helpers
  bool get hasSubscription =>
      subscriptionPlan != null && subscriptionPlan!.isNotEmpty;
  bool get hasReceipt => receiptImage != null && receiptImage!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnerEntity &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.storeName == storeName &&
          other.status == status &&
          other.createdAt == createdAt &&
          other.subscriptionPlan == subscriptionPlan &&
          other.receiptImage == receiptImage &&
          other.paymentDate == paymentDate &&
          other.subscriptionAmount == subscriptionAmount);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    storeName,
    status,
    createdAt,
    subscriptionPlan,
    receiptImage,
    paymentDate,
    subscriptionAmount,
  );

  @override
  String toString() =>
      'OwnerEntity(id: $id, name: $name, email: $email, store: $storeName, '
      'status: $status, subscription: $subscriptionPlan, hasReceipt: $hasReceipt)';
}

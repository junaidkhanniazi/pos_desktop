enum OwnerStatus { pending, active, suspended, rejected }

class OwnerEntity {
  final String id;
  final String name;
  final String email;
  final String storeName;
  final String password; // ✅ ADDED - Missing field
  final String contact; // ✅ ADDED - Missing field
  final String? superAdminId; // ✅ ADDED - Missing field
  final OwnerStatus status;
  final DateTime createdAt;

  // 🔹 NEW: Activation Code (restored for approval flow)
  final String? activationCode;

  // 🔹 Subscription Fields
  final String? subscriptionPlan;
  final String? receiptImage;
  final DateTime? paymentDate;
  final double? subscriptionAmount;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  const OwnerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.storeName,
    required this.password, // ✅ ADDED
    required this.contact, // ✅ ADDED
    this.superAdminId, // ✅ ADDED
    required this.status,
    required this.createdAt,
    this.activationCode,
    this.subscriptionPlan,
    this.receiptImage,
    this.paymentDate,
    this.subscriptionAmount,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
  });

  // 🔹 CopyWith for immutability
  OwnerEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? storeName,
    String? password, // ✅ ADDED
    String? contact, // ✅ ADDED
    String? superAdminId, // ✅ ADDED
    OwnerStatus? status,
    DateTime? createdAt,
    String? activationCode,
    String? subscriptionPlan,
    String? receiptImage,
    DateTime? paymentDate,
    double? subscriptionAmount,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
  }) {
    return OwnerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      storeName: storeName ?? this.storeName,
      password: password ?? this.password, // ✅ ADDED
      contact: contact ?? this.contact, // ✅ ADDED
      superAdminId: superAdminId ?? this.superAdminId, // ✅ ADDED
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      activationCode: activationCode ?? this.activationCode,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      receiptImage: receiptImage ?? this.receiptImage,
      paymentDate: paymentDate ?? this.paymentDate,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }

  // -----------------------------
  // 🔹 Subscription Logic Helpers
  // -----------------------------
  bool get isApproved => status == OwnerStatus.active;

  bool get hasSubscription =>
      subscriptionPlan != null && subscriptionPlan!.isNotEmpty;

  bool get hasReceipt => receiptImage != null && receiptImage!.isNotEmpty;

  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  bool get isSubscriptionExpired {
    if (subscriptionEndDate == null) return true;
    return DateTime.now().isAfter(subscriptionEndDate!);
  }

  bool get isSubscriptionExpiringSoon {
    if (subscriptionEndDate == null) return false;
    final daysRemaining = subscriptionEndDate!
        .difference(DateTime.now())
        .inDays;
    return daysRemaining <= 7 && daysRemaining > 0;
  }

  /// ✅ Calculate dynamic end date from duration (used during activation)
  DateTime calculateSubscriptionEndDate(int durationDays) {
    final start = subscriptionStartDate ?? DateTime.now();
    return start.add(Duration(days: durationDays));
  }

  // -----------------------------
  // 🔹 Equality + Debugging
  // -----------------------------
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnerEntity &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.storeName == storeName &&
          other.password == password && // ✅ ADDED
          other.contact == contact && // ✅ ADDED
          other.superAdminId == superAdminId && // ✅ ADDED
          other.status == status &&
          other.createdAt == createdAt &&
          other.activationCode == activationCode &&
          other.subscriptionPlan == subscriptionPlan &&
          other.receiptImage == receiptImage &&
          other.paymentDate == paymentDate &&
          other.subscriptionAmount == subscriptionAmount &&
          other.subscriptionStartDate == subscriptionStartDate &&
          other.subscriptionEndDate == subscriptionEndDate);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    storeName,
    password, // ✅ ADDED
    contact, // ✅ ADDED
    superAdminId, // ✅ ADDED
    status,
    createdAt,
    activationCode,
    subscriptionPlan,
    receiptImage,
    paymentDate,
    subscriptionAmount,
    subscriptionStartDate,
    subscriptionEndDate,
  );

  @override
  String toString() =>
      'OwnerEntity(id: $id, name: $name, email: $email, store: $storeName, '
      'password: ${password.isNotEmpty ? "***" : "empty"}, ' // ✅ ADDED
      'contact: $contact, ' // ✅ ADDED
      'superAdminId: $superAdminId, ' // ✅ ADDED
      'status: $status, activationCode: $activationCode, '
      'subscriptionPlan: $subscriptionPlan, '
      'start: $subscriptionStartDate, end: $subscriptionEndDate, '
      'active: $isSubscriptionActive, expiringSoon: $isSubscriptionExpiringSoon)';
}

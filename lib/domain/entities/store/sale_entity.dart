class SaleEntity {
  final int? id;
  final double total;
  final String paymentMethod;
  final bool isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  const SaleEntity({
    this.id,
    required this.total,
    required this.paymentMethod,
    this.isSynced = false,
    this.lastUpdated,
    this.createdAt,
  });

  factory SaleEntity.fromMap(Map<String, dynamic> map) {
    return SaleEntity(
      id: map['id'],
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? '',
      isSynced: (map['is_synced'] ?? 0) == 1,
      lastUpdated: map['last_updated'] != null
          ? DateTime.tryParse(map['last_updated'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'total': total,
    'payment_method': paymentMethod,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}

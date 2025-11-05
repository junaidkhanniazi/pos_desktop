class SaleModel {
  final int? id;
  final double total;
  final String paymentMethod;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  SaleModel({
    this.id,
    required this.total,
    required this.paymentMethod,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      total: map['total']?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] ?? 'Cash',
      isSynced: map['is_synced'] ?? 0,
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'payment_method': paymentMethod,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

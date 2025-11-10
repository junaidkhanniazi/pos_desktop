class SaleItemEntity {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;
  final double total;
  final bool isSynced;
  final DateTime? lastUpdated;

  const SaleItemEntity({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    this.isSynced = false,
    this.lastUpdated,
  });

  factory SaleItemEntity.fromMap(Map<String, dynamic> map) {
    return SaleItemEntity(
      id: map['id'],
      saleId: map['sale_id'] ?? 0,
      productId: map['product_id'] ?? 0,
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      isSynced: (map['is_synced'] ?? 0) == 1,
      lastUpdated: map['last_updated'] != null
          ? DateTime.tryParse(map['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'sale_id': saleId,
    'product_id': productId,
    'quantity': quantity,
    'price': price,
    'total': total,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
  };
}

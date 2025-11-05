class SaleItemModel {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;
  final double total;
  final int isSynced;
  final DateTime? lastUpdated;

  SaleItemModel({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    this.isSynced = 0,
    this.lastUpdated,
  });

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      quantity: map['quantity'] ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      isSynced: map['is_synced'] ?? 0,
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'total': total,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}

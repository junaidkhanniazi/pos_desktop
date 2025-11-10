class ProductEntity {
  final int? id;
  final int? categoryId;
  final int? brandId;
  final String name;
  final String? sku;
  final double price;
  final double? costPrice;
  final int quantity;
  final String? barcode;
  final String? imageUrl;
  final bool isActive;
  final bool isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  const ProductEntity({
    this.id,
    this.categoryId,
    this.brandId,
    required this.name,
    this.sku,
    required this.price,
    this.costPrice,
    required this.quantity,
    this.barcode,
    this.imageUrl,
    this.isActive = true,
    this.isSynced = false,
    this.lastUpdated,
    this.createdAt,
  });

  factory ProductEntity.fromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'],
      categoryId: map['category_id'],
      brandId: map['brand_id'],
      name: map['name'] ?? '',
      sku: map['sku'],
      price: (map['price'] ?? 0).toDouble(),
      costPrice: map['cost_price'] != null
          ? double.tryParse(map['cost_price'].toString())
          : null,
      quantity: map['quantity'] ?? 0,
      barcode: map['barcode'],
      imageUrl: map['image_url'],
      isActive: (map['is_active'] ?? 1) == 1,
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
    'category_id': categoryId,
    'brand_id': brandId,
    'name': name,
    'sku': sku,
    'price': price,
    'cost_price': costPrice,
    'quantity': quantity,
    'barcode': barcode,
    'image_url': imageUrl,
    'is_active': isActive ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}

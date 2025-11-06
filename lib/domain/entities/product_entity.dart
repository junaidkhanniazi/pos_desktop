class ProductEntity {
  final int? id;
  final int categoryId;
  final String name;
  final String? sku;
  final double price;
  final double? costPrice;
  final int quantity;
  final String? barcode;
  final String? imageUrl;
  final int isActive;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;
  final int? brandId; // New field for brand_id

  ProductEntity({
    this.id,
    required this.categoryId,
    required this.name,
    this.sku,
    required this.price,
    this.costPrice,
    this.quantity = 0,
    this.barcode,
    this.imageUrl,
    this.isActive = 1,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
    this.brandId, // Include the brandId in constructor
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductEntity &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.name == name &&
        other.sku == sku &&
        other.price == price &&
        other.costPrice == costPrice &&
        other.quantity == quantity &&
        other.barcode == barcode &&
        other.imageUrl == imageUrl &&
        other.isActive == isActive &&
        other.isSynced == isSynced &&
        other.lastUpdated == lastUpdated &&
        other.createdAt == createdAt &&
        other.brandId == brandId; // Compare brandId
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        name.hashCode ^
        sku.hashCode ^
        price.hashCode ^
        costPrice.hashCode ^
        quantity.hashCode ^
        barcode.hashCode ^
        imageUrl.hashCode ^
        isActive.hashCode ^
        isSynced.hashCode ^
        lastUpdated.hashCode ^
        createdAt.hashCode ^
        brandId.hashCode; // Include brandId in hashCode calculation
  }
}

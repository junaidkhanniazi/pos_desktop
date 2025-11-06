import 'package:pos_desktop/domain/entities/product_entity.dart';

class ProductModel {
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

  ProductModel({
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

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      categoryId: categoryId,
      name: name,
      sku: sku,
      price: price,
      costPrice: costPrice,
      quantity: quantity,
      barcode: barcode,
      imageUrl: imageUrl,
      isActive: isActive,
      isSynced: isSynced,
      lastUpdated: lastUpdated,
      createdAt: createdAt,
      brandId: brandId, // Include brandId when converting to entity
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      sku: map['sku'],
      price: map['price']?.toDouble() ?? 0.0,
      costPrice: map['cost_price']?.toDouble(),
      quantity: map['quantity'] ?? 0,
      barcode: map['barcode'],
      imageUrl: map['image_url'],
      isActive: map['is_active'] ?? 1,
      isSynced: map['is_synced'] ?? 0,
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      brandId: map['brand_id'], // Extract brand_id from the map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'sku': sku,
      'price': price,
      'cost_price': costPrice,
      'quantity': quantity,
      'barcode': barcode,
      'image_url': imageUrl,
      'is_active': isActive,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'brand_id': brandId, // Add brand_id to the map for database operations
    };
  }
}

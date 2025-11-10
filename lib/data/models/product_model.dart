import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    int? id,
    int? categoryId,
    int? brandId,
    required String name,
    String? sku,
    required double price,
    double? costPrice,
    required int quantity,
    String? barcode,
    String? imageUrl,
    bool isActive = true,
    bool isSynced = false,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : super(
         id: id,
         categoryId: categoryId,
         brandId: brandId,
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
       );

  factory ProductModel.fromEntity(ProductEntity e) => ProductModel(
    id: e.id,
    categoryId: e.categoryId,
    brandId: e.brandId,
    name: e.name,
    sku: e.sku,
    price: e.price,
    costPrice: e.costPrice,
    quantity: e.quantity,
    barcode: e.barcode,
    imageUrl: e.imageUrl,
    isActive: e.isActive,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
    createdAt: e.createdAt,
  );

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
    id: map['id'] as int?,
    categoryId: map['category_id'] as int?,
    brandId: map['brand_id'] as int?,
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

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

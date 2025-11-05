import 'dart:convert';

class SubscriptionPlanModel {
  final int? id;
  final String name;
  final int durationDays;
  final double price;

  // ✅ NEW: Limits from DB
  final int maxStores;
  final int maxProducts;
  final int maxCategories;

  final String? features;
  final bool isActive;
  final String? createdAt;

  SubscriptionPlanModel({
    this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    this.features,
    this.isActive = true,
    this.createdAt,
    this.maxStores = 1,
    this.maxProducts = 100,
    this.maxCategories = 10,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    int _toInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    double _toDouble(dynamic v, double fallback) {
      if (v == null) return fallback;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }

    return SubscriptionPlanModel(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      durationDays: _toInt(map['duration_days'], 30),
      price: _toDouble(map['price'], 0.0),

      // ✅ read from DB columns (schema: maxStores, maxProducts, maxCategories)
      maxStores: _toInt(map['maxStores'], 1),
      maxProducts: _toInt(map['maxProducts'], 100),
      maxCategories: _toInt(map['maxCategories'], 10),

      features: map['features']?.toString(),
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: map['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration_days': durationDays,
      'price': price,
      'maxStores': maxStores,
      'maxProducts': maxProducts,
      'maxCategories': maxCategories,
      'features': features,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  // ✅ Simpler: features stored as "item1|item2|item3"
  List<String> get featuresList {
    if (features == null || features!.isEmpty) return [];
    return features!
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

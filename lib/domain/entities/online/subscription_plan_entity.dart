class SubscriptionPlanEntity {
  final int id;
  final String name;
  final int? durationDays;
  final double price;
  final int maxStores;
  final int maxProducts;
  final int maxCategories;
  final String features;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    this.durationDays,
    required this.price,
    required this.maxStores,
    required this.maxProducts,
    required this.maxCategories,
    required this.features,
  });

  factory SubscriptionPlanEntity.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanEntity(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? '',
      durationDays: map['duration_days'] is int
          ? map['duration_days']
          : int.tryParse(map['duration_days']?.toString() ?? '0') ?? 0,
      price: _parseDouble(map['price']), // ✅ Safe conversion
      maxStores: map['maxStores'] is int
          ? map['maxStores']
          : int.tryParse(map['maxStores']?.toString() ?? '0') ?? 0,
      maxProducts: map['maxProducts'] is int
          ? map['maxProducts']
          : int.tryParse(map['maxProducts']?.toString() ?? '0') ?? 0,
      maxCategories: map['maxCategories'] is int
          ? map['maxCategories']
          : int.tryParse(map['maxCategories']?.toString() ?? '0') ?? 0,
      features: map['features']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'duration_days': durationDays,
    'price': price,
    'maxStores': maxStores,
    'maxProducts': maxProducts,
    'maxCategories': maxCategories,
    'features': features,
  };
}

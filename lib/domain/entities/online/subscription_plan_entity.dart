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
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      durationDays: map['duration_days'],
      price: (map['price'] ?? 0).toDouble(),
      maxStores: map['maxStores'] ?? 0,
      maxProducts: map['maxProducts'] ?? 0,
      maxCategories: map['maxCategories'] ?? 0,
      features: map['features'] ?? '',
    );
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

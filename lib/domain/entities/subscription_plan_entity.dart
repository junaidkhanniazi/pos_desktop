class SubscriptionPlanEntity {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;
  final int maxStores;
  final int maxProducts;
  final int maxCategories;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.maxStores,
    required this.maxProducts,
    required this.maxCategories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_days': durationDays,
      'features': features.join('|'),
      'maxStores': maxStores,
      'maxProducts': maxProducts,
      'maxCategories': maxCategories,
    };
  }

  factory SubscriptionPlanEntity.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanEntity(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      durationDays: map['duration_days'],
      features: (map['features'] as String).split('|'),
      maxStores: map['maxStores'] ?? 0,
      maxProducts: map['maxProducts'] ?? 0,
      maxCategories: map['maxCategories'] ?? 0,
    );
  }
}

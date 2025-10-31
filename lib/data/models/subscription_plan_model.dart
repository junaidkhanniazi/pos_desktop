import 'dart:convert';

class SubscriptionPlanModel {
  final int? id;
  final String name;
  final int durationDays;
  final double price;
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
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanModel(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      durationDays: map['duration_days'] ?? 30,
      price: map['price'] != null
          ? double.tryParse(map['price'].toString()) ?? 0.0
          : 0.0,
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
      'features': features,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  List<String> get featuresList {
    if (features == null || features!.isEmpty) return [];
    try {
      // Assuming features is stored as JSON string
      final featuresMap = json.decode(features!);
      if (featuresMap['features'] is List) {
        return List<String>.from(featuresMap['features']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

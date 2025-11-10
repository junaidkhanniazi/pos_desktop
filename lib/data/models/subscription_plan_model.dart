import 'dart:convert';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';

class SubscriptionPlanModel extends SubscriptionPlanEntity {
  const SubscriptionPlanModel({
    required int id,
    required String name,
    int? durationDays,
    required double price,
    required int maxStores,
    required int maxProducts,
    required int maxCategories,
    required String features,
  }) : super(
         id: id,
         name: name,
         durationDays: durationDays,
         price: price,
         maxStores: maxStores,
         maxProducts: maxProducts,
         maxCategories: maxCategories,
         features: features,
       );

  factory SubscriptionPlanModel.fromEntity(SubscriptionPlanEntity e) =>
      SubscriptionPlanModel(
        id: e.id,
        name: e.name,
        durationDays: e.durationDays,
        price: e.price,
        maxStores: e.maxStores,
        maxProducts: e.maxProducts,
        maxCategories: e.maxCategories,
        features: e.features,
      );

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) =>
      SubscriptionPlanModel(
        id: map['id'] ?? 0,
        name: map['name'] ?? '',
        durationDays: map['duration_days'],
        price: (map['price'] ?? 0).toDouble(),
        maxStores: map['maxStores'] ?? 0,
        maxProducts: map['maxProducts'] ?? 0,
        maxCategories: map['maxCategories'] ?? 0,
        features: map['features'] ?? '',
      );

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

  factory SubscriptionPlanModel.fromJson(String source) =>
      SubscriptionPlanModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  String toJson() => json.encode(toMap());
}

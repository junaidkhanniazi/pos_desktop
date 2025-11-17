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

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? '',
      price: _parseDouble(map['price']),
      durationDays: map['duration_days'] is int
          ? map['duration_days']
          : int.tryParse(map['duration_days'].toString()) ?? 0,
      features: map['features'] is String
          ? map['features']
          : map['features']?.toString() ?? '',
      maxStores: map['maxStores'] is int
          ? map['maxStores']
          : int.tryParse(map['maxStores'].toString()) ?? 0,
      maxProducts: map['maxProducts'] is int
          ? map['maxProducts']
          : int.tryParse(map['maxProducts'].toString()) ?? 0,
      maxCategories: map['maxCategories'] is int
          ? map['maxCategories']
          : int.tryParse(map['maxCategories'].toString()) ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_days': durationDays,
      'features': features,
      'maxStores': maxStores,
      'maxProducts': maxProducts,
      'maxCategories': maxCategories,
    };
  }

  factory SubscriptionPlanModel.fromJson(String source) =>
      SubscriptionPlanModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  String toJson() => json.encode(toMap());
}

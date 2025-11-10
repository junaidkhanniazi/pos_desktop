import 'dart:convert';
import 'package:pos_desktop/domain/entities/online/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required int id,
    required int ownerId,
    required int subscriptionPlanId,
    required String subscriptionPlanName,
    required String status,
    String? receiptImage,
    DateTime? paymentDate,
    required double subscriptionAmount,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
         id: id,
         ownerId: ownerId,
         subscriptionPlanId: subscriptionPlanId,
         subscriptionPlanName: subscriptionPlanName,
         status: status,
         receiptImage: receiptImage,
         paymentDate: paymentDate,
         subscriptionAmount: subscriptionAmount,
         subscriptionStartDate: subscriptionStartDate,
         subscriptionEndDate: subscriptionEndDate,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory SubscriptionModel.fromEntity(SubscriptionEntity e) =>
      SubscriptionModel(
        id: e.id,
        ownerId: e.ownerId,
        subscriptionPlanId: e.subscriptionPlanId,
        subscriptionPlanName: e.subscriptionPlanName,
        status: e.status,
        receiptImage: e.receiptImage,
        paymentDate: e.paymentDate,
        subscriptionAmount: e.subscriptionAmount,
        subscriptionStartDate: e.subscriptionStartDate,
        subscriptionEndDate: e.subscriptionEndDate,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) =>
      SubscriptionModel(
        id: map['id'] ?? 0,
        ownerId: map['owner_id'] ?? 0,
        subscriptionPlanId: map['subscription_plan_id'] ?? 0,
        subscriptionPlanName: map['subscription_plan_name'] ?? '',
        status: map['status'] ?? '',
        receiptImage: map['receipt_image'],
        paymentDate: map['payment_date'] != null
            ? DateTime.tryParse(map['payment_date'])
            : null,
        subscriptionAmount:
            double.tryParse((map['subscription_amount'] ?? 0).toString()) ??
            0.0,
        subscriptionStartDate: map['subscription_start_date'] != null
            ? DateTime.tryParse(map['subscription_start_date'])
            : null,
        subscriptionEndDate: map['subscription_end_date'] != null
            ? DateTime.tryParse(map['subscription_end_date'])
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'])
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'])
            : null,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'subscription_plan_id': subscriptionPlanId,
    'subscription_plan_name': subscriptionPlanName,
    'status': status,
    'receipt_image': receiptImage,
    'payment_date': paymentDate?.toIso8601String(),
    'subscription_amount': subscriptionAmount,
    'subscription_start_date': subscriptionStartDate?.toIso8601String(),
    'subscription_end_date': subscriptionEndDate?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

import 'package:pos_desktop/data/models/subscription_model.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:pos_desktop/domain/entities/online/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  List<SubscriptionEntity> _mapList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map((map) => SubscriptionModel.fromMap(map))
        .cast<SubscriptionEntity>()
        .toList();
  }

  @override
  Future<int> addSubscription(SubscriptionEntity subscription) async {
    // Map entity → model → map
    final model = SubscriptionModel(
      id: subscription.id,
      ownerId: subscription.ownerId,
      subscriptionPlanId: subscription.subscriptionPlanId,
      subscriptionPlanName: subscription.subscriptionPlanName,
      status: subscription.status,
      receiptImage: subscription.receiptImage,
      paymentDate: subscription.paymentDate,
      subscriptionAmount: subscription.subscriptionAmount,
      subscriptionStartDate: subscription.subscriptionStartDate,
      subscriptionEndDate: subscription.subscriptionEndDate,
      createdAt: subscription.createdAt,
      updatedAt: subscription.updatedAt,
    );

    final result = await SyncApi.post("subscriptions", model.toMap());

    if (result is Map<String, dynamic> && result['id'] != null) {
      return int.tryParse(result['id'].toString()) ?? 0;
    }

    return 0;
  }

  @override
  Future<List<SubscriptionEntity>> getAllSubscriptions() async {
    final list = await SyncApi.get("subscriptions");
    return _mapList(list);
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptionsByOwner(
    String ownerId,
  ) async {
    final list = await SyncApi.get("subscriptions/owner/$ownerId");
    return _mapList(list);
  }

  @override
  Future<SubscriptionEntity?> getActiveSubscription(String ownerId) async {
    final list = await SyncApi.get("subscriptions/active/$ownerId");
    if (list.isEmpty) return null;

    final first = list.first;
    if (first is! Map<String, dynamic>) return null;

    return SubscriptionModel.fromMap(first);
  }

  @override
  Future<void> updateStatus(String subscriptionId, String status) async {
    await SyncApi.put("subscriptions/$subscriptionId/status", {
      "status": status,
    });
  }

  @override
  Future<void> markExpiredSubscriptions() async {
    await SyncApi.put("subscriptions/mark-expired", {});
  }

  @override
  Future<void> deleteSubscription(String subscriptionId) async {
    await SyncApi.delete("subscriptions/$subscriptionId");
  }
}

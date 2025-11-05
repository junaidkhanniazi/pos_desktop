import 'package:pos_desktop/domain/entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<int> addSubscription(SubscriptionEntity subscription);
  Future<List<SubscriptionEntity>> getAllSubscriptions();
  Future<List<SubscriptionEntity>> getSubscriptionsByOwner(String ownerId);
  Future<SubscriptionEntity?> getActiveSubscription(String ownerId);
  Future<void> updateStatus(String subscriptionId, String status);
  Future<void> markExpiredSubscriptions();
  Future<void> deleteSubscription(String subscriptionId);
}

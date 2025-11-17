import 'package:pos_desktop/domain/entities/online/subscription_entity.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_repository.dart';
import 'package:pos_desktop/domain/repositories/subscription_plan_repository.dart';

class SubscriptionUseCase {
  final SubscriptionRepository _subscriptionRepo;
  final SubscriptionPlanRepository _planRepo;

  SubscriptionUseCase(this._subscriptionRepo, this._planRepo);

  // 🔹 Owner subscriptions
  Future<int> add(SubscriptionEntity entity) =>
      _subscriptionRepo.addSubscription(entity);
  Future<SubscriptionEntity?> getActive(String ownerId) =>
      _subscriptionRepo.getActiveSubscription(ownerId);
  Future<List<SubscriptionEntity>> getByOwner(String ownerId) =>
      _subscriptionRepo.getSubscriptionsByOwner(ownerId);
  Future<void> updateStatus(String id, String status) =>
      _subscriptionRepo.updateStatus(id, status);
  Future<void> markExpired() => _subscriptionRepo.markExpiredSubscriptions();

  // 🔹 Admin plans
  Future<List<SubscriptionPlanEntity>> getPlans() => _planRepo.getActivePlans();
  Future<void> addPlan(Map<String, dynamic> data) => _planRepo.addPlan(data);
  Future<void> updatePlan(String id, Map<String, dynamic> data) =>
      _planRepo.updatePlan(id, data);
  Future<void> deletePlan(String id) => _planRepo.deletePlan(id);
}

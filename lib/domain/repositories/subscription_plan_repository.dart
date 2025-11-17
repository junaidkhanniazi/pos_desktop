// domain/repositories/subscription_plan_repository.dart

import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';

abstract class SubscriptionPlanRepository {
  Future<List<SubscriptionPlanEntity>> getActivePlans();
  Future<void> addPlan(Map<String, dynamic> data);
  Future<void> updatePlan(String id, Map<String, dynamic> data);
  Future<void> deletePlan(String id);
}

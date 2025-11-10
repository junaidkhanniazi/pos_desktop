import 'package:pos_desktop/data/models/subscription_plan_model.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_plan_repository.dart';

class SubscriptionPlanRepositoryImpl implements SubscriptionPlanRepository {
  @override
  Future<List<SubscriptionPlanEntity>> getActivePlans() async {
    // If you have a dedicated "active" endpoint, e.g. "subscription-plans/active"
    // you can change this string accordingly.
    final list = await SyncApi.get("subscription-plans");

    final models = list
        .whereType<Map<String, dynamic>>()
        .map((map) => SubscriptionPlanModel.fromMap(map))
        .toList();

    // SubscriptionPlanModel extends SubscriptionPlanEntity → cast is safe
    return models.cast<SubscriptionPlanEntity>();
  }

  @override
  Future<void> initializeDefaultPlans() async {
    // Optional seeding endpoint on your backend.
    // If you don't need this, this can be a no-op or removed from the interface.
    await SyncApi.post("subscription-plans/init", {});
  }
}

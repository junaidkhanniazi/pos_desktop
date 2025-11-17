import 'package:logger/logger.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/errors/failure.dart';
import 'package:pos_desktop/data/models/subscription_plan_model.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_plan_repository.dart';

class SubscriptionPlanRepositoryImpl implements SubscriptionPlanRepository {
  final Logger _logger = Logger();

  @override
  Future<List<SubscriptionPlanEntity>> getActivePlans() async {
    try {
      final list = await SyncApi.get("subscription-plans");

      final models = list
          .whereType<Map<String, dynamic>>()
          .map((map) => SubscriptionPlanModel.fromMap(map))
          .toList();

      _logger.i("✅ Loaded ${models.length} subscription plans from server.");
      return models.cast<SubscriptionPlanEntity>();
    } catch (e) {
      // ✅ Don't double-wrap Failure
      if (e is Failure) ;
      final failure = ExceptionHandler.handle(e);
      _logger.e("❌ Failed to fetch plans: ${failure.message}");
      throw failure;
    }
  }

  // 🔹 CREATE plan
  @override
  Future<void> addPlan(Map<String, dynamic> data) async {
    try {
      await SyncApi.post("subscription-plans", data);
      _logger.i("✅ Plan created successfully");
    } catch (e) {
      if (e is Failure) ;
      final failure = ExceptionHandler.handle(e);
      _logger.e("❌ Failed to add plan: ${failure.message}");
      throw failure;
    }
  }

  // 🔹 UPDATE plan
  @override
  Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    try {
      await SyncApi.put("subscription-plans/$id", data);
      _logger.i("✅ Plan updated (ID: $id)");
    } catch (e) {
      if (e is Failure) ;
      final failure = ExceptionHandler.handle(e);
      _logger.e("❌ Failed to update plan: ${failure.message}");
      throw failure;
    }
  }

  // 🔹 DELETE plan
  @override
  Future<void> deletePlan(String id) async {
    try {
      await SyncApi.delete("subscription-plans/$id");
      _logger.w("🗑️ Plan deleted (ID: $id)");
    } catch (e) {
      if (e is Failure) ;
      final failure = ExceptionHandler.handle(e);
      _logger.e("❌ Failed to delete plan: ${failure.message}");
      throw failure;
    }
  }
}

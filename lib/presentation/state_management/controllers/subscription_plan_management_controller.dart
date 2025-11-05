import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';
import 'package:pos_desktop/data/local/dao/subscription_plan_dao.dart';

class SubscriptionPlanManagementController extends GetxController {
  final SubscriptionPlanDao dao;
  final BuildContext context;
  final _logger = Logger();

  var isLoading = false.obs;
  var plans = <SubscriptionPlanEntity>[].obs;

  SubscriptionPlanManagementController({
    required this.dao,
    required this.context,
  });

  /// 🔹 Load all plans
  Future<void> loadPlans() async {
    try {
      isLoading.value = true;
      final allPlans = await dao.getAllActivePlans();
      plans.assignAll(allPlans);
      _logger.i('✅ Loaded ${plans.length} subscription plans');
    } catch (e) {
      _logger.e('❌ Failed to load plans: $e');
      AppToast.show(
        context,
        message: "Failed to load subscription plans",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Add new plan
  Future<void> addPlan(SubscriptionPlanEntity plan) async {
    try {
      await dao.insertPlan(plan);
      await loadPlans();
      AppToast.show(
        context,
        message: "Plan '${plan.name}' added successfully",
        type: ToastType.success,
      );
    } catch (e) {
      _logger.e('❌ Failed to add plan: $e');
      AppToast.show(
        context,
        message: "Failed to add plan",
        type: ToastType.error,
      );
    }
  }

  /// 🔹 Edit/update plan
  Future<void> editPlan(SubscriptionPlanEntity plan) async {
    try {
      // await dao.updatePlan(plan);
      await loadPlans();
      AppToast.show(
        context,
        message: "Plan '${plan.name}' updated successfully",
        type: ToastType.success,
      );
    } catch (e) {
      _logger.e('❌ Failed to update plan: $e');
      AppToast.show(
        context,
        message: "Failed to update plan",
        type: ToastType.error,
      );
    }
  }

  /// 🔹 Delete plan
  Future<void> deletePlan(int planId) async {
    try {
      await dao.deletePlan(planId);
      await loadPlans();
      AppToast.show(
        context,
        message: "Plan deleted successfully",
        type: ToastType.success,
      );
    } catch (e) {
      _logger.e('❌ Failed to delete plan: $e');
      AppToast.show(
        context,
        message: "Failed to delete plan",
        type: ToastType.error,
      );
    }
  }
}

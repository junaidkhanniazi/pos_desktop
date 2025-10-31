import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/data/local/dao/subscription_plan_dao.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';

class SubscriptionManagementController extends GetxController {
  final SubscriptionPlanDao _dao;
  final BuildContext context;

  SubscriptionManagementController(this._dao, this.context);

  /// Observable list of plans
  var plans = <SubscriptionPlanEntity>[].obs;

  /// Loading state
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔄 Controller onInit called');
    loadPlans();
  }

  /// Load all active subscription plans from DB
  Future<void> loadPlans() async {
    try {
      print('🔄 Loading plans from database...');
      isLoading.value = true;
      final result = await _dao.getAllActivePlans();
      print('✅ Plans loaded: ${result.length}');

      for (final plan in result) {
        print('   - ${plan.name}: ${plan.price}');
      }

      plans.value = result;
    } catch (e) {
      print('❌ Error loading plans: $e');
      AppToast.show(
        context,
        message: ExceptionHandler.handle(e).message,
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
      print('🏁 Loading completed');
    }
  }

  /// Add a new plan
  Future<void> addPlan(SubscriptionPlanEntity plan) async {
    try {
      isLoading.value = true;
      await _dao.insertPlan(plan);
      await loadPlans();
      AppToast.show(
        context,
        message: 'Plan added successfully',
        type: ToastType.success,
      );
    } catch (e) {
      AppToast.show(
        context,
        message: ExceptionHandler.handle(e).message,
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Edit an existing plan
  Future<void> editPlan(SubscriptionPlanEntity plan) async {
    try {
      isLoading.value = true;
      await _dao.insertPlan(plan); // Replace existing plan by id
      await loadPlans();
      AppToast.show(
        context,
        message: 'Plan updated successfully',
        type: ToastType.success,
      );
    } catch (e) {
      AppToast.show(
        context,
        message: ExceptionHandler.handle(e).message,
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a plan
  Future<void> deletePlan(int planId) async {
    try {
      isLoading.value = true;
      await _dao.deletePlan(planId);
      await loadPlans();
      AppToast.show(
        context,
        message: 'Plan deleted successfully',
        type: ToastType.success,
      );
    } catch (e) {
      AppToast.show(
        context,
        message: ExceptionHandler.handle(e).message,
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

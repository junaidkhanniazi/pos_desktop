import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/domain/usecases/subscription_usecase.dart';

class SubscriptionPlanController extends GetxController {
  final SubscriptionUseCase _useCase = Get.find<SubscriptionUseCase>();
  final Logger _logger = Logger();

  final plans = <SubscriptionPlanEntity>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  Future<void> loadPlans() async {
    try {
      isLoading.value = true;
      error.value = null;
      final data = await _useCase.getPlans();
      plans.assignAll(data);
      _logger.i("✅ Loaded ${plans.length} plans");
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      error.value = failure.message;
      _logger.e("❌ Failed to load plans: ${failure.message}");
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPlan(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _useCase.addPlan(data);
      await loadPlans();
      Get.snackbar('Success', 'Plan created successfully');
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _useCase.updatePlan(id, data);
      await loadPlans();
      Get.snackbar('Updated', 'Plan updated successfully');
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      isLoading.value = true;
      await _useCase.deletePlan(id);
      await loadPlans();
      Get.snackbar('Deleted', 'Plan deleted successfully');
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }
}

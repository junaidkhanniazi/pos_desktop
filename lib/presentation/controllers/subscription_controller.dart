// import 'package:get/get.dart';
// import 'package:logger/logger.dart';

// import 'package:pos_desktop/core/errors/exception_handler.dart';
// import 'package:pos_desktop/domain/entities/online/subscription_entity.dart';
// import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
// import 'package:pos_desktop/domain/usecases/subscription_usecase.dart';

// class SubscriptionController extends GetxController {
//   final SubscriptionUseCase _useCase = Get.find<SubscriptionUseCase>();
//   final Logger _logger = Logger();

//   final plans = <SubscriptionPlanEntity>[].obs;
//   final subscriptions = <SubscriptionEntity>[].obs;
//   final activeSubscription = Rxn<SubscriptionEntity>();

//   final isLoading = false.obs;
//   final errorMessage = RxnString();

//   Future<void> loadPlans() async {
//     try {
//       isLoading.value = true;
//       plans.value = await _useCase.getPlans();
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       errorMessage.value = failure.message;
//       _logger.e('❌ loadPlans error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadSubscriptionsForOwner(String ownerId) async {
//     try {
//       isLoading.value = true;
//       subscriptions.value = await _useCase.getByOwner(ownerId);
//       activeSubscription.value = await _useCase.getActive(ownerId);
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       errorMessage.value = failure.message;
//       _logger.e('❌ loadSubscriptionsForOwner error: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> addSubscription(SubscriptionEntity sub) async {
//     try {
//       isLoading.value = true;
//       await _useCase.add(sub);
//       Get.snackbar('Success', 'Subscription added');
//       await loadSubscriptionsForOwner(sub.ownerId.toString());
//     } catch (e) {
//       final failure = ExceptionHandler.handle(e);
//       _logger.e('❌ addSubscription error: $e');
//       Get.snackbar('Error', failure.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

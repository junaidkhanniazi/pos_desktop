import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/online/owner_entity.dart';
import 'package:pos_desktop/domain/usecases/owner_usecase.dart';

class OwnerController extends GetxController {
  final OwnerUseCase _useCase = Get.find<OwnerUseCase>();
  final Logger _logger = Logger();

  final owners = <OwnerEntity>[].obs;
  final pendingOwners = <OwnerEntity>[].obs;
  final selectedOwner = Rxn<OwnerEntity>();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPendingOwners();
  }

  Future<void> loadAllOwners() async {
    try {
      isLoading.value = true;
      owners.value = await _useCase.getAll();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ loadAllOwners error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingOwners() async {
    try {
      isLoading.value = true;
      pendingOwners.value = await _useCase.getPending();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ loadPendingOwners error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOwner(OwnerEntity owner) async {
    try {
      isLoading.value = true;
      await _useCase.addOwner(owner);
      Get.snackbar('Owner Added', 'Owner request submitted successfully');
      await loadPendingOwners();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      Get.snackbar('Error', failure.message);
      _logger.e('❌ addOwner error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveOwner(String ownerId, int durationDays) async {
    try {
      isLoading.value = true;
      await _useCase.activateOwner(ownerId, durationDays);
      Get.snackbar('Owner Activated', 'The owner has been activated');
      await loadPendingOwners();
      await loadAllOwners();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      Get.snackbar('Error', failure.message);
      _logger.e('❌ approveOwner error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectOwner(int ownerId) async {
    try {
      isLoading.value = true;
      await _useCase.rejectOwner(ownerId);
      Get.snackbar('Owner Rejected', 'The owner request was rejected');
      await loadPendingOwners();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      Get.snackbar('Error', failure.message);
      _logger.e('❌ rejectOwner error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

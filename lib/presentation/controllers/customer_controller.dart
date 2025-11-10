import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/store/customer_entity.dart';
import 'package:pos_desktop/domain/usecases/customer_usecase.dart';

class CustomerController extends GetxController {
  final CustomerUseCase _useCase = Get.find<CustomerUseCase>();
  final Logger _logger = Logger();

  final customers = <CustomerEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  int? _storeId;

  Future<void> init(int storeId) async {
    _storeId = storeId;
    await loadCustomers();
  }

  Future<void> loadCustomers() async {
    if (_storeId == null) return;
    try {
      isLoading.value = true;
      customers.value = await _useCase.getAll(_storeId!);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ loadCustomers error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCustomer(CustomerEntity customer) async {
    try {
      await _useCase.add(customer);
      Get.snackbar('Customer Added', 'Customer saved successfully');
      await loadCustomers();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ addCustomer error: $e');
      Get.snackbar('Error', failure.message);
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _useCase.delete(id);
      Get.snackbar('Customer Deleted', 'Customer removed successfully');
      await loadCustomers();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ deleteCustomer error: $e');
      Get.snackbar('Error', failure.message);
    }
  }
}

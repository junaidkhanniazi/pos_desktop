import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/store/supplier_entity.dart';
import 'package:pos_desktop/domain/usecases/supplier_usecase.dart';

class SupplierController extends GetxController {
  final SupplierUseCase _useCase = Get.find<SupplierUseCase>();
  final Logger _logger = Logger();

  final suppliers = <SupplierEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  int? _storeId;

  Future<void> init(int storeId) async {
    _storeId = storeId;
    await loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    if (_storeId == null) return;
    try {
      isLoading.value = true;
      suppliers.value = await _useCase.getAll(_storeId!);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ loadSuppliers error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSupplier(SupplierEntity supplier) async {
    try {
      await _useCase.add(supplier);
      Get.snackbar('Supplier Added', 'Supplier saved successfully');
      await loadSuppliers();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ addSupplier error: $e');
      Get.snackbar('Error', failure.message);
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _useCase.delete(id);
      Get.snackbar('Supplier Deleted', 'Supplier removed successfully');
      await loadSuppliers();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ deleteSupplier error: $e');
      Get.snackbar('Error', failure.message);
    }
  }
}

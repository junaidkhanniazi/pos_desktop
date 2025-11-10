import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/store/expense_entity.dart';
import 'package:pos_desktop/domain/usecases/expense_usecase.dart';

class ExpenseController extends GetxController {
  final ExpenseUseCase _useCase = Get.find<ExpenseUseCase>();
  final Logger _logger = Logger();

  final expenses = <ExpenseEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final totalForPeriod = 0.0.obs;

  int? _storeId;

  Future<void> init(int storeId) async {
    _storeId = storeId;
    await loadExpenses();
  }

  Future<void> loadExpenses() async {
    if (_storeId == null) return;
    try {
      isLoading.value = true;
      expenses.value = await _useCase.getAll(_storeId!);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ loadExpenses error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    try {
      await _useCase.add(expense);
      Get.snackbar('Expense Added', 'Expense recorded successfully');
      await loadExpenses();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ addExpense error: $e');
      Get.snackbar('Error', failure.message);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _useCase.delete(id);
      Get.snackbar('Expense Deleted', 'Expense removed successfully');
      await loadExpenses();
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e('❌ deleteExpense error: $e');
      Get.snackbar('Error', failure.message);
    }
  }
}

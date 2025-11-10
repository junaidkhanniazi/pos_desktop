import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/dao/expense_dao.dart';
import 'package:pos_desktop/data/models/expense_model.dart';
import 'package:pos_desktop/domain/entities/store/expense_entity.dart';
import 'package:pos_desktop/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final Logger _logger = Logger();
  final ExpenseDao _dao = ExpenseDao();

  @override
  Future<List<ExpenseEntity>> getAllExpenses(int storeId) async {
    try {
      final models = await _dao.getAllExpenses(storeId);
      return models.cast<ExpenseEntity>();
    } catch (e) {
      _logger.e("❌ Error fetching expenses: $e");
      return [];
    }
  }

  @override
  Future<int> addExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      return await _dao.insertExpense(model);
    } catch (e) {
      _logger.e("❌ Error adding expense: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await _dao.updateExpense(model);
    } catch (e) {
      _logger.e("❌ Error updating expense: $e");
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      await _dao.deleteExpense(id);
    } catch (e) {
      _logger.e("❌ Error deleting expense: $e");
    }
  }

  @override
  Future<double> getTotalExpensesForPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      return await _dao.getTotalExpensesForPeriod(start, end);
    } catch (e) {
      _logger.e("❌ Error calculating total expenses: $e");
      return 0.0;
    }
  }
}

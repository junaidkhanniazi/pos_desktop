import 'package:pos_desktop/domain/entities/store/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getAllExpenses(int storeId);
  Future<int> addExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);
  Future<double> getTotalExpensesForPeriod({
    required DateTime start,
    required DateTime end,
  });
}

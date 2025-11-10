import 'package:pos_desktop/domain/entities/store/expense_entity.dart';
import 'package:pos_desktop/domain/repositories/expense_repository.dart';

class ExpenseUseCase {
  final ExpenseRepository _repository;
  ExpenseUseCase(this._repository);

  Future<List<ExpenseEntity>> getAll(int storeId) =>
      _repository.getAllExpenses(storeId);
  Future<int> add(ExpenseEntity e) => _repository.addExpense(e);
  Future<void> update(ExpenseEntity e) => _repository.updateExpense(e);
  Future<void> delete(int id) => _repository.deleteExpense(id);
}

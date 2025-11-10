import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/expense_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ExpenseDao {
  final _dbHelper = DatabaseHelper();

  Future<List<ExpenseModel>> getAllExpenses(int storeId) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
    final result = await db.query('expenses', orderBy: 'id DESC');
    return result.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<int> insertExpense(ExpenseModel model) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    return await db.insert(
      'expenses',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(ExpenseModel model) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.update(
      'expenses',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpensesForPeriod(DateTime start, DateTime end) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', 0, 'store');
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE created_at BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}

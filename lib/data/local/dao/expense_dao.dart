import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/expense_model.dart';

class ExpenseDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 GET ALL EXPENSES
  Future<List<ExpenseModel>> getExpenses({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    int? limit,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'expenses',
        orderBy: 'created_at DESC',
        limit: limit,
      );
      await db.close();
      return data.map((e) => ExpenseModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting expenses: $e');
      rethrow;
    }
  }

  // 🔹 GET EXPENSE BY ID
  Future<ExpenseModel?> getExpenseById({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int expenseId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [expenseId],
        limit: 1,
      );
      await db.close();
      if (data.isEmpty) return null;
      return ExpenseModel.fromMap(data.first);
    } catch (e) {
      print('❌ ERROR getting expense by ID: $e');
      rethrow;
    }
  }

  // 🔹 INSERT EXPENSE
  Future<int> insertExpense({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required String title,
    required double amount,
    String? note,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final id = await db.insert('expenses', {
        'title': title,
        'amount': amount,
        'note': note,
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      });
      await db.close();
      return id;
    } catch (e) {
      print('❌ ERROR inserting expense: $e');
      rethrow;
    }
  }

  // 🔹 UPDATE EXPENSE
  Future<void> updateExpense({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int expenseId,
    required String title,
    required double amount,
    String? note,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.update(
        'expenses',
        {
          'title': title,
          'amount': amount,
          'note': note,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [expenseId],
      );
      await db.close();
    } catch (e) {
      print('❌ ERROR updating expense: $e');
      rethrow;
    }
  }

  // 🔹 DELETE EXPENSE
  Future<void> deleteExpense({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int expenseId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      await db.delete('expenses', where: 'id = ?', whereArgs: [expenseId]);
      await db.close();
    } catch (e) {
      print('❌ ERROR deleting expense: $e');
      rethrow;
    }
  }

  // 🔹 GET EXPENSES SUMMARY
  Future<Map<String, dynamic>> getExpensesSummary({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );

      final totalResult = await db.rawQuery(
        '''
        SELECT COUNT(*) as count, COALESCE(SUM(amount), 0) as total 
        FROM expenses 
        WHERE date(created_at) BETWEEN date(?) AND date(?)
      ''',
        [startDate.toIso8601String(), endDate.toIso8601String()],
      );

      await db.close();

      return {
        'total_amount': totalResult.first['total'] ?? 0,
        'expenses_count': totalResult.first['count'] ?? 0,
      };
    } catch (e) {
      print('❌ ERROR getting expenses summary: $e');
      rethrow;
    }
  }

  // 🔹 GET RECENT EXPENSES
  Future<List<ExpenseModel>> getRecentExpenses({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    int limit = 10,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'expenses',
        orderBy: 'created_at DESC',
        limit: limit,
      );
      await db.close();
      return data.map((e) => ExpenseModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting recent expenses: $e');
      rethrow;
    }
  }
}

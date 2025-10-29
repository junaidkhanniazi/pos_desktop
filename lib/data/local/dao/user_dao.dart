import 'package:logger/logger.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/errors/failure.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/user_model.dart';

class UserDao {
  final _dbHelper = DatabaseHelper();
  final _logger = Logger();

  /// Add new staff member (created by owner)
  Future<int> insertUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      return await _dbHelper.executeWithRetry(() async {
        // Check duplicate username
        final existing = await db.query(
          'users',
          where: 'username = ?',
          whereArgs: [user.username],
          limit: 1,
        );

        if (existing.isNotEmpty) {
          throw ValidationFailure('A user with this username already exists.');
        }

        final id = await db.insert('users', user.toMap());
        _logger.i('👤 New staff added with ID: $id');
        return id;
      });
    } catch (e) {
      _logger.e('❌ insertUser error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Login user (used by AuthRepository)
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final db = await _dbHelper.database;
      return await _dbHelper.executeWithRetry(() async {
        final result = await db.query(
          'users',
          where: 'username = ? AND password = ? AND is_active = 1',
          whereArgs: [email.trim(), password.trim()],
          limit: 1,
        );

        if (result.isEmpty) {
          _logger.w('⚠️ Invalid user credentials for $email');
          return null;
        }

        return UserModel.fromMap(result.first);
      });
    } catch (e) {
      _logger.e('❌ loginUser error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Fetch all users for specific owner (for staff management screen)
  Future<List<UserModel>> getUsersByOwner(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
        orderBy: 'id DESC',
      );
      return result.map((map) => UserModel.fromMap(map)).toList();
    } catch (e) {
      _logger.e('❌ getUsersByOwner error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Update user record
  Future<int> updateUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );

      if (count == 0) {
        throw DatabaseFailure('User not found (id=${user.id})');
      }

      _logger.i('🔄 User updated: ${user.id}');
      return count;
    } catch (e) {
      _logger.e('❌ updateUser error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Soft delete / deactivate user
  Future<int> deactivateUser(int userId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'users',
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (count == 0) {
        throw DatabaseFailure('User not found with ID: $userId');
      }

      _logger.w('🧹 User deactivated (id=$userId)');
      return count;
    } catch (e) {
      _logger.e('❌ deactivateUser error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Delete staff permanently (owner-controlled)
  Future<int> deleteUser(int userId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (count == 0) {
        throw DatabaseFailure('User not found with ID: $userId');
      }

      _logger.w('🗑️ User deleted: $userId');
      return count;
    } catch (e) {
      _logger.e('❌ deleteUser error: $e');
      throw ExceptionHandler.handle(e);
    }
  }
}

import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:logger/logger.dart';
import 'package:pos_desktop/data/models/owner_model.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/errors/failure.dart';
import 'dart:math';

class OwnerDao {
  final _dbHelper = DatabaseHelper();
  final _logger = Logger();

  /// Insert new owner (signup request)
  Future<int> insertOwner(OwnerModel owner) async {
    try {
      final db = await _dbHelper.database;

      // Use the retry mechanism for the entire operation
      return await _dbHelper.executeWithRetry(() async {
        // Check for duplicate email
        final existing = await db.query(
          'owners',
          where: 'email = ?',
          whereArgs: [owner.email],
          limit: 1,
        );

        if (existing.isNotEmpty) {
          throw ValidationFailure('An owner with this email already exists');
        }

        // Insert with pending status and no activation code
        final id = await db.insert('owners', owner.toMap());
        _logger.i(
          '🧩 Owner registration submitted with ID: $id (pending approval)',
        );
        return id;
      });
    } catch (e) {
      _logger.e('❌ Database error in insertOwner: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Fetch pending owner requests
  Future<List<OwnerModel>> getPendingOwners() async {
    try {
      final db = await _dbHelper.database;
      return await _dbHelper.executeWithRetry(() async {
        final result = await db.query(
          'owners',
          where: 'status = ?',
          whereArgs: ['pending'],
          orderBy: 'id DESC',
        );
        return result.map((map) => OwnerModel.fromMap(map)).toList();
      });
    } catch (e) {
      _logger.e('❌ Database error in getPendingOwners: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Activate owner and generate activation code
  Future<int> activateOwner(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      final code = _generateActivationCode();

      final count = await db.update(
        'owners',
        {'status': 'approved', 'is_active': 1, 'activation_code': code},
        where: 'id = ?',
        whereArgs: [ownerId],
      );

      if (count == 0) {
        throw DatabaseFailure('Owner not found with ID: $ownerId');
      }

      _logger.i('✅ Owner activated (id=$ownerId) with code=$code');
      return count;
    } catch (e) {
      _logger.e('❌ Database error in activateOwner: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Reject owner request
  Future<int> rejectOwner(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'owners',
        {'status': 'rejected', 'is_active': 0},
        where: 'id = ?',
        whereArgs: [ownerId],
      );

      if (count == 0) {
        throw DatabaseFailure('Owner not found with ID: $ownerId');
      }

      _logger.i('❌ Owner rejected (id=$ownerId)');
      return count;
    } catch (e) {
      _logger.e('❌ Database error in rejectOwner: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Fetch owner by email/password + activation code
  Future<OwnerModel?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  }) async {
    try {
      final db = await _dbHelper.database;

      final whereClause = activationCode != null
          ? 'email = ? AND password = ? AND activation_code = ? AND status = ? AND is_active = 1'
          : 'email = ? AND password = ? AND status = ? AND is_active = 1';

      final whereArgs = activationCode != null
          ? [email.trim(), password.trim(), activationCode, 'approved']
          : [email.trim(), password.trim(), 'approved'];

      final result = await db.query(
        'owners',
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      if (result.isEmpty) {
        _logger.w('⚠️ Invalid credentials or not approved for $email');
        return null;
      }

      return OwnerModel.fromMap(result.first);
    } catch (e) {
      _logger.e('❌ Database error in getOwnerByCredentials: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Get all owners (for super admin)
  Future<List<OwnerModel>> getAllOwners() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query('owners', orderBy: 'id DESC');
      return result.map((map) => OwnerModel.fromMap(map)).toList();
    } catch (e) {
      _logger.e('❌ Database error in getAllOwners: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Get approved owners
  Future<List<OwnerModel>> getApprovedOwners() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'owners',
        where: 'status = ? AND is_active = 1',
        whereArgs: ['approved'],
        orderBy: 'id DESC',
      );
      return result.map((map) => OwnerModel.fromMap(map)).toList();
    } catch (e) {
      _logger.e('❌ Database error in getApprovedOwners: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Update owner record
  Future<int> updateOwner(OwnerModel owner) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'owners',
        owner.toMap(),
        where: 'id = ?',
        whereArgs: [owner.id],
      );

      if (count == 0) {
        throw DatabaseFailure('Owner not found with ID: ${owner.id}');
      }

      _logger.i('🔄 Owner updated: ${owner.id}');
      return count;
    } catch (e) {
      _logger.e('❌ Database error in updateOwner: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Delete owner
  Future<int> deleteOwner(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'owners',
        where: 'id = ?',
        whereArgs: [ownerId],
      );

      if (count == 0) {
        throw DatabaseFailure('Owner not found with ID: $ownerId');
      }

      _logger.i('🗑️ Owner deleted: $ownerId');
      return count;
    } catch (e) {
      _logger.e('❌ Database error in deleteOwner: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  /// Generate a simple 6-digit activation code
  String _generateActivationCode() {
    final rng = Random();
    return (rng.nextInt(900000) + 100000).toString(); // 100000-999999
  }
}

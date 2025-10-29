import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart'; // ✅ ADDED
import 'package:pos_desktop/core/errors/failure.dart'; // ✅ ADDED

class SuperAdminDao {
  final _dbHelper = DatabaseHelper();

  /// Hashes password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Insert super admin (for initial setup)
  Future<int> insertSuperAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;

      // Check if already exists
      final existing = await db.query(
        'super_admin',
        where: 'LOWER(email) = ?',
        whereArgs: [email.trim().toLowerCase()],
        limit: 1,
      );
      if (existing.isNotEmpty) return existing.first['id'] as int;

      final id = await db.insert('super_admin', {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': _hashPassword(password),
      });

      print("✅ Super Admin inserted with id=$id");
      return id;
    } catch (e) {
      // ✅ USING EXCEPTIONHANDLER
      throw ExceptionHandler.handle(e);
    }
  }

  /// Login check for Super Admin
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final db = await _dbHelper.database;
      final hashedPassword = _hashPassword(password);

      final result = await db.query(
        'super_admin',
        where: 'LOWER(email) = ? AND password = ?',
        whereArgs: [email.trim().toLowerCase(), hashedPassword],
        limit: 1,
      );

      if (result.isEmpty) {
        print("❌ Super Admin login failed: email=${email.trim()}");
        return null;
      }

      print("✅ Super Admin login success: ${result.first}");
      return result.first;
    } catch (e) {
      // ✅ USING EXCEPTIONHANDLER
      throw ExceptionHandler.handle(e);
    }
  }

  /// Fetch all super admins (optional)
  Future<List<Map<String, dynamic>>> getAllSuperAdmins() async {
    try {
      final db = await _dbHelper.database;
      return await db.query('super_admin', orderBy: 'id DESC');
    } catch (e) {
      // ✅ USING EXCEPTIONHANDLER
      throw ExceptionHandler.handle(e);
    }
  }
}

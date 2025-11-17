import 'package:logger/logger.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/errors/failure.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/domain/repositories/auth_repository.dart';

/// Handles authentication (login) using [SyncApi].
/// Replaces old RemoteAuthApi — unified API layer for all endpoints.
class AuthRepositoryImpl implements AuthRepository {
  final Logger _logger = Logger();

  AuthRepositoryImpl();

  AuthRole? _mapRole(String? role) {
    if (role == null) return null;

    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return AuthRole.superAdmin;
      case 'owner':
        return AuthRole.owner;
      default:
        return null;
    }
  }

  // @override
  // Future<AuthRole?> loginAny(String email, String password) async {
  //   try {
  //     final body = {'email': email, 'password': password};
  //     final result = await SyncApi.post("auth/login", body);
  //     _logger.i("🔐 Universal login response: $result");

  //     if (result == null || result is! Map<String, dynamic>) {
  //       throw Failure('Invalid response from server');
  //     }

  //     if (result['success'] != true) {
  //       throw Failure(result['message'] ?? 'Login failed');
  //     }

  //     final role = _mapRole(result['role']);
  //     if (role == AuthRole.owner) {
  //       final sub = result['subscription'];
  //       if (sub == null || sub['status'] != 'active') {
  //         throw Failure('Your subscription is inactive or expired.');
  //       }
  //     }

  //     _logger.i("✅ Login successful as $role");
  //     return role;
  //   } catch (e) {
  //     _logger.e("❌ Universal login error: $e");

  //     if (e is Failure) throw e;

  //     throw ExceptionHandler.handle(e);
  //   }
  // }

  @override
  Future<AuthRole?> loginAny(String email, String password) async {
    try {
      final body = {'email': email, 'password': password};
      final result = await SyncApi.post("auth/login", body);
      _logger.i("🔐 Universal login response: $result");

      if (result == null || result is! Map<String, dynamic>) {
        throw Failure('Invalid response from server');
      }

      if (result['success'] != true) {
        throw Failure(result['message'] ?? 'Login failed');
      }

      final role = _mapRole(result['role']);
      if (role == null) throw Failure("Invalid role from server");

      // 🔹 Prepare AuthStorageHelper
      final authStorage = AuthStorageHelper();

      // 🔹 Save ID based on role
      if (role == AuthRole.owner) {
        final sub = result['subscription'];
        if (sub == null || sub['status'] != 'active') {
          throw Failure('Your subscription is inactive or expired.');
        }

        final owner = result['owner'];
        final ownerId = owner?['id']?.toString();

        await authStorage.saveLogin(role: role, email: email, ownerId: ownerId);
        _logger.i("💾 Saved owner login → ID: $ownerId");
      } else if (role == AuthRole.superAdmin) {
        final admin = result['admin'];
        final adminId = admin?['id']?.toString();

        await authStorage.saveLogin(role: role, email: email, adminId: adminId);
        _logger.i("💾 Saved super admin login → ID: $adminId");
      } else {
        await authStorage.saveLogin(role: role, email: email);
        _logger.w("⚠️ Unknown role, only email saved");
      }

      _logger.i("✅ Login successful as $role");
      return role;
    } catch (e) {
      _logger.e("❌ Universal login error: $e");

      if (e is Failure) throw e;
      throw ExceptionHandler.handle(e);
    }
  }
}

import 'package:logger/logger.dart';
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

  @override
  Future<AuthRole?> loginOwner(String email, String password) async {
    try {
      final body = {'email': email, 'password': password};

      // 🔹 API call
      final result = await SyncApi.post("auth/login", body);
      _logger.i("🔐 Login response: $result");

      // 🔸 Validate response
      if (result == null || result is! Map<String, dynamic>) {
        _logger.w("⚠️ Invalid login response format");
        return null;
      }

      final bool success = result['success'] == true;
      if (!success) {
        _logger.w("❌ Login failed: ${result['message']}");
        return null;
      }

      final role = _mapRole(result['role']);
      if (role == AuthRole.owner) {
        _logger.i("✅ Owner login success");
        return role;
      }

      _logger.w("⚠️ Non-owner role attempted login: ${result['role']}");
      return null;
    } catch (e) {
      _logger.e("❌ Login error: $e");
      return null;
    }
  }

  @override
  Future<AuthRole?> loginAny(
    String email,
    String password, {
    String? activationCode,
  }) async {
    try {
      final body = {'email': email, 'password': password};

      if (activationCode != null && activationCode.isNotEmpty) {
        body['activationCode'] = activationCode;
      }

      final result = await SyncApi.post("auth/login", body);
      _logger.i("🔐 Universal login response: $result");

      if (result == null || result is! Map<String, dynamic>) return null;
      if (result['success'] != true) return null;

      final role = _mapRole(result['role']);
      _logger.i("✅ Login successful as $role");
      return role;
    } catch (e) {
      _logger.e("❌ Universal login error: $e");
      return null;
    }
  }
}

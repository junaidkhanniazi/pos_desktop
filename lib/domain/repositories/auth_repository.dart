import 'package:pos_desktop/domain/entities/auth_role.dart';

/// Domain contract for login flows (no DB/UI here)
abstract class AuthRepository {
  /// Try Super Admin login. Return role if success, else null.
  Future<AuthRole?> loginSuperAdmin(String email, String password);

  /// Try Owner login. If activationCode required, pass it.
  Future<AuthRole?> loginOwner(
    String email,
    String password, {
    String? activationCode,
  });

  /// Try Staff (user) login under an owner.
  Future<AuthRole?> loginStaff(String email, String password);

  /// Convenience: Try all in order. Returns first matching role or null.
  Future<AuthRole?> loginAny(
    String email,
    String password, {
    String? activationCode,
  });
}

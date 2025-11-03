import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/domain/repositories/auth_repository.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/errors/failure.dart';
import 'package:pos_desktop/data/local/dao/user_dao.dart';
import 'package:pos_desktop/data/models/user_model.dart';

/// Handles login logic for all roles (SuperAdmin, Owner, Staff)
class LoginUseCase {
  final AuthRepository _repository;
  final UserDao _userDao = UserDao();

  LoginUseCase(this._repository);

  /// 🔹 Core login entry
  Future<AuthRole> call(
    String email,
    String password, {
    String? activationCode,
  }) async {
    try {
      // Attempt login for any role
      final role = await _repository.loginAny(
        email,
        password,
        activationCode: activationCode,
      );

      if (role == null) {
        throw ValidationFailure('Invalid email or password.');
      }

      // 🧩 If staff, capture their role dynamically
      if (role == AuthRole.staff) {
        final user = await _userDao.loginUser(email, password);
        await AuthStorageHelper.saveLogin(
          role: AuthRole.staff,
          email: email,
          staffRole:
              user?.role, // 👈 dynamic role like 'cashier' or 'accountant'
          ownerId: user?.ownerId.toString(),
        );
      } else {
        // 🧩 For SuperAdmin or Owner
        await AuthStorageHelper.saveLogin(role: role, email: email);
      }

      return role;
    } catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }

  /// 🔸 Check if user can auto-login (SharedPrefs)
  static Future<AuthRole?> checkAutoLogin() async {
    final loggedIn = await AuthStorageHelper.isLoggedIn();
    if (!loggedIn) return null;
    return await AuthStorageHelper.getRole();
  }

  /// 🔸 Clear all login session data
  static Future<void> logout() async {
    await AuthStorageHelper.logout();
  }
}

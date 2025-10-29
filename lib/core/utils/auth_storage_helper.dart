import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';

class AuthStorageHelper {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyRole = 'user_role';
  static const _keyEmail = 'user_email';
  static const _keyOwnerId = 'owner_id';
  static const _keyStaffRole = 'staff_role';

  /// Save login info
  static Future<void> saveLogin({
    required AuthRole role,
    required String email,
    String? ownerId,
    String? staffRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyRole, role.name);
    await prefs.setString(_keyEmail, email);
    if (ownerId != null) await prefs.setString(_keyOwnerId, ownerId);
    if (staffRole != null) await prefs.setString(_keyStaffRole, staffRole);
  }

  static Future<AuthRole?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_keyRole);
    if (roleName == null) return null;
    try {
      return AuthRole.values.firstWhere((r) => r.name == roleName);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getStaffRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStaffRole);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getOwnerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOwnerId);
  }
}

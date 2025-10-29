import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyRole = 'user_role';
  static const _keyEmail = 'user_email';

  /// Save login session
  static Future<void> saveSession(String role, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyEmail, email);
  }

  /// Retrieve saved role (null if not logged in)
  static Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRole);
    await prefs.remove(_keyEmail);
  }
}

import 'package:pos_desktop/core/storage/storage_service.dart';

class AuthStorage {
  static const _keyRole = 'user_role';
  static const _keyEmail = 'user_email';

  final StorageService storage;

  AuthStorage(this.storage);

  /// Save login session
  Future<void> saveSession(String role, String email) async {
    await storage.save(_keyRole, role);
    await storage.save(_keyEmail, email);
  }

  /// Retrieve saved role (null if not logged in)
  Future<String?> getSavedRole() => storage.read(_keyRole);
  Future<String?> getSavedEmail() => storage.read(_keyEmail);

  /// Clear session on logout
  Future<void> clearSession() async {
    await storage.remove(_keyRole);
    await storage.remove(_keyEmail);
  }
}

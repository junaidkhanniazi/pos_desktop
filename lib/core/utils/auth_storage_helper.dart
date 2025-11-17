import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:pos_desktop/core/storage/storage_service.dart';
import 'package:pos_desktop/core/storage/shared_prefs_storage.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/data/models/store_model.dart';

class AuthStorageHelper {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyRole = 'user_role';
  static const _keyEmail = 'user_email';
  static const _keyOwnerId = 'owner_id';
  static const _keyStaffRole = 'staff_role';
  static const _keyAdminId = 'admin_id';
  static const _keyTempOwnerData = 'temp_owner_data';
  static const _keyCurrentStoreId = 'current_store_id';
  static const _keyCurrentStoreName = 'current_store_name';

  static final _logger = Logger();
  static final StorageService _storage = SharedPrefsStorage();

  // ======================================================
  // 🔹 LOGIN MANAGEMENT
  // ======================================================a

  Future<void> saveLogin({
    required AuthRole role,
    required String email,
    String? ownerId,
    String? staffRole,
    String? adminId,
  }) async {
    await (_storage as SharedPrefsStorage).saveBool(_keyIsLoggedIn, true);
    await _storage.save(_keyRole, role.name);
    await _storage.save(_keyEmail, email);
    if (ownerId != null) await _storage.save(_keyOwnerId, ownerId);
    if (staffRole != null) await _storage.save(_keyStaffRole, staffRole);
    if (adminId != null) await _storage.save(_keyAdminId, adminId);
    _logger.i("✅ Login saved for: $email (${role.name})");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = _storage as SharedPrefsStorage;
    return await prefs.readBool(_keyIsLoggedIn) ?? false;
  }

  static Future<AuthRole?> getRole() async {
    final roleName = await _storage.read(_keyRole);
    if (roleName == null) return null;
    return AuthRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => AuthRole.owner,
    );
  }

  static Future<String?> getEmail() => _storage.read(_keyEmail);
  static Future<String?> getOwnerId() => _storage.read(_keyOwnerId);
  static Future<String?> getAdminId() => _storage.read(_keyAdminId);
  static Future<String?> getStaffRole() => _storage.read(_keyStaffRole);

  Future<void> logout() async {
    await _storage.clear();
    _logger.w("🚪 User logged out and preferences cleared");
  }

  // ======================================================
  // 🔹 TEMP OWNER DATA (used during signup flow)
  // ======================================================

  static Future<void> saveTempOwnerData(Map<String, dynamic> data) async {
    await _storage.save(_keyTempOwnerData, jsonEncode(data));
    _logger.i("💾 Temp owner data saved: $data");
  }

  static Future<Map<String, dynamic>?> getTempOwnerData() async {
    final jsonString = await _storage.read(_keyTempOwnerData);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<void> clearTempOwnerData() async {
    await _storage.remove(_keyTempOwnerData);
    _logger.i("🧹 Temp owner data cleared");
  }

  // ======================================================
  // 🔹 CURRENT STORE HANDLING
  // ======================================================
  static Future<void> setCurrentStore(StoreModel store) async {
    final prefs = _storage as SharedPrefsStorage;
    await prefs.saveInt(_keyCurrentStoreId, store.id);
    await _storage.save(_keyCurrentStoreName, store.storeName);
    _logger.i("🏪 Current store set: ${store.storeName} (ID: ${store.id})");
  }

  static Future<int?> getCurrentStoreId() async {
    final prefs = _storage as SharedPrefsStorage;
    return prefs.readInt(_keyCurrentStoreId);
  }

  static Future<String?> getCurrentStoreName() =>
      _storage.read(_keyCurrentStoreName);

  static Future<void> debugCurrentStore() async {
    final id = await getCurrentStoreId();
    final name = await getCurrentStoreName();
    _logger.i('🔍 CURRENT STORE DEBUG:\n   ID: $id\n   Name: $name');
  }
}

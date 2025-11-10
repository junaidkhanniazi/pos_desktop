import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:pos_desktop/core/storage/storage_service.dart';
import 'package:pos_desktop/core/storage/shared_prefs_storage.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:pos_desktop/data/models/subscription_model.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';

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
  // ======================================================

  static Future<void> saveLogin({
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

  static Future<void> logout() async {
    await _storage.clear();
    _logger.w("🚪 User logged out and preferences cleared");
  }

  // ======================================================
  // 🔹 SUBSCRIPTION STATUS (Online version)
  // ======================================================
  static Future<SubscriptionModel?> _fetchActiveSubscriptionOnline(
    String ownerId,
  ) async {
    try {
      final response = await SyncApi.get("owners/subscriptions/owner/$ownerId");
      if (response.isEmpty) return null;
      return SubscriptionModel.fromMap(response.first);
    } catch (e) {
      _logger.e('❌ Error fetching subscription from server: $e');
      return null;
    }
  }

  static Future<bool> isSubscriptionExpired() async {
    try {
      final ownerId = await getOwnerId();
      if (ownerId == null) return true;

      final sub = await _fetchActiveSubscriptionOnline(ownerId);
      if (sub == null) return true;

      return sub.isExpired;
    } catch (e) {
      _logger.e("❌ Subscription check failed: $e");
      return true;
    }
  }

  // static Future<Map<String, dynamic>> getSubscriptionStatus() async {
  //   final ownerId = await getOwnerId();
  //   if (ownerId == null) {
  //     return {'isExpired': true, 'message': 'Owner ID not found'};
  //   }

  //   final sub = await _fetchActiveSubscriptionOnline(ownerId);
  //   if (sub == null) {
  //     return {'isExpired': true, 'message': 'No active subscription'};
  //   }

  //   final endDate = sub.subscriptionEndDate != null
  //       ? DateTime.tryParse(sub.subscriptionEndDate!)
  //       : null;

  //   return {
  //     'isExpired': sub.isExpired,
  //     'isExpiringSoon': sub.isExpiringSoon,
  //     'endDate': sub.subscriptionEndDate,
  //     'daysLeft': endDate != null
  //         ? endDate.difference(DateTime.now()).inDays
  //         : 0,
  //     'message': sub.isExpired
  //         ? 'Subscription expired'
  //         : sub.isExpiringSoon
  //         ? 'Subscription expiring soon'
  //         : 'Subscription active',
  //   };
  // }

  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final ownerId = await getOwnerId();
    if (ownerId == null) {
      return {'isExpired': true, 'message': 'Owner ID not found'};
    }

    final sub = await _fetchActiveSubscriptionOnline(ownerId);
    if (sub == null) {
      return {'isExpired': true, 'message': 'No active subscription'};
    }

    // ✅ sub.subscriptionEndDate is already a DateTime?
    final endDate = sub.subscriptionEndDate;

    return {
      'isExpired': sub.isExpired,
      'isExpiringSoon': sub.isExpiringSoon,
      'endDate': endDate,
      'daysLeft': endDate != null
          ? endDate.difference(DateTime.now()).inDays
          : 0,
      'message': sub.isExpired
          ? 'Subscription expired'
          : sub.isExpiringSoon
          ? 'Subscription expiring soon'
          : 'Subscription active',
    };
  }

  static Future<bool> checkAndHandleExpiredSubscription() async {
    try {
      final loggedIn = await isLoggedIn();
      if (!loggedIn) return false;

      final role = await getRole();
      if (role != AuthRole.owner) {
        _logger.i('✅ Skipping subscription check for role: $role');
        return false;
      }

      if (await isSubscriptionExpired()) {
        await logout();
        _logger.w('⚠️ Auto-logged out due to expired subscription');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('❌ Error during subscription check: $e');
      return false;
    }
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

  static Future<void> clearCurrentStore() async {
    await _storage.remove(_keyCurrentStoreId);
    await _storage.remove(_keyCurrentStoreName);
    _logger.i("🗑️ Cleared current store selection");
  }
}

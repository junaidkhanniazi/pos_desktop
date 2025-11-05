import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/local/dao/subscription_dao.dart';
import 'package:pos_desktop/data/models/subscription_model.dart';

class AuthStorageHelper {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyRole = 'user_role';
  static const _keyEmail = 'user_email';
  static const _keyOwnerId = 'owner_id';
  static const _keyStaffRole = 'staff_role';
  static const _keyAdminId = 'admin_id';
  static const _keyTempOwnerData = 'temp_owner_data';

  static final _logger = Logger();

  // ======================================================
  // 🔹 Login Data
  // ======================================================

  static Future<void> saveLogin({
    required AuthRole role,
    required String email,
    String? ownerId,
    String? staffRole,
    String? adminId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyRole, role.name);
    await prefs.setString(_keyEmail, email);
    if (ownerId != null) await prefs.setString(_keyOwnerId, ownerId);
    if (staffRole != null) await prefs.setString(_keyStaffRole, staffRole);
    if (adminId != null) await prefs.setString(_keyAdminId, adminId);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<AuthRole?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyRole);
    if (name == null) return null;
    return AuthRole.values.firstWhere(
      (r) => r.name == name,
      orElse: () => AuthRole.owner,
    );
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getOwnerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOwnerId);
  }

  static Future<String?> getAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminId);
  }

  static Future<String?> getStaffRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStaffRole);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ======================================================
  // 🔹 Subscription Handling (via SubscriptionDao)
  // ======================================================

  static Future<SubscriptionModel?> _getActiveSubscription() async {
    try {
      final email = await getEmail();
      if (email == null) return null;

      final ownerDao = OwnerDao();
      final owner = await ownerDao.getOwnerByEmail(email);
      if (owner == null) return null;

      final subDao = SubscriptionDao();
      return await subDao.getActiveSubscription(owner.id!);
    } catch (e) {
      _logger.e('❌ Error fetching active subscription: $e');
      return null;
    }
  }

  static Future<bool> isSubscriptionExpired() async {
    final sub = await _getActiveSubscription();
    if (sub == null) return true;
    return sub.isExpired;
  }

  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final sub = await _getActiveSubscription();
    if (sub == null) {
      return {'isExpired': true, 'message': 'No active subscription'};
    }

    final endDate = sub.subscriptionEndDate != null
        ? DateTime.tryParse(sub.subscriptionEndDate!)
        : null;

    return {
      'isExpired': sub.isExpired,
      'isExpiringSoon': sub.isExpiringSoon,
      'endDate': sub.subscriptionEndDate,
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

  static Future<void> saveTempOwnerData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTempOwnerData, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getTempOwnerData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTempOwnerData);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<void> clearTempOwnerData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTempOwnerData);
  }

  static Future<bool> checkAndHandleExpiredSubscription() async {
    try {
      final loggedIn = await isLoggedIn();
      if (!loggedIn) return false;

      final role = await getRole();

      // ✅ ONLY CHECK SUBSCRIPTION FOR OWNERS, NOT SUPER ADMIN OR STAFF
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
}

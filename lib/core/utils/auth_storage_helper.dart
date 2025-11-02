import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/models/owner_model.dart'; // ✅ ADD THIS IMPORT

class AuthStorageHelper {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyRole = 'user_role';
  static const _keyEmail = 'user_email';
  static const _keyOwnerId = 'owner_id';
  static const _keyStaffRole = 'staff_role';
  static const _keyAdminId = 'admin_id';

  /// Save login info
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

  static Future<String?> getAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminId);
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

  // ✅ NEW METHODS FOR SUBSCRIPTION EXPIRATION CHECK

  /// 🔹 Check if logged-in owner's subscription has expired
  static Future<bool> isSubscriptionExpired() async {
    try {
      final role = await getRole();
      if (role != AuthRole.owner) return false; // Only for owners

      final email = await getEmail();
      if (email == null) return false;

      final ownerDao = OwnerDao();
      final owner = await ownerDao.getOwnerByEmail(email);

      return owner?.isSubscriptionExpired ?? true;
    } catch (e) {
      print('❌ Error checking subscription: $e');
      return true; // Safe side - assume expired if error
    }
  }

  /// 🔹 Get owner by email (helper method) - FIXED: OwnerModel instead of Owner
  static Future<OwnerModel?> getCurrentOwner() async {
    try {
      final email = await getEmail();
      if (email == null) return null;

      final ownerDao = OwnerDao();
      return await ownerDao.getOwnerByEmail(email);
    } catch (e) {
      print('❌ Error getting current owner: $e');
      return null;
    }
  }

  /// 🔹 Force logout if subscription expired
  static Future<bool> checkAndHandleExpiredSubscription() async {
    try {
      final bool userIsLoggedIn = await isLoggedIn(); // ✅ RENAMED VARIABLE
      if (!userIsLoggedIn) return false;

      if (await isSubscriptionExpired()) {
        await logout();
        print('✅ Auto-logged out due to expired subscription');
        return true; // Subscription expired and logged out
      }
      return false; // Subscription active
    } catch (e) {
      print('❌ Error in subscription check: $e');
      return false;
    }
  }

  /// 🔹 Get subscription status with details - FIXED: OwnerModel instead of Owner
  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final role = await getRole();
      if (role != AuthRole.owner) {
        return {'isExpired': false, 'message': 'Not an owner account'};
      }

      final owner = await getCurrentOwner();
      if (owner == null) {
        return {'isExpired': true, 'message': 'Owner not found'};
      }

      return {
        'isExpired': owner.isSubscriptionExpired,
        'isExpiringSoon': owner.isSubscriptionExpiringSoon,
        'endDate': owner.subscriptionEndDate,
        'daysLeft': owner.isSubscriptionExpired
            ? 0
            : DateTime.parse(
                owner.subscriptionEndDate!,
              ).difference(DateTime.now()).inDays,
        'message': owner.isSubscriptionExpired
            ? 'Subscription expired'
            : owner.isSubscriptionExpiringSoon
            ? 'Subscription expiring soon'
            : 'Subscription active',
      };
    } catch (e) {
      return {'isExpired': true, 'message': 'Error checking status: $e'};
    }
  }

  /// 🔹 Check if user should be redirected to login due to expired subscription
  static Future<bool> shouldRedirectToLogin() async {
    final bool userLoggedIn = await isLoggedIn(); // ✅ RENAMED VARIABLE
    if (!userLoggedIn) return false;

    return await checkAndHandleExpiredSubscription();
  }
}

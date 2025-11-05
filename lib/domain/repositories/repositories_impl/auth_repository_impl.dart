import 'package:pos_desktop/data/local/dao/subscription_dao.dart';
import 'package:pos_desktop/data/local/dao/super_admin_dao.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/local/dao/user_dao.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository]
/// Uses SQLite DAOs for all three roles.
class AuthRepositoryImpl implements AuthRepository {
  final SuperAdminDao _superAdminDao;
  final OwnerDao _ownerDao;
  final UserDao _userDao;

  AuthRepositoryImpl(this._superAdminDao, this._ownerDao, this._userDao);

  /// 1️⃣ Super Admin Login
  @override
  Future<AuthRole?> loginSuperAdmin(String email, String password) async {
    try {
      final superAdmin = await _superAdminDao.login(email, password);
      if (superAdmin != null) return AuthRole.superAdmin;
    } catch (_) {}
    return null;
  }

  /// 2️⃣ Owner Login (ACTIVATION CODE REMOVED - uses subscription status)
  @override
  Future<AuthRole?> loginOwner(
    String email,
    String password, {
    String? activationCode, // ❌ This parameter is now ignored
  }) async {
    try {
      // ✅ Now only email and password are checked
      // Subscription status is automatically checked inside getOwnerByCredentials
      final owner = await _ownerDao.getOwnerByCredentials(email, password);
      if (owner != null) return AuthRole.owner;
    } catch (e) {
      // Re-throw subscription related errors (expired, etc.)
      rethrow;
    }
    return null;
  }

  /// 3️⃣ Staff Login (standard override)
  @override
  Future<AuthRole?> loginStaff(String email, String password) async {
    try {
      final user = await _userDao.loginUser(email, password);
      if (user != null && user.isActive) return AuthRole.staff;
    } catch (_) {}
    return null;
  }

  @override
  Future<SubscriptionEntity?> getOwnerSubscription(String ownerId) async {
    try {
      final subscriptionDao = SubscriptionDao();
      final subscription = await subscriptionDao.getActiveSubscription(
        int.tryParse(ownerId) ?? 0,
      );

      if (subscription != null) {
        return subscription.toEntity();
      }
      return null;
    } catch (e) {
      print('❌ Error getting subscription for owner $ownerId: $e');
      return null;
    }
  }

  /// ✅ Helper function — NOT an override
  /// Returns tuple (mainRole, subRole)
  Future<(AuthRole, String?)?> loginStaffWithSubRole(
    String email,
    String password,
  ) async {
    try {
      final user = await _userDao.loginUser(email, password);
      if (user != null && user.isActive) {
        return (AuthRole.staff, user.role);
      }
    } catch (_) {}
    return null;
  }

  /// 4️⃣ Unified login (ACTIVATION CODE REMOVED)
  @override
  Future<AuthRole?> loginAny(
    String email,
    String password, {
    String? activationCode, // ❌ This parameter is now ignored
  }) async {
    // Try Super Admin
    final admin = await loginSuperAdmin(email, password);
    if (admin != null) return admin;

    // Try Owner (activation code parameter removed)
    final owner = await loginOwner(email, password);
    if (owner != null) return owner;

    // Try Staff
    final staff = await loginStaff(email, password);
    if (staff != null) return staff;

    return null;
  }
}

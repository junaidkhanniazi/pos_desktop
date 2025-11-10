import 'package:pos_desktop/core/utils/auth_storage_helper.dart';

class RouteGuard {
  static Future<bool> canAccessOwnerDashboard() async {
    final loggedIn = await AuthStorageHelper.isLoggedIn();
    if (!loggedIn) return false;

    final expired = await AuthStorageHelper.isSubscriptionExpired();
    if (expired) {
      await AuthStorageHelper.logout();
      return false;
    }
    return true;
  }
}

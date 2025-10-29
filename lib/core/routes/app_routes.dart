import 'package:flutter/material.dart';
import 'package:pos_desktop/presentation/dashboards/accountant/accountant_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/cashier/cashier_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/inventory_manager/inventory_manager_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/super_admin_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/owner/owner_dashboard.dart';
import 'package:pos_desktop/presentation/screens/login_screen.dart';
import 'package:pos_desktop/presentation/screens/owner_signup_screen.dart';
import 'package:pos_desktop/presentation/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String ownerSignup = '/owner-signup';
  static const String superAdminDashboard = '/super-admin-dashboard';
  static const String ownerDashboard = '/owner-dashboard';
  static const String cashierDashboard = '/cashier-dashboard';
  static const String inventoryManagerDashboard =
      '/inventory-manager-dashboard';
  static const String accountantDashboard = '/accountant-dashboard';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.ownerSignup:
        return MaterialPageRoute(builder: (_) => const OwnerSignupScreen());

      case AppRoutes.superAdminDashboard:
        return MaterialPageRoute(builder: (_) => const SuperAdminDashboard());

      case AppRoutes.ownerDashboard:
        return MaterialPageRoute(builder: (_) => const OwnerDashboard());

      case AppRoutes.cashierDashboard:
        return MaterialPageRoute(builder: (_) => const CashierDashboard());

      case AppRoutes.inventoryManagerDashboard:
        return MaterialPageRoute(
          builder: (_) => const InventoryManagerDashboard(),
        );

      case AppRoutes.accountantDashboard:
        return MaterialPageRoute(builder: (_) => const AccountantDashboard());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('404 - Page Not Found'))),
        );
    }
  }
}

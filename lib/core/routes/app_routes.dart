import 'package:flutter/material.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/presentation/dashboards/accountant/accountant_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/cashier/cashier_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/inventory_manager/inventory_manager_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/super_admin_dashboard.dart';
import 'package:pos_desktop/presentation/dashboards/owner/owner_dashboard.dart';
import 'package:pos_desktop/presentation/screens/login_screen.dart';
import 'package:pos_desktop/presentation/screens/splash_screen.dart';
import 'package:pos_desktop/presentation/screens/subscription_plans_screen.dart';
import 'package:pos_desktop/presentation/screens/payment_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String ownerSignup = '/owner-signup';
  static const String subscriptionPlans = '/subscription-plans';
  static const String payment = '/payment';

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

      // case AppRoutes.ownerSignup:
      //   return MaterialPageRoute(builder: (_) => const OwnerSignupScreen());

      case AppRoutes.subscriptionPlans:
        // ✅ No longer require arguments - will fetch from temp storage
        return MaterialPageRoute(
          builder: (_) => const SubscriptionPlansScreen(),
        );

      case AppRoutes.payment:
        // ✅ Only need the selected plan, rest comes from temp storage
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            selectedPlan: args['selectedPlan'] as SubscriptionPlanEntity,
          ),
        );

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

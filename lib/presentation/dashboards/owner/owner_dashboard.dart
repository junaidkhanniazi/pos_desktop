import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_sidebar.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_topbar.dart';
import 'screens/owner_overview_screen.dart';
import 'screens/owner_reports_screen.dart';
import 'screens/owner_staff_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int selectedIndex = 0;
  Timer? _subscriptionChecker;

  @override
  void initState() {
    super.initState();
    _startSubscriptionChecker();
    _checkSubscriptionOnStart();
  }

  // ✅ START PERIODIC SUBSCRIPTION CHECK
  void _startSubscriptionChecker() {
    _subscriptionChecker = Timer.periodic(Duration(minutes: 5), (timer) async {
      // ✅ Step 1: Mark expired subscriptions inactive
      // final subDao = SubscriptionDao();
      // await subDao.markExpiredSubscriptions();

      // ✅ Step 2: Check current owner subscription
      final shouldLogout =
          await AuthStorageHelper.checkAndHandleExpiredSubscription();

      if (shouldLogout && mounted) {
        _showExpirationMessageAndLogout();
      }
    });
  }

  // ✅ CHECK SUBSCRIPTION WHEN DASHBOARD OPENS
  void _checkSubscriptionOnStart() async {
    try {
      final status = await AuthStorageHelper.getSubscriptionStatus();

      if (status['isExpired'] == true && mounted) {
        _showExpirationMessageAndLogout();
      } else if (status['isExpiringSoon'] == true && mounted) {
        _showWarningMessage(status['daysLeft']);
      }
    } catch (e) {
      print('❌ Subscription check error: $e');
    }
  }

  // ✅ SHOW EXPIRATION MESSAGE AND LOGOUT
  void _showExpirationMessageAndLogout() {
    AppToast.show(
      context,
      message: 'Your subscription has expired. Please renew to continue.',
      type: ToastType.error,
    );

    // Navigate to login after short delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  // ✅ SHOW WARNING MESSAGE FOR EXPIRING SOON
  void _showWarningMessage(int daysLeft) {
    AppToast.show(
      context,
      message:
          'Your subscription expires in $daysLeft days. Please renew soon.',
      type: ToastType.warning,
    );
  }

  @override
  void dispose() {
    _subscriptionChecker?.cancel();
    super.dispose();
  }

  // 🔥 UPDATED - Build current page WITHOUT GlobalKey
  Widget _buildCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return const OwnerOverviewScreen();
      case 1:
        return const OwnerInventoryScreen(); // 🔹 REMOVE key parameter
      case 2:
        return const OwnerStaffScreen();
      case 3:
        return const OwnerReportsScreen();
      case 4:
        return const OwnerStoreManagementScreen();
      default:
        return const OwnerOverviewScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          OwnerSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) => setState(() => selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                // 🔥 UPDATED - Pass the callback to OwnerTopBar
                OwnerTopBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Container(
                      key: ValueKey(selectedIndex),
                      color: AppColors.background,
                      child: _buildCurrentPage(),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: AppColors.surface,
                  child: Text(
                    "© 2025 POS Desktop — Owner Dashboard",
                    style: AppText.small.copyWith(color: AppColors.textLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final ownerId = await AuthStorageHelper.getOwnerId();
      //     if (ownerId != null) {
      //       // final subDao = SubscriptionDao();
      //       await subDao.testExpireSubscription(int.parse(ownerId));
      //       AppToast.show(context, message: "Subscription expired for testing");

      //       // Optional: Auto logout to test the flow
      //       await AuthStorageHelper.logout();
      //       Navigator.pushReplacementNamed(context, '/login');
      //     }
      //   },
      //   child: Icon(Icons.timer_off),
      //   backgroundColor: Colors.orange,
      //   tooltip: "Test Subscription Expiry",
      // ),
    );
  }
}

class OwnerInventoryScreen extends StatelessWidget {
  const OwnerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class OwnerStoreManagementScreen extends StatelessWidget {
  const OwnerStoreManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

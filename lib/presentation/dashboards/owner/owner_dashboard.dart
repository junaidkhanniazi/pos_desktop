import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart'; // ✅ ADD THIS
import 'package:pos_desktop/core/utils/toast_helper.dart'; // ✅ ADD THIS
import 'package:pos_desktop/core/routes/app_routes.dart'; // ✅ ADD THIS
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_sidebar.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_topbar.dart';
import 'screens/owner_overview_screen.dart';
import 'screens/owner_inventory_screen.dart';
import 'screens/owner_reports_screen.dart';
import 'screens/owner_staff_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int selectedIndex = 0;
  Timer? _subscriptionChecker; // ✅ ADD TIMER FOR PERIODIC CHECK

  final List<Widget> pages = const [
    OwnerOverviewScreen(),
    OwnerInventoryScreen(),
    OwnerStaffScreen(),
    OwnerReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startSubscriptionChecker(); // ✅ START CHECKING SUBSCRIPTION
    _checkSubscriptionOnStart(); // ✅ CHECK ON DASHBOARD START
  }

  // ✅ START PERIODIC SUBSCRIPTION CHECK
  void _startSubscriptionChecker() {
    _subscriptionChecker = Timer.periodic(Duration(minutes: 5), (timer) async {
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
    _subscriptionChecker?.cancel(); // ✅ CANCEL TIMER
    super.dispose();
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
                const OwnerTopBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Container(
                      key: ValueKey(selectedIndex),
                      color: AppColors.background,
                      child: pages[selectedIndex],
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
    );
  }
}

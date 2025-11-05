import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_desktop/core/storage/auth_storage.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart'; // ✅ ADD THIS
import 'package:pos_desktop/core/utils/toast_helper.dart'; // ✅ ADD THIS
import 'package:pos_desktop/core/routes/app_routes.dart'; // ✅ ADD THIS
import 'package:pos_desktop/data/local/dao/subscription_dao.dart';
import 'package:pos_desktop/data/remote/sync/sync_service.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_sidebar.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_topbar.dart';
import 'screens/owner_overview_screen.dart';
import 'screens/owner_inventory_screen.dart';
import 'screens/owner_reports_screen.dart';
import 'screens/owner_staff_screen.dart';
import 'package:path/path.dart' as p;

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int selectedIndex = 0;
  Timer? _subscriptionChecker; // ✅ ADD TIMER FOR PERIODIC CHECK
  bool _isSyncing = false;
  // Future<void> _manualSync() async {
  //   setState(() => _isSyncing = true);

  //   try {
  //     final syncService = SyncService();
  //     final docs = await getApplicationDocumentsDirectory();

  //     // ✅ Get owner email or name from storage
  //     final email = await AuthStorage.getSavedEmail() ?? "owner";
  //     final ownerName = email
  //         .split('@')
  //         .first
  //         .toLowerCase(); // derive folder name

  //     // ✅ Build store path dynamically (assuming default main_store)
  //     final storeDbPath = p.join(
  //       docs.path,
  //       'Pos_Desktop/pos_data/$ownerName/${ownerName}_main_store/store.db',
  //     );

  //     print("🔄 Manual sync started for: $storeDbPath");

  //     await syncService.pushUnsyncedData(storeDbPath);
  //     await syncService.pullFromServer(storeDbPath);

  //     if (mounted) {
  //       AppToast.show(
  //         context,
  //         message: "✅ Sync completed successfully!",
  //         type: ToastType.success,
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       AppToast.show(
  //         context,
  //         message: "❌ Sync failed: $e",
  //         type: ToastType.error,
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSyncing = false);
  //   }
  // }

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
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: Colors.blueAccent,
      //   icon: Icon(_isSyncing ? Icons.sync : Icons.cloud_sync),
      //   label: Text(_isSyncing ? "Syncing..." : "Sync Now"),
      //   onPressed: _isSyncing ? null : _manualSync,
      // ),
      // Add this to your owner_dashboard.dart in the scaffold
      // If you want separate FABs for each scenario
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Expired FAB
          FloatingActionButton(
            onPressed: () => _testScenario(context, 'expired'),
            child: Icon(Icons.timer_off),
            backgroundColor: Colors.red,
            mini: true,
            tooltip: "Test Expired",
          ),
          SizedBox(height: 10),

          // Expiring Soon FAB
          FloatingActionButton(
            onPressed: () => _testScenario(context, 'expiring_soon'),
            child: Icon(Icons.warning),
            backgroundColor: Colors.orange,
            mini: true,
            tooltip: "Test Expiring Soon",
          ),
          SizedBox(height: 10),

          // Valid FAB
          FloatingActionButton(
            onPressed: () => _testScenario(context, 'valid'),
            child: Icon(Icons.check_circle),
            backgroundColor: Colors.green,
            mini: true,
            tooltip: "Test Valid",
          ),
          SizedBox(height: 10),

          // Main FAB
          FloatingActionButton(
            onPressed: () => _showTestMenu(context),
            child: Icon(Icons.bug_report),
            backgroundColor: Colors.purple,
            tooltip: "All Test Scenarios",
          ),
        ],
      ),
    );
  }
}

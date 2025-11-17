import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_sidebar.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_topbar.dart';
import 'package:pos_desktop/presentation/dashboards/owner/screens/owner_store_management_screen.dart';
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

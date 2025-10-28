import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
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

  final List<Widget> pages = const [
    OwnerOverviewScreen(),
    OwnerInventoryScreen(),
    OwnerStaffScreen(),
    OwnerReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ use theme color instead of hardcoded hex
      backgroundColor: AppColors.background,

      body: Row(
        children: [
          // 🔹 Themed sidebar
          OwnerSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) => setState(() => selectedIndex = index),
          ),

          // 🔹 Main content area
          Expanded(
            child: Column(
              children: [
                // 🔸 Top bar (already has brand elements)
                const OwnerTopBar(),

                // 🔸 Dynamic content area with smooth transition
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

                // Optional footer
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

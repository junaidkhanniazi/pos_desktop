import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/componenets/sidebar.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/componenets/topbar.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/screens/owner_requests_screen.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/screens/reports_screens.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/screens/subscription_management_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/owners_screen.dart';
import 'screens/settings_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OverviewScreen(),
    OwnerRequestsScreen(),
    const OwnersScreen(),
    const ReportsScreen(),
    const SubscriptionManagementScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(
            child: Column(
              children: [
                const Topbar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, a) =>
                        FadeTransition(opacity: a, child: child),
                    child: _screens[_selectedIndex],
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

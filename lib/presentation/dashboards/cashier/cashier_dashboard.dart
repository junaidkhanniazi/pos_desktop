import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos_desktop/presentation/dashboards/cashier/screens/cahsier_sales_history_screen.dart';
import 'package:pos_desktop/presentation/dashboards/cashier/screens/cashier_%20shift_summary_screen.dart';
import 'package:pos_desktop/presentation/dashboards/cashier/screens/cashier_pos_screen.dart';
import 'package:pos_desktop/presentation/dashboards/common/base_dashboard_layout.dart';

class CashierDashboard extends StatelessWidget {
  const CashierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      SidebarItem(icon: LucideIcons.scanLine, label: 'POS'),
      SidebarItem(icon: LucideIcons.receipt, label: 'Sales History'),
      SidebarItem(icon: LucideIcons.badgeDollarSign, label: 'Shift Summary'),
    ];

    final pages = const [
      CashierPosScreen(),
      CashierSalesHistoryScreen(),
      CashierShiftSummaryScreen(),
    ];

    return BaseDashboardLayout(title: "Cashier", items: items, pages: pages);
  }
}

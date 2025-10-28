import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos_desktop/presentation/dashboards/accountant/screens/accountant_expenses_screen.dart';
import 'package:pos_desktop/presentation/dashboards/accountant/screens/accountant_finance_overview_screen.dart';
import 'package:pos_desktop/presentation/dashboards/accountant/screens/accountant_sales_report_screen.dart';
import 'package:pos_desktop/presentation/dashboards/common/base_dashboard_layout.dart';

class AccountantDashboard extends StatelessWidget {
  const AccountantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      SidebarItem(icon: LucideIcons.layoutPanelTop, label: 'Overview'),
      SidebarItem(icon: LucideIcons.barChart3, label: 'Sales Report'),
      SidebarItem(icon: LucideIcons.wallet2, label: 'Expenses'),
    ];
    final pages = const [
      AccountantFinanceOverviewScreen(),
      AccountantSalesReportScreen(),
      AccountantExpensesScreen(),
    ];
    return BaseDashboardLayout(title: "Accountant", items: items, pages: pages);
  }
}

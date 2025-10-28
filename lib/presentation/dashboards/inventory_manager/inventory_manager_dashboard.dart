import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos_desktop/presentation/dashboards/common/base_dashboard_layout.dart';
import 'package:pos_desktop/presentation/dashboards/inventory_manager/screens/inventory_manager_categories_brands_screen.dart';
import 'package:pos_desktop/presentation/dashboards/inventory_manager/screens/inventory_manager_products_screen.dart';
import 'package:pos_desktop/presentation/dashboards/inventory_manager/screens/inventory_manager_stock_overview_screen.dart';

class InventoryManagerDashboard extends StatelessWidget {
  const InventoryManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      SidebarItem(icon: LucideIcons.activity, label: 'Overview'),
      SidebarItem(icon: LucideIcons.box, label: 'Products'),
      SidebarItem(icon: LucideIcons.tags, label: 'Categories & Brands'),
    ];
    final pages = const [
      InventoryManagerStockOverviewScreen(),
      InventoryManagerProductsScreen(), // uses your OwnerInventoryScreen internally
      InventoryManagerCategoriesBrandsScreen(),
    ];
    return BaseDashboardLayout(
      title: "Inventory Manager",
      items: items,
      pages: pages,
    );
  }
}

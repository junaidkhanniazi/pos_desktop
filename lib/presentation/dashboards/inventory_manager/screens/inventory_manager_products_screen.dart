import 'package:flutter/material.dart';
import 'package:pos_desktop/presentation/dashboards/owner/screens/owner_inventory_screen.dart';

class InventoryManagerProductsScreen extends StatelessWidget {
  const InventoryManagerProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Reuse the category/brand inventory you already built
    return const OwnerInventoryScreen();
  }
}

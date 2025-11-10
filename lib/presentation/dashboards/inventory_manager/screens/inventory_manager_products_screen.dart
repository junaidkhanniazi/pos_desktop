import 'package:flutter/material.dart';

class InventoryManagerProductsScreen extends StatelessWidget {
  const InventoryManagerProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Reuse the category/brand inventory you already built
    return const OwnerInventoryScreen();
  }
}

class OwnerInventoryScreen extends StatelessWidget {
  const OwnerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

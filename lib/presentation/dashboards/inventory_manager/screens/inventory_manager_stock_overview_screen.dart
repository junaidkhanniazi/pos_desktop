import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_card.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_chart.dart';

class InventoryManagerStockOverviewScreen extends StatelessWidget {
  const InventoryManagerStockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Stock Overview",
              style: AppText.h1.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                OwnerCard(title: "Total SKUs", value: "342"),
                OwnerCard(title: "Low Stock", value: "27"),
                OwnerCard(title: "Out of Stock", value: "9"),
                OwnerCard(title: "Pending PO", value: "4"),
              ],
            ),
            const SizedBox(height: 24),
            const OwnerChart(),
          ],
        ),
      ),
    );
  }
}

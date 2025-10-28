import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';

class OwnerReportsScreen extends StatelessWidget {
  const OwnerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topProducts = [
      {"name": "iPhone 15 Case", "sales": 120},
      {"name": "Apple Watch Strap", "sales": 85},
      {"name": "Samsung S24 Cover", "sales": 74},
      {"name": "AirPods Skin", "sales": 52},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Text(
              "Reports & Analytics",
              style: AppText.h1.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 20),

            // 🔹 Summary Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: isWide
                      ? WrapAlignment.spaceBetween
                      : WrapAlignment.start,
                  children: [
                    _reportCard("Total Sales", "\$12,430", AppColors.primary),
                    _reportCard("Orders", "228", AppColors.secondary),
                    _reportCard("Profit", "\$2,130", AppColors.success),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),

            // 🔹 Top Products
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Top Selling Products",
                    style: AppText.h2.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  ...topProducts.map(
                    (p) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.background,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p['name'] as String,
                            style: AppText.body.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            "${p['sales']} sales",
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Download / Export Button
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: "Export Report",
                icon: Icons.download_rounded,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(String title, String value, Color accent) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppText.body.copyWith(color: AppColors.textMedium),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppText.h2.copyWith(color: accent)),
        ],
      ),
    );
  }
}

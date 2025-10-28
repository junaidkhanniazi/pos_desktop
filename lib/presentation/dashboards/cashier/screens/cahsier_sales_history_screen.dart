import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class CashierSalesHistoryScreen extends StatelessWidget {
  const CashierSalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final search = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sales History",
            style: AppText.h1.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 280,
                child: AppInput(
                  controller: search,
                  hint: "Search receipt # / customer",
                  icon: Icons.search,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListView.separated(
                itemCount: 8,
                separatorBuilder: (_, __) => Divider(color: AppColors.border),
                itemBuilder: (_, i) => ListTile(
                  title: Text(
                    "Receipt #10${30 + i}",
                    style: AppText.body.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "27 Oct 2025 • Cashier: Ali",
                    style: AppText.small,
                  ),
                  trailing: Text(
                    i.isEven ? "\$24.50" : "\$58.00",
                    style: AppText.h3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';

class CashierShiftSummaryScreen extends StatelessWidget {
  const CashierShiftSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shift Summary",
            style: AppText.h1.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _kpi("Total Bills", "42"),
              _kpi("Cash Collected", "\$620"),
              _kpi("Card Collected", "\$380"),
              _kpi("Refunds", "\$25"),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: AppButton(
              label: "Close Shift",
              icon: Icons.lock_clock,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpi(String title, String value) => Container(
    width: 220,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: AppColors.shadow.withOpacity(0.08), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.small.copyWith(color: AppColors.textMedium)),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppText.h2.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

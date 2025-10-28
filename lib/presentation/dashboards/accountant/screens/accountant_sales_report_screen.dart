import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_chart.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';

class AccountantSalesReportScreen extends StatelessWidget {
  const AccountantSalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sales Report",
            style: AppText.h1.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          const OwnerChart(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: "Export CSV",
              icon: Icons.download_rounded,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

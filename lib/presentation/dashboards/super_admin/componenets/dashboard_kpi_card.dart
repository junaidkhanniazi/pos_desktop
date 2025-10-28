import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

class DashboardKpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtext;

  const DashboardKpiCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppText.small.copyWith(color: AppColors.textMedium),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppText.h2.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtext != null) ...[
                  const SizedBox(height: 2),
                  Text(subtext!, style: AppText.small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

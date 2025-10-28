import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

class OwnerCard extends StatelessWidget {
  final String title;
  final String value;

  const OwnerCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Card Title
          Text(
            title,
            style: AppText.small.copyWith(
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // 🔹 Card Value
          Text(
            value,
            style: AppText.h2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),
          // 🔸 Decorative Divider (Optional accent)
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

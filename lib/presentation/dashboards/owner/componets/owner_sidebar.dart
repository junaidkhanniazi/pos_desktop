import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/state_management/login/logout_controller.dart';

class OwnerSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final _logoutController = LogoutController(); // ✅ use controller

  OwnerSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': LucideIcons.layoutDashboard, 'label': 'Overview'},
      {'icon': LucideIcons.box, 'label': 'Inventory'},
      {'icon': LucideIcons.users, 'label': 'Staff'},
      {'icon': LucideIcons.barChart3, 'label': 'Reports'},
    ];

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Text(
            "Owner Panel",
            style: AppText.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 36),

          // 🔹 Sidebar Items
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final isSelected = selectedIndex == i;
                final color = isSelected
                    ? AppColors.primary
                    : AppColors.textMedium;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onItemSelected(i),
                  hoverColor: AppColors.primary.withOpacity(0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[i]['icon'] as IconData,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          items[i]['label'] as String,
                          style: AppText.body.copyWith(
                            color: color,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 Logout Button (simple call to controller)
          InkWell(
            onTap: () => _logoutController.logout(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.logOut,
                    color: AppColors.textMedium,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Logout",
                    style: AppText.body.copyWith(color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

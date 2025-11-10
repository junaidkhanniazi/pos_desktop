import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final _logoutController = AuthController(); // ✅ use controller

  Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Overview'},
      {'icon': Icons.group_add_rounded, 'label': 'Owner Requests'},
      {'icon': Icons.people_alt_rounded, 'label': 'Owners'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Reports'},
      {
        'icon': Icons.subscriptions_rounded,
        'label': 'Subscriptions',
      }, // ✅ new screen
      {'icon': Icons.settings_rounded, 'label': 'Settings'},
    ];

    return Container(
      width: 240,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 26),
          Text(
            'Super Admin',
            style: AppText.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final selected = i == selectedIndex;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onItemSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[i]['icon'] as IconData,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textLight,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          items[i]['label'] as String,
                          style: AppText.body.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textDark,
                            fontWeight: selected
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.accent),
            title: Text(
              "Logout",
              style: AppText.body.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _logoutController.logout(), // ✅ clean call
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

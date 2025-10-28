import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class OwnerTopBar extends StatelessWidget {
  const OwnerTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Title / Logo
          Row(
            children: [
              Icon(
                LucideIcons.layoutDashboard,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "Dashboard",
                style: AppText.h3.copyWith(color: AppColors.textDark),
              ),
            ],
          ),

          // 🔹 Right side (search + notification + user)
          Row(
            children: [
              // 🔍 Search (optional)
              SizedBox(
                width: 220,
                child: AppInput(
                  controller: TextEditingController(),
                  hint: "Search...",
                  icon: LucideIcons.search,
                ),
              ),
              const SizedBox(width: 16),

              // 🔔 Notification icon
              _buildIconButton(
                icon: LucideIcons.bell,
                tooltip: "Notifications",
                onPressed: () {},
              ),
              const SizedBox(width: 8),

              // ⚙️ Settings icon
              _buildIconButton(
                icon: LucideIcons.settings,
                tooltip: "Settings",
                onPressed: () {},
              ),
              const SizedBox(width: 20),

              // 👤 User avatar with name
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Owner",
                    style: AppText.body.copyWith(color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable themed icon button
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: AppText.small.copyWith(color: Colors.white),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.textMedium, size: 20),
        ),
      ),
    );
  }
}

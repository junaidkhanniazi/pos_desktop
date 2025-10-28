import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: "Super Admin");
    final emailCtrl = TextEditingController(text: "admin@pos.app");
    final phoneCtrl = TextEditingController(text: "+92 300 1234567");

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Profile
          Expanded(
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Profile", style: AppText.h2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "System Super Admin",
                        style: AppText.body.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: nameCtrl,
                    hint: "Full Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  AppInput(
                    controller: emailCtrl,
                    hint: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 10),
                  AppInput(
                    controller: phoneCtrl,
                    hint: "Phone",
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: "Save Profile",
                      icon: Icons.check,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),

          // System
          Expanded(
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("System Settings", style: AppText.h2),
                  const SizedBox(height: 12),
                  _settingRow("Auto Backups", "Enabled"),
                  _settingRow("Data Retention", "90 days"),
                  _settingRow("Theme", "Light"),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AppButton(
                        label: "Backup Now",
                        icon: Icons.cloud_upload_rounded,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: "Clear Cache",
                        icon: Icons.cleaning_services_rounded,
                        onPressed: () {},
                        isPrimary: false,
                      ),
                      AppButton(
                        label: "Reset Defaults",
                        icon: Icons.restore_rounded,
                        onPressed: () {},
                        isPrimary: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(color: AppColors.shadow.withOpacity(0.08), blurRadius: 8),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: child,
  );

  Widget _settingRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: AppText.body),
        Text(
          v,
          style: AppText.body.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

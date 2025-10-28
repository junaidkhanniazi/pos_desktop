import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class OwnerStaffScreen extends StatefulWidget {
  const OwnerStaffScreen({super.key});

  @override
  State<OwnerStaffScreen> createState() => _OwnerStaffScreenState();
}

class _OwnerStaffScreenState extends State<OwnerStaffScreen> {
  final List<Map<String, String>> staff = [
    {"name": "Ahmed Raza", "role": "Cashier", "shift": "Morning"},
    {"name": "Sara Malik", "role": "Manager", "shift": "Evening"},
    {"name": "Bilal Khan", "role": "Sales", "shift": "Morning"},
    {"name": "Ayesha Tariq", "role": "Cashier", "shift": "Evening"},
  ];

  void _showStaffDialog({Map<String, String>? existingStaff, int? index}) {
    final nameCtrl = TextEditingController(text: existingStaff?['name'] ?? '');
    final roleCtrl = TextEditingController(text: existingStaff?['role'] ?? '');
    final shiftCtrl = TextEditingController(
      text: existingStaff?['shift'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existingStaff == null ? "Add New Staff" : "Edit Staff Member",
                style: AppText.h2.copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: 20),
              AppInput(
                controller: nameCtrl,
                hint: "Full Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 14),
              AppInput(
                controller: roleCtrl,
                hint: "Role",
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 14),
              AppInput(
                controller: shiftCtrl,
                hint: "Shift (e.g. Morning, Evening)",
                icon: Icons.access_time,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: "Cancel",
                    onPressed: () => Navigator.pop(context),
                    isPrimary: false,
                    width: 100,
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: existingStaff == null ? "Add" : "Update",
                    icon: existingStaff == null ? Icons.add : Icons.check,
                    onPressed: () {
                      final newData = {
                        "name": nameCtrl.text.trim(),
                        "role": roleCtrl.text.trim(),
                        "shift": shiftCtrl.text.trim(),
                      };

                      setState(() {
                        if (existingStaff == null) {
                          staff.add(newData);
                        } else {
                          staff[index!] = newData;
                        }
                      });

                      Navigator.pop(context);
                    },
                    width: 120,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Staff", style: AppText.h2),
        content: Text(
          "Are you sure you want to remove ${staff[index]['name']}?",
          style: AppText.body.copyWith(color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: AppText.body.copyWith(color: AppColors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => staff.removeAt(index));
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: AppText.body.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Staff Management",
                style: AppText.h1.copyWith(color: AppColors.textDark),
              ),
              AppButton(
                label: "Add Staff",
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () => _showStaffDialog(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🔹 Staff List
          Expanded(
            child: Container(
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
              child: ListView.separated(
                itemCount: staff.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final person = staff[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        person['name']![0],
                        style: AppText.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      person['name']!,
                      style: AppText.h3.copyWith(color: AppColors.textDark),
                    ),
                    subtitle: Text(
                      "Role: ${person['role']}  •  Shift: ${person['shift']}",
                      style: AppText.body.copyWith(color: AppColors.textMedium),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Edit Staff",
                          icon: const Icon(Icons.edit_outlined),
                          color: AppColors.primary,
                          onPressed: () => _showStaffDialog(
                            existingStaff: person,
                            index: index,
                          ),
                        ),
                        IconButton(
                          tooltip: "Remove Staff",
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.error.withOpacity(0.8),
                          onPressed: () => _showDeleteDialog(index),
                        ),
                      ],
                    ),
                    hoverColor: AppColors.primary.withOpacity(0.04),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

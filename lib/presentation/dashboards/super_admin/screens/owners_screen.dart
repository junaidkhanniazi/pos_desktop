import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class OwnersScreen extends StatefulWidget {
  const OwnersScreen({super.key});

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  final searchCtrl = TextEditingController();
  final owners = <Map<String, dynamic>>[
    {
      "name": "TechMart",
      "owner": "Ali Raza",
      "email": "ali@techmart.com",
      "stores": 3,
      "status": "Active",
    },
    {
      "name": "HyperCity",
      "owner": "Sarah Khan",
      "email": "sarah@hypercity.pk",
      "stores": 5,
      "status": "Active",
    },
    {
      "name": "QuickShop",
      "owner": "Bilal Ahmed",
      "email": "bilal@quickshop.pk",
      "stores": 1,
      "status": "Suspended",
    },
    {
      "name": "Everyday Mart",
      "owner": "Ayesha Tariq",
      "email": "ayesha@everyday.com",
      "stores": 2,
      "status": "Pending",
    },
  ];

  void _addOwnerDialog() {
    final storeName = TextEditingController();
    final ownerName = TextEditingController();
    final email = TextEditingController();
    final stores = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add New Owner", style: AppText.h2),
                const SizedBox(height: 14),
                AppInput(
                  controller: storeName,
                  hint: "Store / Brand Name",
                  icon: Icons.store_mall_directory_outlined,
                ),
                const SizedBox(height: 10),
                AppInput(
                  controller: ownerName,
                  hint: "Owner Full Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 10),
                AppInput(
                  controller: email,
                  hint: "Email",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 10),
                AppInput(
                  controller: stores,
                  hint: "Number of Stores",
                  icon: Icons.numbers_outlined,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: "Cancel",
                      isPrimary: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    AppButton(
                      label: "Add Owner",
                      icon: Icons.check,
                      onPressed: () {
                        setState(() {
                          owners.insert(0, {
                            "name": storeName.text.trim(),
                            "owner": ownerName.text.trim(),
                            "email": email.text.trim(),
                            "stores": int.tryParse(stores.text.trim()) ?? 1,
                            "status": "Pending",
                          });
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
    "Active" => AppColors.success,
    "Pending" => AppColors.warning,
    _ => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Owners Management",
                style: AppText.h1.copyWith(color: AppColors.textDark),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 280,
                    child: AppInput(
                      controller: searchCtrl,
                      hint: "Search owner/store/email",
                      icon: Icons.search,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: "Add Owner",
                    icon: Icons.add,
                    onPressed: _addOwnerDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.background,
                  ),
                  headingTextStyle: AppText.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  dataRowHeight: 56,
                  columns: const [
                    DataColumn(label: Text("Store")),
                    DataColumn(label: Text("Owner")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Stores")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: owners.map((o) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            o['name'],
                            style: AppText.body.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DataCell(Text(o['owner'], style: AppText.body)),
                        DataCell(Text(o['email'], style: AppText.small)),
                        DataCell(Text("${o['stores']}", style: AppText.body)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                o['status'],
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              o['status'],
                              style: AppText.small.copyWith(
                                color: _statusColor(o['status']),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                                onPressed: () {
                                  setState(() => o['status'] = "Active");
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.pause_circle_outline,
                                  color: AppColors.warning,
                                ),
                                onPressed: () {
                                  setState(() => o['status'] = "Pending");
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.block,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  setState(() => o['status'] = "Suspended");
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

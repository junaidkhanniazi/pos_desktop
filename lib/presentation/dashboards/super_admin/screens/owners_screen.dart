import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

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

  Color _statusColor(String s) => switch (s) {
    "Active" => AppColors.success,
    "Pending" => AppColors.warning,
    _ => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Owners Management",
                style: AppText.h1.copyWith(color: AppColors.textDark),
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

import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class AccountantExpensesScreen extends StatefulWidget {
  const AccountantExpensesScreen({super.key});
  @override
  State<AccountantExpensesScreen> createState() =>
      _AccountantExpensesScreenState();
}

class _AccountantExpensesScreenState extends State<AccountantExpensesScreen> {
  final items = <Map<String, dynamic>>[
    {"title": "Electricity Bill", "amount": 210.0},
    {"title": "Packaging Material", "amount": 120.0},
    {"title": "Internet", "amount": 50.0},
  ];

  void _addExpenseDialog() {
    final t = TextEditingController();
    final a = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Expense", style: AppText.h2),
              const SizedBox(height: 12),
              AppInput(
                controller: t,
                hint: "Title",
                icon: Icons.note_alt_outlined,
              ),
              const SizedBox(height: 10),
              AppInput(
                controller: a,
                hint: "Amount (\$)",
                icon: Icons.attach_money,
              ),
              const SizedBox(height: 16),
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
                    label: "Add",
                    icon: Icons.add,
                    onPressed: () {
                      final title = t.text.trim();
                      final amt = double.tryParse(a.text.trim()) ?? 0;
                      if (title.isNotEmpty && amt > 0) {
                        setState(
                          () => items.add({"title": title, "amount": amt}),
                        );
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Expenses",
                style: AppText.h1.copyWith(color: AppColors.textDark),
              ),
              AppButton(
                label: "Add Expense",
                icon: Icons.add,
                onPressed: _addExpenseDialog,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(color: AppColors.border),
                itemBuilder: (_, i) => ListTile(
                  title: Text(
                    items[i]['title'],
                    style: AppText.body.copyWith(color: AppColors.textDark),
                  ),
                  trailing: Text(
                    "\$${(items[i]['amount'] as num).toStringAsFixed(2)}",
                    style: AppText.h3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

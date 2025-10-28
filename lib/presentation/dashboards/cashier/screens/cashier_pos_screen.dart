import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class CashierPosScreen extends StatelessWidget {
  const CashierPosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scanCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: "1");

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left: Cart
          Expanded(
            flex: 3,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cart",
                    style: AppText.h2.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          controller: scanCtrl,
                          hint: "Scan barcode or search product",
                          icon: Icons.qr_code_scanner,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        child: AppInput(
                          controller: qtyCtrl,
                          hint: "Qty",
                          icon: Icons.numbers,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        label: "Add",
                        icon: Icons.add,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (_, __) =>
                          Divider(color: AppColors.border),
                      itemBuilder: (_, i) => ListTile(
                        title: Text(
                          "Sample Product ${i + 1}",
                          style: AppText.body.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "Qty: 1 × \$10.00",
                          style: AppText.small,
                        ),
                        trailing: Text(
                          "\$10.00",
                          style: AppText.h3.copyWith(color: AppColors.textDark),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Right: Totals & Payment
          Expanded(
            flex: 2,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal", style: AppText.body),
                      Text("\$40.00", style: AppText.h3),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Discount", style: AppText.body),
                      Text(
                        "-\$2.00",
                        style: AppText.h3.copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tax (8%)", style: AppText.body),
                      Text("\$3.04", style: AppText.h3),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total", style: AppText.h2),
                      Text(
                        "\$41.04",
                        style: AppText.h2.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: "Cash",
                    icon: Icons.payments,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: "Card",
                    icon: Icons.credit_card,
                    onPressed: () {},
                    isPrimary: false,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: "Print Receipt",
                    icon: Icons.print_rounded,
                    onPressed: () {},
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

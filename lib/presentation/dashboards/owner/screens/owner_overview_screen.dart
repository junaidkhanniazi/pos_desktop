import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import '../componets/owner_card.dart';
import '../componets/owner_chart.dart';

class OwnerOverviewScreen extends StatelessWidget {
  const OwnerOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Text(
              "Overview",
              style: AppText.h1.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 20),

            // 🔹 Summary Cards
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                OwnerCard(title: "Total Sales", value: "\$12,430"),
                OwnerCard(title: "Active Staff", value: "14"),
                OwnerCard(title: "Low Stock Items", value: "5"),
                OwnerCard(title: "Monthly Profit", value: "\$2,130"),
              ],
            ),
            const SizedBox(height: 40),

            // 🔹 Sales Chart Section
            Text(
              "Sales Overview",
              style: AppText.h2.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            const OwnerChart(),
            const SizedBox(height: 30),

            // 🔹 Recent Transactions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Transactions",
                    style: AppText.h2.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.background,
                      ),
                      dataRowHeight: 56,
                      headingTextStyle: AppText.body.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Customer")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Status")),
                      ],
                      rows: [
                        _buildTransactionRow(
                          "27 Oct 2025",
                          "Ali Khan",
                          "\$120",
                          "Completed",
                        ),
                        _buildTransactionRow(
                          "27 Oct 2025",
                          "Sarah Ahmad",
                          "\$90",
                          "Pending",
                        ),
                        _buildTransactionRow(
                          "26 Oct 2025",
                          "Usman Raza",
                          "\$310",
                          "Completed",
                        ),
                        _buildTransactionRow(
                          "25 Oct 2025",
                          "Areeba Zafar",
                          "\$75",
                          "Cancelled",
                        ),
                        _buildTransactionRow(
                          "25 Oct 2025",
                          "Hassan Iqbal",
                          "\$260",
                          "Refunded",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DataRow _buildTransactionRow(
  String date,
  String customer,
  String amount,
  String status,
) {
  Color statusColor;
  Color statusBg;

  switch (status) {
    case "Completed":
      statusColor = AppColors.success;
      statusBg = AppColors.success.withOpacity(0.15);
      break;
    case "Pending":
      statusColor = AppColors.warning;
      statusBg = AppColors.warning.withOpacity(0.2);
      break;
    case "Cancelled":
      statusColor = AppColors.error;
      statusBg = AppColors.error.withOpacity(0.2);
      break;
    case "Refunded":
      statusColor = AppColors.secondary;
      statusBg = AppColors.secondary.withOpacity(0.2);
      break;
    default:
      statusColor = AppColors.textMedium;
      statusBg = AppColors.border;
  }

  return DataRow(
    color: WidgetStateProperty.resolveWith<Color?>(
      (states) =>
          states.contains(WidgetState.hovered) ? AppColors.background : null,
    ),
    cells: [
      DataCell(
        Text(date, style: AppText.body.copyWith(color: AppColors.textDark)),
      ),
      DataCell(
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            customer,
            style: AppText.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
      DataCell(
        Text(amount, style: AppText.body.copyWith(color: AppColors.textDark)),
      ),
      DataCell(
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: AppText.small.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

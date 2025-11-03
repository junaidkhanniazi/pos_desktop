import 'package:flutter/material.dart';
import 'package:pos_desktop/presentation/dashboards/owner/componets/owner_card.dart';

class AccountantFinanceOverviewScreen extends StatelessWidget {
  const AccountantFinanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: const [
          OwnerCard(title: "Today Sales", value: "\$1,240"),
          OwnerCard(title: "Month Sales", value: "\$25,980"),
          OwnerCard(title: "Expenses (Month)", value: "\$6,320"),
          OwnerCard(title: "Net Profit (Est.)", value: "\$19,660"),
        ],
      ),
    );
  }
}

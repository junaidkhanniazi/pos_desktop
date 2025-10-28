import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Platform Reports",
            style: AppText.h1.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 16),

          // charts row
          Expanded(
            child: Row(
              children: [
                // Revenue bar chart
                Expanded(
                  child: _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Monthly Revenue", style: AppText.h3),
                        const SizedBox(height: 10),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      const m = [
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                      ];
                                      final i = v.toInt();
                                      return i >= 0 && i < m.length
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                m[i],
                                                style: AppText.small,
                                              ),
                                            )
                                          : const SizedBox();
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(7, (i) {
                                final values = [
                                  12.0,
                                  11.0,
                                  13.5,
                                  14.0,
                                  15.2,
                                  16.8,
                                  18.0,
                                ];
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: values[i],
                                      width: 16,
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                // Top owners
                Expanded(
                  child: _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Top Performing Stores", style: AppText.h3),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView(
                            children: [
                              _topTile("HyperCity", "\$6,240"),
                              _topTile("TechMart Lahore", "\$5,820"),
                              _topTile("Everyday Mart", "\$4,390"),
                              _topTile("QuickShop", "\$3,210"),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: AppButton(
                            label: "Export CSV",
                            icon: Icons.download_rounded,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _topTile(String name, String amt) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const CircleAvatar(
      backgroundColor: Color(0xFFEFF2FF),
      child: Icon(Icons.store_mall_directory, color: AppColors.primary),
    ),
    title: Text(
      name,
      style: AppText.body.copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
    ),
    trailing: Text(amt, style: AppText.h3),
  );
}

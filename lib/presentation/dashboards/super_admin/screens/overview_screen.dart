import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/componenets/dashboard_card.dart';
import 'package:pos_desktop/presentation/dashboards/super_admin/componenets/dashboard_kpi_card.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = const [
      ('Total Owners', '24', Icons.store_mall_directory, '+2 this week'),
      ('Active Users', '145', Icons.people_alt, '↑ 6% MoM'),
      ('Revenue', '\$12,340', Icons.attach_money, 'Oct 2025'),
      ('Pending Shops', '5', Icons.pending_actions, 'Need review'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overview Dashboard",
              style: AppText.h1.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 16),

            // KPIs
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: stats
                  .map(
                    (s) => DashboardKpiCard(
                      title: s.$1,
                      value: s.$2,
                      icon: s.$3,
                      subtext: s.$4,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Charts + Recent Activity
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue trend
                Expanded(
                  child: GlassCard(
                    child: SizedBox(
                      height: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Platform Revenue (Last 7 months)",
                            style: AppText.h3,
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (v, _) => Text(
                                        "\$${v.toInt()}k",
                                        style: AppText.small,
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, _) {
                                        const months = [
                                          'Apr',
                                          'May',
                                          'Jun',
                                          'Jul',
                                          'Aug',
                                          'Sep',
                                          'Oct',
                                        ];
                                        final i = v.toInt();
                                        return i >= 0 && i < months.length
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Text(
                                                  months[i],
                                                  style: AppText.small.copyWith(
                                                    color: AppColors.textMedium,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox();
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: 20,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: const [
                                      FlSpot(0, 6),
                                      FlSpot(1, 8),
                                      FlSpot(2, 7),
                                      FlSpot(3, 10),
                                      FlSpot(4, 12),
                                      FlSpot(5, 15),
                                      FlSpot(6, 18),
                                    ],
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withOpacity(0.25),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                // Recent Activity
                Expanded(
                  child: GlassCard(
                    child: SizedBox(
                      height: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Recent Activity", style: AppText.h3),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.separated(
                              itemCount: 6,
                              separatorBuilder: (_, __) =>
                                  Divider(color: AppColors.border),
                              itemBuilder: (_, i) {
                                final items = [
                                  (
                                    "New Owner Registered",
                                    "TechMart Lahore",
                                    "2h ago",
                                  ),
                                  ("Owner Approved", "Everyday Mart", "5h ago"),
                                  ("Store Suspended", "QuickShop", "20h ago"),
                                  (
                                    "Revenue Settlement",
                                    "Monthly payout",
                                    "1d ago",
                                  ),
                                  ("New Cashier Added", "HyperCity", "1d ago"),
                                  (
                                    "Backup Completed",
                                    "System backup",
                                    "2d ago",
                                  ),
                                ];
                                final it = items[i];
                                return ListTile(
                                  title: Text(
                                    it.$1,
                                    style: AppText.body.copyWith(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${it.$2} • ${it.$3}",
                                    style: AppText.small,
                                  ),
                                  leading: const Icon(
                                    Icons.bolt,
                                    color: AppColors.secondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

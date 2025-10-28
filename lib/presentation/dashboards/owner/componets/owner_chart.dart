import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

class OwnerChart extends StatelessWidget {
  const OwnerChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> salesData = [3.5, 4.2, 3.8, 5.0, 4.6, 6.2, 5.5];
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Chart Title
          Text(
            "Monthly Sales Overview",
            style: AppText.h3.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            "Sales trend (in thousands)",
            style: AppText.small.copyWith(color: AppColors.textMedium),
          ),
          const SizedBox(height: 20),

          // 🔹 Chart Section
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text(
                        '\$${value.toInt()}k',
                        style: AppText.small.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              months[index],
                              style: AppText.small.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 34,
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
                maxX: months.length.toDouble() - 1,
                minY: 0,
                maxY: 8,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      salesData.length,
                      (i) => FlSpot(i.toDouble(), salesData[i]),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
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
                    barWidth: 3,
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

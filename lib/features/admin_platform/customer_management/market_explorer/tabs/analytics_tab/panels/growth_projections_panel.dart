// lib/features/admin_platform/customer_management/market_explorer/tabs/analytics_tab/panels/growth_projections_panel.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/zaecdcenters_model.dart';
import '../dialogs/analytics_dialogs.dart';

class GrowthProjectionsPanel extends StatelessWidget {
  final MarketAnalytics analytics;
  final String selectedTimeframe;

  const GrowthProjectionsPanel({
    super.key,
    required this.analytics,
    required this.selectedTimeframe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Growth Projections',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Configure'),
                  onPressed: () => AnalyticsDialogs.showProjectionSettingsDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'Current',
                            'Year 1',
                            'Year 2',
                            'Year 3',
                            'Year 5'
                          ];
                          if (value.toInt() < titles.length) {
                            return Text(titles[value.toInt()],
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Conservative projection
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 127),
                        FlSpot(1, 415),
                        FlSpot(2, 1040),
                        FlSpot(3, 2078),
                        FlSpot(4, 4157),
                      ],
                      isCurved: true,
                      color: const Color(0xFF875DEC),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF875DEC).withOpacity(0.1),
                      ),
                    ),
                    // Aggressive projection
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 127),
                        FlSpot(1, 623),
                        FlSpot(2, 1560),
                        FlSpot(3, 3118),
                        FlSpot(4, 6236),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF875DEC), 'Conservative'),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.green, 'Aggressive'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
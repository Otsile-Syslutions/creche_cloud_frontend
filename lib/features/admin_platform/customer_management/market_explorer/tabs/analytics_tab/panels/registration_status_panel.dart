// lib/features/admin_platform/customer_management/market_explorer/tabs/analytics_tab/panels/registration_status_panel.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/zaecdcenters_model.dart';

class RegistrationStatusPanel extends StatelessWidget {
  final MarketAnalytics analytics;

  const RegistrationStatusPanel({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final total = analytics.byRegistrationStatus
        .fold(0, (sum, item) => sum + item.count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registration Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: analytics.byRegistrationStatus
                      .map((status) => PieChartSectionData(
                    value: status.count.toDouble(),
                    title:
                    '${((status.count / total) * 100).toStringAsFixed(1)}%',
                    color: _getStatusColor(status.status),
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...analytics.byRegistrationStatus.map((status) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${status.status}: ${status.count}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Fully registered':
        return Colors.green;
      case 'Conditionally registered':
        return Colors.orange;
      case 'In process':
        return Colors.blue;
      case 'Not registered':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
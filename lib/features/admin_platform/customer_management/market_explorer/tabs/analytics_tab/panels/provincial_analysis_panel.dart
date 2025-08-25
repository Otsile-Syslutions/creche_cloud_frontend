// lib/features/admin_platform/customer_management/market_explorer/tabs/analytics_tab/panels/provincial_analysis_panel.dart

import 'package:flutter/material.dart';
import '../../../models/zaecdcenters_model.dart';
import '../dialogs/analytics_dialogs.dart';

class ProvincialAnalysisPanel extends StatelessWidget {
  final MarketAnalytics analytics;
  final String selectedTimeframe;

  const ProvincialAnalysisPanel({
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
                  'Provincial Market Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => AnalyticsDialogs.showExportAnalyticsDialog(),
                  tooltip: 'Export Data',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Province')),
                  DataColumn(label: Text('Total Centers')),
                  DataColumn(label: Text('Registered')),
                  DataColumn(label: Text('Penetration')),
                  DataColumn(label: Text('Potential MRR')),
                  DataColumn(label: Text('Opportunity')),
                ],
                rows: analytics.byProvince
                    .map((province) => _buildProvincialRow(province))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildProvincialRow(ProvinceStats province) {
    final penetration = province.registered > 0
        ? (province.registered / province.count) * 100
        : 0.0;

    return DataRow(
      cells: [
        DataCell(Text(province.province)),
        DataCell(Text(province.count.toString())),
        DataCell(Text(province.registered.toString())),
        DataCell(Text('${penetration.toStringAsFixed(2)}%')),
        DataCell(Text('R${(province.potentialMRR / 1000).toStringAsFixed(0)}k')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: penetration < 0.2
                  ? Colors.red[100]
                  : penetration < 0.3
                  ? Colors.orange[100]
                  : Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              penetration < 0.2
                  ? 'High'
                  : penetration < 0.3
                  ? 'Medium'
                  : 'Low',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: penetration < 0.2
                    ? Colors.red[700]
                    : penetration < 0.3
                    ? Colors.orange[700]
                    : Colors.green[700],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
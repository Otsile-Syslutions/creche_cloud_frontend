// lib/features/admin_platform/customer_management/market_explorer/tabs/analytics_tab/panels/key_metrics_panel.dart

import 'package:flutter/material.dart';
import '../../../models/zaecdcenters_model.dart';

class KeyMetricsPanel extends StatelessWidget {
  final MarketAnalytics analytics;
  final String selectedTimeframe;

  const KeyMetricsPanel({
    super.key,
    required this.analytics,
    required this.selectedTimeframe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticsCard(
            'Total Market',
            '${analytics.overall.totalCenters}',
            'ECD Centers',
            Icons.business,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Market Penetration',
            '${analytics.conversionMetrics.conversionRate.toStringAsFixed(2)}%',
            '${analytics.conversionMetrics.converted} customers',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Potential MRR',
            'R${_formatCurrency(analytics.overall.totalPotentialMRR)}',
            'At full penetration',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'In Progress',
            '${analytics.conversionMetrics.inProgress}',
            'Active leads',
            Icons.account_balance_wallet,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color color,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
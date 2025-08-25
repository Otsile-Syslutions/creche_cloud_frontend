// lib/features/admin_platform/customer_management/market_explorer/tabs/analytics_tab/panels/opportunity_mapping_panel.dart

import 'package:flutter/material.dart';
import '../../../models/zaecdcenters_model.dart';

class OpportunityMappingPanel extends StatelessWidget {
  final List<ZAECDCenters> prospects;
  final String selectedTimeframe;

  const OpportunityMappingPanel({
    super.key,
    required this.prospects,
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
            const Text(
              'Opportunity Mapping',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOpportunityCard(
                    'High-Value Targets',
                    '${prospects.where((p) => p.numberOfChildren >= 100).length} centers',
                    '100+ children',
                    'High potential MRR',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOpportunityCard(
                    'Medium-Value Targets',
                    '${prospects.where((p) => p.numberOfChildren >= 50 && p.numberOfChildren < 100).length} centers',
                    '50-100 children',
                    'Medium potential MRR',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOpportunityCard(
                    'Small-Value Targets',
                    '${prospects.where((p) => p.numberOfChildren < 50).length} centers',
                    '1-50 children',
                    'Lower potential MRR',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(
      String title,
      String count,
      String size,
      String potential,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(count,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(size, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            potential,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
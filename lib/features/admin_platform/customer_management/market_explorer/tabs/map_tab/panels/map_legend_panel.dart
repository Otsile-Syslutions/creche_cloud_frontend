// lib/features/admin_platform/customer_management/market_explorer/tabs/map_tab/panels/map_legend_panel.dart

import 'package:flutter/material.dart';

class MapLegendPanel extends StatelessWidget {
  final bool showCompetitors;
  final bool showTerritories;

  const MapLegendPanel({
    super.key,
    required this.showCompetitors,
    required this.showTerritories,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Legend',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(Colors.green, 'Customer'),
            _buildLegendItem(Colors.red, 'Hot Prospect (80+)'),
            _buildLegendItem(Colors.orange, 'Qualified (60-79)'),
            _buildLegendItem(Colors.blue, 'Lead (40-59)'),
            _buildLegendItem(Colors.grey, 'Cold Prospect (<40)'),
            if (showCompetitors) ...[
              const Divider(height: 12),
              _buildLegendItem(Colors.purple, 'Competitor'),
            ],
            if (showTerritories) ...[
              const Divider(height: 12),
              const Text('Territories:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              _buildLegendItem(
                  Colors.blue.withOpacity(0.3), 'Gauteng North'),
              _buildLegendItem(
                  Colors.green.withOpacity(0.3), 'Gauteng South'),
              _buildLegendItem(
                  Colors.orange.withOpacity(0.3), 'KZN Coastal'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
// lib/features/admin_platform/customer_management/market_explorer/tabs/map_tab/panels/territory_panel.dart

import 'package:flutter/material.dart';
import '../dialogs/map_territory_dialogs.dart';

class TerritoryPanel extends StatelessWidget {
  final VoidCallback onClose;

  const TerritoryPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Territory Management',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTerritoryCard(
                      'Gauteng North', 1247, 29, 'Sarah M.'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTerritoryCard(
                      'Gauteng South', 890, 18, 'John K.'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:
                  _buildTerritoryCard('KZN Coastal', 567, 12, 'Mary T.'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create Territory'),
                  onPressed: () => TerritoryDialogs.showCreateTerritoryDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF875DEC),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export'),
                  onPressed: () => TerritoryDialogs.showExportTerritoriesDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF875DEC),
                    side: const BorderSide(color: Color(0xFF875DEC)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerritoryCard(
      String name, int prospects, int customers, String rep) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text('$prospects prospects', style: const TextStyle(fontSize: 10)),
          Text('$customers customers', style: const TextStyle(fontSize: 10)),
          Text('Rep: $rep',
              style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
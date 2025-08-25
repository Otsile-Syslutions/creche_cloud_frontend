// lib/features/admin_platform/customer_management/market_explorer/tabs/map_tab/panels/map_controls_panel.dart

import 'package:flutter/material.dart';

class MapControlsPanel extends StatelessWidget {
  final String selectedMapType;
  final bool showHeatMap;
  final bool showClusters;
  final bool showTerritories;
  final bool showCompetitors;
  final Function(String) onMapTypeChanged;
  final Function(bool) onHeatMapToggled;
  final Function(bool) onClustersToggled;
  final Function(bool) onTerritoriesToggled;
  final Function(bool) onCompetitorsToggled;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitAll;

  const MapControlsPanel({
    super.key,
    required this.selectedMapType,
    required this.showHeatMap,
    required this.showClusters,
    required this.showTerritories,
    required this.showCompetitors,
    required this.onMapTypeChanged,
    required this.onHeatMapToggled,
    required this.onClustersToggled,
    required this.onTerritoriesToggled,
    required this.onCompetitorsToggled,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Map Type Toggle
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapTypeButton('roadmap', 'Road', Icons.map),
                _buildMapTypeButton('satellite', 'Satellite', Icons.satellite),
                _buildMapTypeButton('hybrid', 'Hybrid', Icons.layers),
              ],
            ),

            const Divider(height: 16),

            // View Options
            Column(
              children: [
                _buildToggleButton(
                  'Heat Map',
                  showHeatMap,
                  Icons.whatshot,
                  onHeatMapToggled,
                ),
                _buildToggleButton(
                  'Clusters',
                  showClusters,
                  Icons.group_work,
                  onClustersToggled,
                ),
                _buildToggleButton(
                  'Territories',
                  showTerritories,
                  Icons.border_all,
                  onTerritoriesToggled,
                ),
                _buildToggleButton(
                  'Competitors',
                  showCompetitors,
                  Icons.business,
                  onCompetitorsToggled,
                ),
              ],
            ),

            const Divider(height: 16),

            // Zoom Controls
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onZoomIn,
                  tooltip: 'Zoom In',
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: onZoomOut,
                  tooltip: 'Zoom Out',
                ),
                IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: onFitAll,
                  tooltip: 'Fit All',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeButton(String type, String label, IconData icon) {
    final isSelected = selectedMapType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () => onMapTypeChanged(type),
            style: IconButton.styleFrom(
              backgroundColor: isSelected ? Colors.blue[100] : null,
              foregroundColor: isSelected ? Colors.blue[700] : null,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String label,
      bool value,
      IconData icon,
      Function(bool) onChanged,
      ) {
    return SwitchListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
// lib/features/admin_platform/schools_management/market_explorer/views/map_analytics_views.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../models/zaecdcenters_model.dart';

// Map View Implementation
class MarketExplorerMapView extends StatefulWidget {
  final List<ZAECDCenters> prospects;
  final Function(ZAECDCenters) onProspectSelected;

  const MarketExplorerMapView({
    super.key,
    required this.prospects,
    required this.onProspectSelected,
  });

  @override
  State<MarketExplorerMapView> createState() => _MarketExplorerMapViewState();
}

class _MarketExplorerMapViewState extends State<MarketExplorerMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polygon> _territories = {};
  bool _showHeatMap = false;
  bool _showClusters = true;
  bool _showTerritories = false;
  bool _showCompetitors = false;
  String _selectedMapType = 'roadmap';
  ZAECDCenters? _selectedProspect;

  // South Africa bounds
  static const LatLng _center = LatLng(-28.5, 24.0);
  static const double _zoom = 6.0;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _center,
            zoom: _zoom,
          ),
          markers: _markers,
          polygons: _territories,
          mapType: _getMapType(),
          onTap: _onMapTap,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
        ),

        // Map Controls Overlay
        Positioned(
          top: 16,
          left: 16,
          child: _buildMapControls(),
        ),

        // Legend Overlay
        Positioned(
          top: 16,
          right: 16,
          child: _buildMapLegend(),
        ),

        // Territory Panel (when territories are shown)
        if (_showTerritories)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildTerritoryPanel(),
          ),

        // Prospect Details Panel (when prospect is selected)
        if (_selectedProspect != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildProspectDetailsPanel(),
          ),
      ],
    );
  }

  Widget _buildMapControls() {
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
                  _showHeatMap,
                  Icons.whatshot,
                      (value) => setState(() => _showHeatMap = value),
                ),
                _buildToggleButton(
                  'Clusters',
                  _showClusters,
                  Icons.group_work,
                      (value) => setState(() => _showClusters = value),
                ),
                _buildToggleButton(
                  'Territories',
                  _showTerritories,
                  Icons.border_all,
                      (value) => setState(() => _showTerritories = value),
                ),
                _buildToggleButton(
                  'Competitors',
                  _showCompetitors,
                  Icons.business,
                      (value) => setState(() => _showCompetitors = value),
                ),
              ],
            ),

            const Divider(height: 16),

            // Zoom Controls
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _zoomIn,
                  tooltip: 'Zoom In',
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _zoomOut,
                  tooltip: 'Zoom Out',
                ),
                IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: _fitAllMarkers,
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
    final isSelected = _selectedMapType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () => setState(() => _selectedMapType = type),
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

  Widget _buildMapLegend() {
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
            if (_showCompetitors) ...[
              const Divider(height: 12),
              _buildLegendItem(Colors.purple, 'Competitor'),
            ],
            if (_showTerritories) ...[
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

  Widget _buildTerritoryPanel() {
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
                  onPressed: () => setState(() => _showTerritories = false),
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
                  onPressed: _createTerritory,
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export'),
                  onPressed: _exportTerritories,
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

  Widget _buildProspectDetailsPanel() {
    if (_selectedProspect == null) return const SizedBox.shrink();

    return Card(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedProspect!.ecdName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _selectedProspect = null),
                ),
              ],
            ),
            const Divider(),
            Text('${_selectedProspect!.numberOfChildren} children'),
            Text('Score: ${_selectedProspect!.leadScore}'),
            Text('Status: ${_selectedProspect!.registrationStatus}'),
            if (_selectedProspect!.contactPerson != null)
              Text('Contact: ${_selectedProspect!.contactPerson}'),
            if (_selectedProspect!.telephone != null)
              Text('Phone: ${_selectedProspect!.telephone}'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              onPressed: () => widget.onProspectSelected(_selectedProspect!),
            ),
          ],
        ),
      ),
    );
  }

  void _createMarkers() {
    _markers.clear();

    for (final prospect in widget.prospects) {
      // Use location coordinates if available
      double? lat, lng;

      if (prospect.location != null && prospect.location!.coordinates.length >= 2) {
        lng = prospect.location!.longitude;
        lat = prospect.location!.latitude;
      } else if (prospect.gisLatitude != null && prospect.gisLongitude != null) {
        lat = double.tryParse(prospect.gisLatitude!);
        lng = double.tryParse(prospect.gisLongitude!);
      }

      if (lat != null && lng != null && lat != 0 && lng != 0) {
        final markerId = MarkerId(prospect.id);
        final marker = Marker(
          markerId: markerId,
          position: LatLng(lat, lng),
          icon: _getMarkerIcon(prospect),
          infoWindow: InfoWindow(
            title: prospect.ecdName,
            snippet:
            '${prospect.numberOfChildren} children • Score: ${prospect.leadScore}',
            onTap: () => widget.onProspectSelected(prospect),
          ),
          onTap: () => setState(() => _selectedProspect = prospect),
        );

        _markers.add(marker);
      }
    }
  }

  BitmapDescriptor _getMarkerIcon(ZAECDCenters prospect) {
    if (prospect.leadStatus == 'Customer') {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (prospect.leadScore >= 80) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (prospect.leadScore >= 60) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (prospect.leadScore >= 40) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    } else {
      return BitmapDescriptor.defaultMarker;
    }
  }

  MapType _getMapType() {
    switch (_selectedMapType) {
      case 'satellite':
        return MapType.satellite;
      case 'hybrid':
        return MapType.hybrid;
      default:
        return MapType.normal;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedProspect = null);
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _fitAllMarkers() {
    if (_markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      minLat = math.min(minLat, marker.position.latitude);
      maxLat = math.max(maxLat, marker.position.latitude);
      minLng = math.min(minLng, marker.position.longitude);
      maxLng = math.max(maxLng, marker.position.longitude);
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  void _createTerritory() {
    // Implement territory creation dialog
  }

  void _exportTerritories() {
    // Implement territory export functionality
  }
}

// Analytics View Implementation with fl_chart
class MarketExplorerAnalyticsView extends StatefulWidget {
  final List<ZAECDCenters> prospects;
  final MarketAnalytics? analytics;
  final VoidCallback onRefresh;

  const MarketExplorerAnalyticsView({
    super.key,
    required this.prospects,
    this.analytics,
    required this.onRefresh,
  });

  @override
  State<MarketExplorerAnalyticsView> createState() =>
      _MarketExplorerAnalyticsViewState();
}

class _MarketExplorerAnalyticsViewState
    extends State<MarketExplorerAnalyticsView> {
  String _selectedTimeframe = '1Y';

  @override
  Widget build(BuildContext context) {
    if (widget.analytics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading analytics...'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Header
          Row(
            children: [
              const Text(
                'Market Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildTimeframeSelector(),
            ],
          ),
          const SizedBox(height: 24),
          _buildKeyMetricsRow(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildMarketPenetrationChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRegistrationStatusChart(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProvincialAnalysis(),
          const SizedBox(height: 24),
          _buildOpportunityMapping(),
          const SizedBox(height: 24),
          _buildGrowthProjections(),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '3M', label: Text('3M')),
        ButtonSegment(value: '6M', label: Text('6M')),
        ButtonSegment(value: '1Y', label: Text('1Y')),
        ButtonSegment(value: 'ALL', label: Text('All Time')),
      ],
      selected: {_selectedTimeframe},
      onSelectionChanged: (Set<String> selection) {
        setState(() {
          _selectedTimeframe = selection.first;
        });
      },
    );
  }

  Widget _buildKeyMetricsRow() {
    final analytics = widget.analytics!;
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
            'R${analytics.overall.totalPotentialMRR.toStringAsFixed(0)}',
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

  Widget _buildMarketPenetrationChart() {
    final analytics = widget.analytics!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Penetration by Province',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: analytics.byProvince
                      .map((e) => e.count.toDouble())
                      .reduce(math.max),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final province = analytics.byProvince[groupIndex];
                        return BarTooltipItem(
                          '${province.province}\n${province.count} centers',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < analytics.byProvince.length) {
                            return Text(
                              analytics.byProvince[value.toInt()].province,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: analytics.byProvince
                      .asMap()
                      .entries
                      .map((entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.count.toDouble(),
                        color: Colors.blue,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationStatusChart() {
    final analytics = widget.analytics!;
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

  Widget _buildProvincialAnalysis() {
    final analytics = widget.analytics!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provincial Market Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildOpportunityMapping() {
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
                    '${widget.prospects.where((p) => p.numberOfChildren >= 100).length} centers',
                    '100+ children',
                    'High potential MRR',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOpportunityCard(
                    'Medium-Value Targets',
                    '${widget.prospects.where((p) => p.numberOfChildren >= 50 && p.numberOfChildren < 100).length} centers',
                    '50-100 children',
                    'Medium potential MRR',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOpportunityCard(
                    'Small-Value Targets',
                    '${widget.prospects.where((p) => p.numberOfChildren < 50).length} centers',
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

  Widget _buildGrowthProjections() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Growth Projections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
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
                _buildLegendItem(Colors.blue, 'Conservative'),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.green, 'Aggressive'),
              ],
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
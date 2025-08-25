// lib/features/admin_platform/customer_management/market_explorer/tabs/map_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

import '../../controllers/market_explorer_controller.dart';
import '../../models/zaecdcenters_model.dart';
import 'panels/map_contols_panel.dart';
import 'panels/map_legend_panel.dart';
import 'panels/map_prospect_details_panel.dart';
import 'panels/map_territory_panel.dart';


class MapTab extends GetView<MarketExplorerController> {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _MapTabView(prospects: controller.centers);
  }
}

class _MapTabView extends StatefulWidget {
  final List<ZAECDCenters> prospects;

  const _MapTabView({
    required this.prospects,
  });

  @override
  State<_MapTabView> createState() => _MapTabViewState();
}

class _MapTabViewState extends State<_MapTabView> {
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
          child: MapControlsPanel(
            selectedMapType: _selectedMapType,
            showHeatMap: _showHeatMap,
            showClusters: _showClusters,
            showTerritories: _showTerritories,
            showCompetitors: _showCompetitors,
            onMapTypeChanged: (type) => setState(() => _selectedMapType = type),
            onHeatMapToggled: (value) => setState(() => _showHeatMap = value),
            onClustersToggled: (value) => setState(() => _showClusters = value),
            onTerritoriesToggled: (value) => setState(() => _showTerritories = value),
            onCompetitorsToggled: (value) => setState(() => _showCompetitors = value),
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onFitAll: _fitAllMarkers,
          ),
        ),

        // Legend Overlay
        Positioned(
          top: 16,
          right: 16,
          child: MapLegendPanel(
            showCompetitors: _showCompetitors,
            showTerritories: _showTerritories,
          ),
        ),

        // Territory Panel (when territories are shown)
        if (_showTerritories)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: TerritoryPanel(
              onClose: () => setState(() => _showTerritories = false),
            ),
          ),

        // Prospect Details Panel (when prospect is selected)
        if (_selectedProspect != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: ProspectDetailsPanel(
              prospect: _selectedProspect!,
              onClose: () => setState(() => _selectedProspect = null),
              onViewDetails: (prospect) {
                final controller = Get.find<MarketExplorerController>();
                controller.selectedProspectForDetail.value = prospect;
                controller.toggleView('list');
              },
            ),
          ),
      ],
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
            snippet: '${prospect.numberOfChildren} children • Score: ${prospect.leadScore}',
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
}
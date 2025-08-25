// lib/features/admin_platform/customer_management/market_explorer/tabs/analytics_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/market_explorer_controller.dart';
import '../../models/zaecdcenters_model.dart';
import 'panels/growth_projections_panel.dart';
import 'panels/key_metrics_panel.dart';
import 'panels/market_penetration_panel.dart';
import 'panels/opportunity_mapping_panel.dart';
import 'panels/provincial_analysis_panel.dart';
import 'panels/registration_status_panel.dart';


class AnalyticsTab extends GetView<MarketExplorerController> {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnalyticsTabView(
      prospects: controller.centers,
      analytics: controller.analytics.value,
      onRefresh: controller.fetchAnalytics,
    );
  }
}

class _AnalyticsTabView extends StatefulWidget {
  final List<ZAECDCenters> prospects;
  final MarketAnalytics? analytics;
  final VoidCallback onRefresh;

  const _AnalyticsTabView({
    required this.prospects,
    this.analytics,
    required this.onRefresh,
  });

  @override
  State<_AnalyticsTabView> createState() => _AnalyticsTabViewState();
}

class _AnalyticsTabViewState extends State<_AnalyticsTabView> {
  String _selectedTimeframe = '1Y';

  @override
  Widget build(BuildContext context) {
    if (widget.analytics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF875DEC),
            ),
            const SizedBox(height: 16),
            const Text('Loading analytics...'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF875DEC),
                foregroundColor: Colors.white,
              ),
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

          // Key Metrics
          KeyMetricsPanel(
            analytics: widget.analytics!,
            selectedTimeframe: _selectedTimeframe,
          ),

          const SizedBox(height: 24),

          // Charts Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: MarketPenetrationPanel(
                  analytics: widget.analytics!,
                  selectedTimeframe: _selectedTimeframe,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RegistrationStatusPanel(
                  analytics: widget.analytics!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Provincial Analysis
          ProvincialAnalysisPanel(
            analytics: widget.analytics!,
            selectedTimeframe: _selectedTimeframe,
          ),

          const SizedBox(height: 24),

          // Opportunity Mapping
          OpportunityMappingPanel(
            prospects: widget.prospects,
            selectedTimeframe: _selectedTimeframe,
          ),

          const SizedBox(height: 24),

          // Growth Projections
          GrowthProjectionsPanel(
            analytics: widget.analytics!,
            selectedTimeframe: _selectedTimeframe,
          ),
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
        widget.onRefresh();
      },
    );
  }
}
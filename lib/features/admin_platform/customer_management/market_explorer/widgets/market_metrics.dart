// lib/features/admin_platform/customer_management/market_explorer/widgets/metrics_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_explorer_controller.dart';

class MetricsSection extends GetView<MarketExplorerController> {
  const MetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Obx(() {
        // Check if market stats are loaded
        final hasMarketStats = controller.marketStats.value != null;
        final hasSelection = controller.selectedCenters.isNotEmpty;

        // Get values from controller (with fallbacks)
        final totalMarketSchools = controller.totalMarketSchools;
        final totalMarketChildren = controller.totalMarketChildren;
        final totalMarketMRR = controller.totalMarketMRR;

        final onboardedSchools = controller.onboardedSchools;
        final onboardedChildren = controller.onboardedChildren;
        final currentMRR = controller.currentMRR;

        final marketSharePercentage = controller.marketSharePercentage;

        // Show loading state if data is loading
        if (controller.isLoading.value && !hasMarketStats) {
          return _buildLoadingState();
        }

        // Show error state if there's an error
        if (controller.errorMessage.value.isNotEmpty && !hasMarketStats) {
          return _buildErrorState();
        }

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Prospects',
                hasSelection
                    ? '${_formatNumber(controller.selectedCenters.length)} selected'
                    : totalMarketSchools > 0
                    ? '${_formatNumber(onboardedSchools)} of ${_formatNumber(totalMarketSchools)}'
                    : '${_formatNumber(controller.totalCenters.value)} in filter',
                Icons.business_outlined,
                subtitle: hasSelection
                    ? 'Schools selected'
                    : totalMarketSchools > 0
                    ? 'Schools onboarded'
                    : 'Schools in current filter',
                isLoading: controller.isLoading.value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Children',
                hasSelection
                    ? _formatNumber(controller.totalSelectedChildren)
                    : totalMarketChildren > 0
                    ? '${_formatNumber(onboardedChildren)} of ${_formatNumber(totalMarketChildren)}'
                    : _formatNumber(controller.totalChildren.value),
                Icons.child_care_outlined,
                subtitle: hasSelection
                    ? 'Children in selection'
                    : totalMarketChildren > 0
                    ? 'Children reached'
                    : 'Children in filter',
                isLoading: controller.isLoading.value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Potential MRR',
                hasSelection
                    ? 'R${_formatCurrency(controller.totalSelectedMRR.toDouble())}'
                    : totalMarketMRR > 0
                    ? 'R${_formatCurrency(currentMRR)} of R${_formatCurrency(totalMarketMRR)}'
                    : 'R${_formatCurrency(controller.totalPotentialMRR.value)}',
                Icons.payments_outlined,
                subtitle: hasSelection
                    ? 'Selected value'
                    : totalMarketMRR > 0
                    ? 'Current vs potential'
                    : 'Total potential in filter',
                isLoading: controller.isLoading.value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                hasSelection ? 'Avg. Score' : 'Market Share',
                hasSelection
                    ? _calculateAverageScore().toStringAsFixed(1)
                    : '${marketSharePercentage.toStringAsFixed(2)}%',
                hasSelection
                    ? Icons.analytics_outlined
                    : Icons.pie_chart_outline_outlined,
                subtitle: hasSelection
                    ? 'Lead score average'
                    : 'Market penetration',
                isPercentage: !hasSelection,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        );
      }),
    );
  }

  // Build loading state
  Widget _buildLoadingState() {
    return Row(
      children: List.generate(4, (index) =>
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  // Build error state
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          TextButton(
            onPressed: () => controller.refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper function to format numbers with thousand separators
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  // Helper function to format currency with thousand separators
  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
    return '$wholePart.${parts[1]}';
  }

  // Helper method to calculate average score of selected prospects
  double _calculateAverageScore() {
    if (controller.selectedCenters.isEmpty) return 0.0;
    final totalScore = controller.selectedCenters.fold(
      0,
          (sum, center) => sum + center.leadScore,
    );
    return totalScore / controller.selectedCenters.length;
  }

  Widget _buildMetricCard(
      String label,
      String value,
      IconData icon, {
        String? subtitle,
        bool isPercentage = false,
        bool isLoading = false,
      }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF875DEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF875DEC),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? _buildShimmer()
                    : Text(
                  value,
                  style: TextStyle(
                    fontSize: isPercentage ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: isPercentage ? const Color(0xFF875DEC) : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && !isLoading) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: 80,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
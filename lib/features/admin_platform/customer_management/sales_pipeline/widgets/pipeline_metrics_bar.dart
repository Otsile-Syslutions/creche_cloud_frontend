// lib/features/admin_platform/customer_management/sales_pipeline/widgets/pipeline_metrics_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_pipeline_controller.dart';

class PipelineMetricsBar extends StatelessWidget {
  const PipelineMetricsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesPipelineController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Obx(() {
        controller.loadSalesVelocity(); // Load velocity metrics

        return Row(
          children: [
            _buildMetricCard(
              icon: Icons.attach_money,
              label: 'Total Pipeline Value',
              value: 'R${_formatValue(controller.totalPipelineValue)}',
              color: Colors.blue,
              trend: null,
            ),
            const SizedBox(width: 24),

            _buildMetricCard(
              icon: Icons.psychology,
              label: 'Weighted Value',
              value: 'R${_formatValue(controller.weightedPipelineValue)}',
              color: Colors.purple,
              trend: null,
            ),
            const SizedBox(width: 24),

            _buildMetricCard(
              icon: Icons.layers,
              label: 'Total Deals',
              value: '${controller.totalDealsCount}',
              color: Colors.green,
              subValue: '${controller.hotDealsCount} hot',
            ),
            const SizedBox(width: 24),

            _buildMetricCard(
              icon: Icons.warning_amber,
              label: 'Needs Attention',
              value: '${controller.rottingDealsCount}',
              color: Colors.orange,
              subValue: 'rotting deals',
            ),

            const Spacer(),

            // Win rate
            if (controller.statistics.value != null)
              _buildWinRateCard(controller.statistics.value!),
          ],
        );
      }),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subValue,
    double? trend,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (trend != null) ...[
                    const SizedBox(width: 6),
                    Icon(
                      trend >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: trend >= 0 ? Colors.green : Colors.red,
                    ),
                    Text(
                      '${trend.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: trend >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  subValue,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinRateCard(PipelineStatistics stats) {
    final conversion = stats.pipeline['conversion'];
    if (conversion == null) return const SizedBox.shrink();

    final totalDeals = conversion['totalDeals'] ?? 0;
    final wonDeals = conversion['wonDeals'] ?? 0;
    final winRate = totalDeals > 0 ? (wonDeals / totalDeals * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF875DEC).withOpacity(0.1),
            const Color(0xFF875DEC).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF875DEC).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                size: 20,
                color: Color(0xFF875DEC),
              ),
              const SizedBox(width: 8),
              Text(
                'Win Rate',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${winRate.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF875DEC),
            ),
          ),
          Text(
            '$wonDeals of $totalDeals',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
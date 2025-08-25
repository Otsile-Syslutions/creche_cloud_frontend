// lib/features/admin_platform/customer_management/sales_pipeline/widgets/pipeline_column.dart

import 'package:flutter/material.dart';
import '../controllers/sales_pipeline_controller.dart';
import '../models/deal_model.dart';
import 'deal_card.dart';

class PipelineColumn extends StatelessWidget {
  final PipelineStageConfig config;
  final PipelineStage? stage;
  final Function(Deal) onDragStart;
  final VoidCallback onDragEnd;
  final VoidCallback onDragEnter;
  final VoidCallback onDragLeave;
  final VoidCallback onDrop;
  final Function(Deal) onDealTap;
  final bool isDragOver;

  const PipelineColumn({
    super.key,
    required this.config,
    this.stage,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragEnter,
    required this.onDragLeave,
    required this.onDrop,
    required this.onDealTap,
    this.isDragOver = false,
  });

  @override
  Widget build(BuildContext context) {
    final deals = stage?.deals ?? [];
    final totalValue = stage?.totalValue ?? 0;
    final count = stage?.count ?? 0;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDragOver
            ? config.color.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDragOver
              ? config.color.withOpacity(0.3)
              : Colors.grey.shade200,
          width: isDragOver ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      config.icon,
                      size: 18,
                      color: config.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        config.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: config.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R${_formatValue(totalValue)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '${config.probability}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Deals list
          Expanded(
            child: DragTarget<Deal>(
              onWillAccept: (deal) {
                if (deal?.stage != config.name) {
                  onDragEnter();
                  return true;
                }
                return false;
              },
              onLeave: (_) => onDragLeave(),
              onAccept: (deal) => onDrop(),
              builder: (context, candidateData, rejectedData) {
                if (deals.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No deals',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          if (isDragOver) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: config.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: config.color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Drop here',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: config.color,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                // Fix for scrollbar issue - use ScrollConfiguration to control scrollbar
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false, // Disable default scrollbars
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: deals.length,
                    // Add explicit scroll physics
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final deal = deals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Draggable<Deal>(
                          data: deal,
                          onDragStarted: () => onDragStart(deal),
                          onDragEnd: (_) => onDragEnd(),
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 260,
                              child: DealCard(
                                deal: deal,
                                isDragging: true,
                                onTap: () {},
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: DealCard(
                              deal: deal,
                              onTap: () {},
                            ),
                          ),
                          child: DealCard(
                            deal: deal,
                            onTap: () => onDealTap(deal),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
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
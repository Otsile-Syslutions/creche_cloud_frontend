// lib/features/admin_platform/customer_management/sales_pipeline/widgets/pipeline_column.dart

import 'package:flutter/material.dart';
import '../controllers/sales_pipeline_controller.dart';
import '../models/deal_model.dart';
import 'deal_card.dart';

class PipelineColumn extends StatefulWidget {
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
  State<PipelineColumn> createState() => _PipelineColumnState();
}

class _PipelineColumnState extends State<PipelineColumn> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deals = widget.stage?.deals ?? [];
    final totalValue = widget.stage?.totalValue ?? 0;
    final count = widget.stage?.count ?? 0;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: widget.isDragOver
            ? widget.config.color.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDragOver
              ? widget.config.color.withOpacity(0.3)
              : Colors.grey.shade200,
          width: widget.isDragOver ? 2 : 1,
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
          _buildHeader(count, totalValue),
          Expanded(
            child: _buildDealsList(deals),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count, double totalValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.config.color.withOpacity(0.1),
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
                widget.config.icon,
                size: 18,
                color: widget.config.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.config.name,
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
                  color: widget.config.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.config.color,
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
                '${widget.config.probability}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDealsList(List<Deal> deals) {
    return DragTarget<Deal>(
      onWillAccept: (deal) {
        if (deal?.stage != widget.config.name) {
          widget.onDragEnter();
          return true;
        }
        return false;
      },
      onLeave: (_) => widget.onDragLeave(),
      onAccept: (deal) => widget.onDrop(),
      builder: (context, candidateData, rejectedData) {
        if (deals.isEmpty) {
          return _buildEmptyState();
        }

        // Fixed: Only use Scrollbar when there's actual scrollable content
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: deals.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final deal = deals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Draggable<Deal>(
                data: deal,
                onDragStarted: () => widget.onDragStart(deal),
                onDragEnd: (_) => widget.onDragEnd(),
                feedback: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
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
                  onTap: () => widget.onDealTap(deal),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
            if (widget.isDragOver) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.config.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.config.color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Drop here',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.config.color,
                  ),
                ),
              ),
            ],
          ],
        ),
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
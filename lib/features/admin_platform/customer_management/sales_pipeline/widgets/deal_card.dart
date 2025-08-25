// lib/features/admin_platform/customer_management/sales_pipeline/widgets/deal_card.dart

import 'package:flutter/material.dart';
import '../models/deal_model.dart';

class DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;
  final bool isDragging;

  const DealCard({
    super.key,
    required this.deal,
    required this.onTap,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDragging ? 0.15 : 0.05),
              blurRadius: isDragging ? 8 : 4,
              offset: Offset(0, isDragging ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal header with status indicators
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and indicators row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deal.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (deal.isHot)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Colors.red,
                          ),
                        ),
                      if (deal.isRotting)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.warning,
                            size: 14,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Company name
                  Text(
                    deal.ecdCenter?.ecdName ?? 'Unknown Company',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Value and probability
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R${_formatValue(deal.value.annual)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getProbabilityColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${deal.probability.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getProbabilityColor(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Additional info
                  Row(
                    children: [
                      // Owner avatar and name
                      if (deal.owner != null) ...[
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey.shade300,
                          child: Text(
                            deal.owner!.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            deal.owner!.fullName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      // Days in stage indicator
                      if (deal.daysInStage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: _getDaysColor(deal.daysInStage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${deal.daysInStage}d',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getDaysColor(deal.daysInStage),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Activities indicator
                  if (deal.activities.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getNextActivityIcon(deal),
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getNextActivityText(deal),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Tags
                  if (deal.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: deal.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Expected close date footer
            if (deal.expectedCloseDate != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(deal.expectedCloseDate!),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (deal.isHot) return Colors.red.shade300;
    if (deal.isRotting) return Colors.orange.shade300;
    if (deal.probability >= 70) return Colors.green.shade300;
    return Colors.grey.shade200;
  }

  Color _getProbabilityColor() {
    if (deal.probability >= 70) return Colors.green;
    if (deal.probability >= 40) return Colors.blue;
    if (deal.probability >= 20) return Colors.orange;
    return Colors.grey;
  }

  Color _getDaysColor(int days) {
    if (days > 30) return Colors.red;
    if (days > 14) return Colors.orange;
    if (days > 7) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0 && difference <= 7) return 'In $difference days';
    if (difference < 0 && difference >= -7) return '${-difference} days ago';

    return '${date.day}/${date.month}';
  }

  IconData _getNextActivityIcon(Deal deal) {
    final nextActivity = deal.activities
        .where((a) => !a.completed && a.dueDate != null)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    if (nextActivity.isEmpty) return Icons.event_available;

    switch (nextActivity.first.type) {
      case 'call':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'meeting':
        return Icons.people;
      case 'demo':
        return Icons.play_circle_outline;
      default:
        return Icons.task_alt;
    }
  }

  String _getNextActivityText(Deal deal) {
    final nextActivity = deal.activities
        .where((a) => !a.completed && a.dueDate != null)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    if (nextActivity.isEmpty) return 'No activities';

    final activity = nextActivity.first;
    final daysUntil = activity.dueDate!.difference(DateTime.now()).inDays;

    if (daysUntil < 0) return '${activity.type} overdue';
    if (daysUntil == 0) return '${activity.type} today';
    if (daysUntil == 1) return '${activity.type} tomorrow';

    return '${activity.type} in $daysUntil days';
  }
}
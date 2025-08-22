// lib/features/admin_platform/customer_management/sales_pipeline/models/pipeline_status_model.dart

import 'package:flutter/material.dart';

class PipelineStatus {
  final String status;
  final DateTime timestamp;
  final String? notes;
  final String? updatedBy;

  PipelineStatus({
    required this.status,
    required this.timestamp,
    this.notes,
    this.updatedBy,
  });

  factory PipelineStatus.fromJson(Map<String, dynamic> json) {
    return PipelineStatus(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      notes: json['notes'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'updatedBy': updatedBy,
    };
  }

  PipelineStatus copyWith({
    String? status,
    DateTime? timestamp,
    String? notes,
    String? updatedBy,
  }) {
    return PipelineStatus(
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PipelineStatus &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.updatedBy == updatedBy;
  }

  @override
  int get hashCode {
    return status.hashCode ^
    timestamp.hashCode ^
    notes.hashCode ^
    updatedBy.hashCode;
  }
}

// Enum for pipeline status values
enum PipelineStatusType {
  initialContact('Initial Contact'),
  demoScheduled('Demo Scheduled'),
  demoCompleted('Demo Completed'),
  proposalSent('Proposal Sent'),
  nurturing('Nurturing'),
  onboarding('Onboarding'),
  closedWon('Closed Won'),
  closedLost('Closed Lost'),
  churned('Churned');

  const PipelineStatusType(this.displayName);
  final String displayName;

  static PipelineStatusType? fromString(String value) {
    return PipelineStatusType.values
        .where((status) => status.displayName == value)
        .firstOrNull;
  }

  Color get color {
    switch (this) {
      case PipelineStatusType.initialContact:
        return Colors.blue.shade300;
      case PipelineStatusType.demoScheduled:
        return Colors.orange.shade300;
      case PipelineStatusType.demoCompleted:
        return Colors.purple.shade300;
      case PipelineStatusType.proposalSent:
        return Colors.indigo.shade300;
      case PipelineStatusType.nurturing:
        return Colors.amber.shade300;
      case PipelineStatusType.onboarding:
        return Colors.green.shade300;
      case PipelineStatusType.closedWon:
        return Colors.green.shade600;
      case PipelineStatusType.closedLost:
        return Colors.red.shade400;
      case PipelineStatusType.churned:
        return Colors.grey.shade400;
    }
  }

  IconData get icon {
    switch (this) {
      case PipelineStatusType.initialContact:
        return Icons.contact_phone;
      case PipelineStatusType.demoScheduled:
        return Icons.schedule;
      case PipelineStatusType.demoCompleted:
        return Icons.check_circle_outline;
      case PipelineStatusType.proposalSent:
        return Icons.description;
      case PipelineStatusType.nurturing:
        return Icons.favorite_outline;
      case PipelineStatusType.onboarding:
        return Icons.trending_up;
      case PipelineStatusType.closedWon:
        return Icons.celebration;
      case PipelineStatusType.closedLost:
        return Icons.cancel_outlined;
      case PipelineStatusType.churned:
        return Icons.trending_down;
    }
  }

  bool get isPositive {
    switch (this) {
      case PipelineStatusType.initialContact:
      case PipelineStatusType.demoScheduled:
      case PipelineStatusType.demoCompleted:
      case PipelineStatusType.proposalSent:
      case PipelineStatusType.nurturing:
      case PipelineStatusType.onboarding:
      case PipelineStatusType.closedWon:
        return true;
      case PipelineStatusType.closedLost:
      case PipelineStatusType.churned:
        return false;
    }
  }

  bool get isFinal {
    switch (this) {
      case PipelineStatusType.closedWon:
      case PipelineStatusType.closedLost:
      case PipelineStatusType.churned:
        return true;
      default:
        return false;
    }
  }

  int get sortOrder {
    switch (this) {
      case PipelineStatusType.initialContact:
        return 1;
      case PipelineStatusType.demoScheduled:
        return 2;
      case PipelineStatusType.demoCompleted:
        return 3;
      case PipelineStatusType.proposalSent:
        return 4;
      case PipelineStatusType.nurturing:
        return 5;
      case PipelineStatusType.onboarding:
        return 6;
      case PipelineStatusType.closedWon:
        return 7;
      case PipelineStatusType.closedLost:
        return 8;
      case PipelineStatusType.churned:
        return 9;
    }
  }
}

// Helper class for pipeline status management
class PipelineStatusHelper {
  static List<String> get allStatusNames {
    return PipelineStatusType.values.map((e) => e.displayName).toList();
  }

  static List<PipelineStatusType> get activeStatuses {
    return PipelineStatusType.values.where((s) => !s.isFinal).toList();
  }

  static List<PipelineStatusType> get finalStatuses {
    return PipelineStatusType.values.where((s) => s.isFinal).toList();
  }

  static PipelineStatusType? getStatusFromString(String statusName) {
    return PipelineStatusType.fromString(statusName);
  }

  static Widget buildStatusChip(String statusName, {bool small = false}) {
    final statusType = PipelineStatusType.fromString(statusName);
    if (statusType == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8,
          vertical: small ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(small ? 8 : 12),
        ),
        child: Text(
          statusName,
          style: TextStyle(
            fontSize: small ? 10 : 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontFamily: 'Roboto',
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: statusType.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(small ? 8 : 12),
        border: Border.all(
          color: statusType.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusType.icon,
            size: small ? 10 : 12,
            color: statusType.color,
          ),
          SizedBox(width: small ? 2 : 4),
          Text(
            statusName,
            style: TextStyle(
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: statusType.color,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildStatusIcon(String statusName, {double size = 16}) {
    final statusType = PipelineStatusType.fromString(statusName);
    if (statusType == null) {
      return Icon(
        Icons.help_outline,
        size: size,
        color: Colors.grey,
      );
    }

    return Icon(
      statusType.icon,
      size: size,
      color: statusType.color,
    );
  }

  static Color getStatusColor(String statusName) {
    final statusType = PipelineStatusType.fromString(statusName);
    return statusType?.color ?? Colors.grey;
  }

  static bool isPositiveStatus(String statusName) {
    final statusType = PipelineStatusType.fromString(statusName);
    return statusType?.isPositive ?? false;
  }

  static bool isFinalStatus(String statusName) {
    final statusType = PipelineStatusType.fromString(statusName);
    return statusType?.isFinal ?? false;
  }

  static List<PipelineStatus> sortPipelineHistory(List<PipelineStatus> statuses) {
    return statuses..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  static PipelineStatus? getLatestStatus(List<PipelineStatus> statuses) {
    if (statuses.isEmpty) return null;
    return statuses.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  static List<String> getNextPossibleStatuses(String currentStatus) {
    final currentType = PipelineStatusType.fromString(currentStatus);
    if (currentType == null) return allStatusNames;

    switch (currentType) {
      case PipelineStatusType.initialContact:
        return [
          PipelineStatusType.demoScheduled.displayName,
          PipelineStatusType.nurturing.displayName,
          PipelineStatusType.closedLost.displayName,
        ];
      case PipelineStatusType.demoScheduled:
        return [
          PipelineStatusType.demoCompleted.displayName,
          PipelineStatusType.nurturing.displayName,
          PipelineStatusType.closedLost.displayName,
        ];
      case PipelineStatusType.demoCompleted:
        return [
          PipelineStatusType.proposalSent.displayName,
          PipelineStatusType.nurturing.displayName,
          PipelineStatusType.closedWon.displayName,
          PipelineStatusType.closedLost.displayName,
        ];
      case PipelineStatusType.proposalSent:
        return [
          PipelineStatusType.onboarding.displayName,
          PipelineStatusType.nurturing.displayName,
          PipelineStatusType.closedWon.displayName,
          PipelineStatusType.closedLost.displayName,
        ];
      case PipelineStatusType.nurturing:
        return [
          PipelineStatusType.demoScheduled.displayName,
          PipelineStatusType.proposalSent.displayName,
          PipelineStatusType.closedWon.displayName,
          PipelineStatusType.closedLost.displayName,
        ];
      case PipelineStatusType.onboarding:
        return [
          PipelineStatusType.closedWon.displayName,
          PipelineStatusType.closedLost.displayName,
        ];
      case PipelineStatusType.closedWon:
        return [
          PipelineStatusType.churned.displayName,
        ];
      case PipelineStatusType.closedLost:
      case PipelineStatusType.churned:
        return [
          PipelineStatusType.initialContact.displayName,
        ];
    }
  }
}
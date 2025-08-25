// lib/features/admin_platform/customer_management/sales_pipeline/models/deal_model.dart

import 'package:flutter/material.dart';
import '../../market_explorer/models/zaecdcenters_model.dart';

class Deal {
  final String id;
  final String ecdCenterId;
  final ZAECDCenters? ecdCenter;
  String title;
  String stage;
  DealValue value;
  double probability;
  DateTime? expectedCloseDate;
  DateTime? actualCloseDate;
  DealStatus? status;
  String ownerId;
  UserInfo? owner;
  List<DealParticipant> participants;
  List<DealContact> contacts;
  List<DealActivity> activities;
  List<DealNote> notes;
  List<String> tags;
  String source;
  String visibility;
  DealMetrics? metrics;
  DateTime createdAt;
  DateTime updatedAt;

  Deal({
    required this.id,
    required this.ecdCenterId,
    this.ecdCenter,
    required this.title,
    required this.stage,
    required this.value,
    this.probability = 10,
    this.expectedCloseDate,
    this.actualCloseDate,
    this.status,
    required this.ownerId,
    this.owner,
    this.participants = const [],
    this.contacts = const [],
    this.activities = const [],
    this.notes = const [],
    this.tags = const [],
    this.source = 'Import',
    this.visibility = 'team',
    this.metrics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['_id'] ?? json['id'] ?? '',
      ecdCenterId: json['ecdCenter'] is String
          ? json['ecdCenter']
          : json['ecdCenter']?['_id'] ?? '',
      ecdCenter: json['ecdCenter'] is Map
          ? ZAECDCenters.fromJson(json['ecdCenter'])
          : null,
      title: json['title'] ?? '',
      stage: json['stage'] ?? 'Initial Contact',
      value: DealValue.fromJson(json['value'] ?? {}),
      probability: (json['probability'] ?? 10).toDouble(),
      expectedCloseDate: json['expectedCloseDate'] != null
          ? DateTime.parse(json['expectedCloseDate'])
          : null,
      actualCloseDate: json['actualCloseDate'] != null
          ? DateTime.parse(json['actualCloseDate'])
          : null,
      status: json['status'] != null
          ? DealStatus.fromJson(json['status'])
          : null,
      ownerId: json['owner'] is String
          ? json['owner']
          : json['owner']?['_id'] ?? '',
      owner: json['owner'] is Map
          ? UserInfo.fromJson(json['owner'])
          : null,
      participants: (json['participants'] as List? ?? [])
          .map((p) => DealParticipant.fromJson(p))
          .toList(),
      contacts: (json['contacts'] as List? ?? [])
          .map((c) => DealContact.fromJson(c))
          .toList(),
      activities: (json['activities'] as List? ?? [])
          .map((a) => DealActivity.fromJson(a))
          .toList(),
      notes: (json['notes'] as List? ?? [])
          .map((n) => DealNote.fromJson(n))
          .toList(),
      tags: List<String>.from(json['tags'] ?? []),
      source: json['source'] ?? 'Import',
      visibility: json['visibility'] ?? 'team',
      metrics: json['metrics'] != null
          ? DealMetrics.fromJson(json['metrics'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecdCenter': ecdCenterId,
      'title': title,
      'stage': stage,
      'value': value.toJson(),
      'probability': probability,
      'expectedCloseDate': expectedCloseDate?.toIso8601String(),
      'actualCloseDate': actualCloseDate?.toIso8601String(),
      'status': status?.toJson(),
      'owner': ownerId,
      'participants': participants.map((p) => p.toJson()).toList(),
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'tags': tags,
      'source': source,
      'visibility': visibility,
      'metrics': metrics?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  void updateProbability() {
    final stageProbabilities = {
      'Initial Contact': 10.0,
      'Demo Scheduled': 20.0,
      'Demo Completed': 30.0,
      'Proposal Sent': 50.0,
      'Nurturing': 25.0,
      'Onboarding': 90.0,
      'Closed Won': 100.0,
      'Closed Lost': 0.0,
      'Churned': 0.0,
    };

    probability = stageProbabilities[stage] ?? 10.0;
    value.updateWeighted(probability);
  }

  bool get isHot => status?.isHot ?? false;
  bool get isRotting => status?.isRotting ?? false;
  bool get isClosed => stage == 'Closed Won' || stage == 'Closed Lost' || stage == 'Churned';
  bool get isWon => stage == 'Closed Won';

  int get daysInStage => status?.daysInStage ?? 0;
  int get daysInPipeline => status?.daysInPipeline ?? 0;

  Color get stageColor {
    final colors = {
      'Initial Contact': Colors.blue.shade300,
      'Demo Scheduled': Colors.orange.shade300,
      'Demo Completed': Colors.purple.shade300,
      'Proposal Sent': Colors.indigo.shade300,
      'Nurturing': Colors.amber.shade300,
      'Onboarding': Colors.green.shade300,
      'Closed Won': Colors.green.shade600,
      'Closed Lost': Colors.red.shade400,
      'Churned': Colors.grey.shade400,
    };
    return colors[stage] ?? Colors.grey;
  }
}

class DealValue {
  double monthly;
  double annual;
  double weighted;

  DealValue({
    required this.monthly,
    required this.annual,
    required this.weighted,
  });

  factory DealValue.fromJson(Map<String, dynamic> json) {
    return DealValue(
      monthly: (json['monthly'] ?? 0).toDouble(),
      annual: (json['annual'] ?? 0).toDouble(),
      weighted: (json['weighted'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthly': monthly,
      'annual': annual,
      'weighted': weighted,
    };
  }

  void updateWeighted(double probability) {
    weighted = annual * (probability / 100);
  }
}

class DealStatus {
  final bool isHot;
  final bool isRotting;
  final int daysInStage;
  final int daysInPipeline;

  DealStatus({
    required this.isHot,
    required this.isRotting,
    required this.daysInStage,
    required this.daysInPipeline,
  });

  factory DealStatus.fromJson(Map<String, dynamic> json) {
    return DealStatus(
      isHot: json['isHot'] ?? false,
      isRotting: json['isRotting'] ?? false,
      daysInStage: json['daysInStage'] ?? 0,
      daysInPipeline: json['daysInPipeline'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isHot': isHot,
      'isRotting': isRotting,
      'daysInStage': daysInStage,
      'daysInPipeline': daysInPipeline,
    };
  }
}

class DealParticipant {
  final String userId;
  final UserInfo? user;
  final String role;

  DealParticipant({
    required this.userId,
    this.user,
    required this.role,
  });

  factory DealParticipant.fromJson(Map<String, dynamic> json) {
    return DealParticipant(
      userId: json['user'] is String
          ? json['user']
          : json['user']?['_id'] ?? '',
      user: json['user'] is Map
          ? UserInfo.fromJson(json['user'])
          : null,
      role: json['role'] ?? 'follower',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'role': role,
    };
  }
}

class DealContact {
  final String name;
  final String? role;
  final String? email;
  final String? phone;
  final bool isPrimary;
  final DateTime? lastContacted;

  DealContact({
    required this.name,
    this.role,
    this.email,
    this.phone,
    this.isPrimary = false,
    this.lastContacted,
  });

  factory DealContact.fromJson(Map<String, dynamic> json) {
    return DealContact(
      name: json['name'] ?? '',
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      isPrimary: json['isPrimary'] ?? false,
      lastContacted: json['lastContacted'] != null
          ? DateTime.parse(json['lastContacted'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'isPrimary': isPrimary,
      'lastContacted': lastContacted?.toIso8601String(),
    };
  }
}

class DealActivity {
  final String id;
  final String type;
  final String subject;
  final String? description;
  final DateTime? dueDate;
  final int? duration;
  final bool completed;
  final DateTime? completedAt;
  final String? assignedToId;
  final UserInfo? assignedTo;
  final String? outcome;
  final String? nextStep;

  DealActivity({
    required this.id,
    required this.type,
    required this.subject,
    this.description,
    this.dueDate,
    this.duration,
    this.completed = false,
    this.completedAt,
    this.assignedToId,
    this.assignedTo,
    this.outcome,
    this.nextStep,
  });

  factory DealActivity.fromJson(Map<String, dynamic> json) {
    return DealActivity(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      duration: json['duration'],
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      assignedToId: json['assignedTo'] is String
          ? json['assignedTo']
          : json['assignedTo']?['_id'],
      assignedTo: json['assignedTo'] is Map
          ? UserInfo.fromJson(json['assignedTo'])
          : null,
      outcome: json['outcome'],
      nextStep: json['nextStep'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'subject': subject,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'duration': duration,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'assignedTo': assignedToId,
      'outcome': outcome,
      'nextStep': nextStep,
    };
  }
}

class DealNote {
  final String id;
  final String content;
  final String? authorId;
  final UserInfo? author;
  final DateTime createdAt;
  final bool isPinned;

  DealNote({
    required this.id,
    required this.content,
    this.authorId,
    this.author,
    required this.createdAt,
    this.isPinned = false,
  });

  factory DealNote.fromJson(Map<String, dynamic> json) {
    return DealNote(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author'] is String
          ? json['author']
          : json['author']?['_id'],
      author: json['author'] is Map
          ? UserInfo.fromJson(json['author'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isPinned: json['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isPinned': isPinned,
    };
  }
}

class DealMetrics {
  final int emailsSent;
  final int emailsReceived;
  final int callsMade;
  final int meetingsHeld;
  final int proposalsSent;
  final DateTime? lastActivityDate;
  final DateTime? nextActivityDate;

  DealMetrics({
    this.emailsSent = 0,
    this.emailsReceived = 0,
    this.callsMade = 0,
    this.meetingsHeld = 0,
    this.proposalsSent = 0,
    this.lastActivityDate,
    this.nextActivityDate,
  });

  factory DealMetrics.fromJson(Map<String, dynamic> json) {
    return DealMetrics(
      emailsSent: json['emailsSent'] ?? 0,
      emailsReceived: json['emailsReceived'] ?? 0,
      callsMade: json['callsMade'] ?? 0,
      meetingsHeld: json['meetingsHeld'] ?? 0,
      proposalsSent: json['proposalsSent'] ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : null,
      nextActivityDate: json['nextActivityDate'] != null
          ? DateTime.parse(json['nextActivityDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailsSent': emailsSent,
      'emailsReceived': emailsReceived,
      'callsMade': callsMade,
      'meetingsHeld': meetingsHeld,
      'proposalsSent': proposalsSent,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'nextActivityDate': nextActivityDate?.toIso8601String(),
    };
  }
}

class UserInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? avatar;

  UserInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  String get fullName => '$firstName $lastName';
}

// Activity creation helper
class ActivityData {
  final String type;
  final String subject;
  final String? description;
  final DateTime? dueDate;
  final int? duration;
  final String? assignedTo;

  ActivityData({
    required this.type,
    required this.subject,
    this.description,
    this.dueDate,
    this.duration,
    this.assignedTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'subject': subject,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'duration': duration,
      'assignedTo': assignedTo,
    };
  }
}

// Won details for closing deals
class WonDetails {
  final double finalPrice;
  final double? discountGiven;
  final int? contractLength;
  final List<String> keyFactors;
  final String? subscriptionPlan;

  WonDetails({
    required this.finalPrice,
    this.discountGiven,
    this.contractLength,
    this.keyFactors = const [],
    this.subscriptionPlan,
  });

  Map<String, dynamic> toJson() {
    return {
      'finalPrice': finalPrice,
      'discountGiven': discountGiven,
      'contractLength': contractLength,
      'keyFactors': keyFactors,
      'subscriptionPlan': subscriptionPlan,
    };
  }
}

// Lost reason for closing deals
class LostReason {
  final String primary;
  final String? details;
  final String? competitorWon;

  LostReason({
    required this.primary,
    this.details,
    this.competitorWon,
  });

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'details': details,
      'competitorWon': competitorWon,
    };
  }
}
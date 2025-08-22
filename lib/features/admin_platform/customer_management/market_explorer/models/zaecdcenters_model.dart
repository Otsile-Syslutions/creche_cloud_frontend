// lib/features/admin_platform/schools_management/market_explorer/models/zaecdcenters_model.dart

import '../../sales_pipeline/models/pipeline_status_model.dart';


class ZAECDCenters {
  final String id;
  final String ecdName;
  final String operationalStatus;
  final String registrationStatus;
  final int? registrationDate;

  // Location
  final String province;
  final int? provinceCode;
  final String? districtMunicipality;
  final String? localMunicipality;
  final String? wardId;
  final String? gisLongitude;
  final String? gisLatitude;
  final LocationCoordinates? location;

  // Address
  final String? township;
  final String? suburb;
  final String? townCity;
  final String? streetAddress;
  final String? postalAddress;

  // Contact
  final String? contactPerson;
  final String? telephone;
  final String? email;

  // Capacity
  final int numberOfChildren;
  final int numberOfStaff;

  // Ownership
  final String? landOwnership;
  final String? buildingOwnership;

  // CRM/Sales Fields
  final int leadScore;
  final String leadStatus;
  final String pipelineStage;
  final double potentialMRR;
  final DateTime? lastContactDate;
  final DateTime? nextFollowUpDate;
  final String? assignedSalesRep;
  final String? salesTerritory;

  // NEW FIELDS - Competitor and Pipeline Tracking
  final bool isUsingCompetitor;
  final String? competitorAppUsed;
  final bool wonOverFromCompetitor;
  final bool isMovedToPipeline;
  final List<PipelineStatus> pipelineStatus;

  // Enrichment Data
  final EnrichmentData? enrichmentData;

  // Conversion Data
  final ConversionData? conversionData;

  // Data Quality
  final DataQuality? dataQuality;

  // Tags
  final List<String> tags;

  // Notes & Tasks
  final List<Note>? notes;
  final List<Task>? tasks;

  // Metadata
  final String? dataSource;
  final DateTime? importedDate;
  final int? originalDataYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  ZAECDCenters({
    required this.id,
    required this.ecdName,
    this.operationalStatus = 'Operational',
    this.registrationStatus = 'Unknown',
    this.registrationDate,
    required this.province,
    this.provinceCode,
    this.districtMunicipality,
    this.localMunicipality,
    this.wardId,
    this.gisLongitude,
    this.gisLatitude,
    this.location,
    this.township,
    this.suburb,
    this.townCity,
    this.streetAddress,
    this.postalAddress,
    this.contactPerson,
    this.telephone,
    this.email,
    this.numberOfChildren = 0,
    this.numberOfStaff = 0,
    this.landOwnership,
    this.buildingOwnership,
    this.leadScore = 0,
    this.leadStatus = 'Prospect',
    this.pipelineStage = 'Market',
    this.potentialMRR = 0,
    this.lastContactDate,
    this.nextFollowUpDate,
    this.assignedSalesRep,
    this.salesTerritory,
    // NEW FIELDS
    this.isUsingCompetitor = false,
    this.competitorAppUsed,
    this.wonOverFromCompetitor = false,
    this.isMovedToPipeline = false,
    this.pipelineStatus = const [],
    this.enrichmentData,
    this.conversionData,
    this.dataQuality,
    this.tags = const [],
    this.notes,
    this.tasks,
    this.dataSource,
    this.importedDate,
    this.originalDataYear,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  String get fullAddress {
    final parts = [
      streetAddress,
      suburb ?? township,
      townCity,
      province,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(', ');
  }

  bool get hasValidContact =>
      (dataQuality?.hasValidPhone ?? false) ||
          (dataQuality?.hasValidEmail ?? false);

  String get sizeCategory {
    if (numberOfChildren >= 100) return 'Large';
    if (numberOfChildren >= 50) return 'Medium';
    if (numberOfChildren >= 20) return 'Small';
    return 'Very Small';
  }

  String get leadScoreCategory {
    if (leadScore >= 80) return 'Hot';
    if (leadScore >= 60) return 'Warm';
    if (leadScore >= 40) return 'Cool';
    return 'Cold';
  }

  String get provinceName {
    const provinceNames = {
      'WC': 'Western Cape',
      'GT': 'Gauteng',
      'KZN': 'KwaZulu-Natal',
      'EC': 'Eastern Cape',
      'LIM': 'Limpopo',
      'MP': 'Mpumalanga',
      'NW': 'North West',
      'FS': 'Free State',
      'NC': 'Northern Cape',
    };
    return provinceNames[province] ?? province;
  }

  // NEW COMPUTED PROPERTIES
  String get competitorStatus {
    if (wonOverFromCompetitor) {
      return 'Won from Competitor';
    } else if (isUsingCompetitor && competitorAppUsed != null && competitorAppUsed!.isNotEmpty) {
      return 'Using $competitorAppUsed';
    } else if (isUsingCompetitor) {
      return 'Using Competitor';
    }
    return 'No Competitor';
  }

  PipelineStatus? get currentPipelineStatus {
    if (pipelineStatus.isEmpty) return null;
    return PipelineStatusHelper.getLatestStatus(pipelineStatus);
  }

  String get pipelineProgressSummary {
    if (!isMovedToPipeline) return 'Not in Pipeline';
    final current = currentPipelineStatus;
    if (current == null) return 'Pipeline Started';
    return current.status;
  }

  bool get hasCompetitorAdvantage =>
      isUsingCompetitor || wonOverFromCompetitor;

  bool get isInActivePipeline =>
      isMovedToPipeline && currentPipelineStatus != null &&
          !PipelineStatusHelper.isFinalStatus(currentPipelineStatus!.status);

  List<PipelineStatus> get sortedPipelineHistory =>
      PipelineStatusHelper.sortPipelineHistory(List.from(pipelineStatus));

  // Factory constructor for JSON parsing
  factory ZAECDCenters.fromJson(Map<String, dynamic> json) {
    return ZAECDCenters(
      id: json['_id'] ?? json['id'] ?? '',
      ecdName: json['ecdName'] ?? '',
      operationalStatus: json['operationalStatus'] ?? 'Operational',
      registrationStatus: json['registrationStatus'] ?? 'Unknown',
      registrationDate: json['registrationDate'],
      province: json['province'] ?? '',
      provinceCode: json['provinceCode'],
      districtMunicipality: json['districtMunicipality'],
      localMunicipality: json['localMunicipality'],
      wardId: json['wardId'],
      gisLongitude: json['gisLongitude'],
      gisLatitude: json['gisLatitude'],
      location: json['location'] != null
          ? LocationCoordinates.fromJson(json['location'])
          : null,
      township: json['township'],
      suburb: json['suburb'],
      townCity: json['townCity'],
      streetAddress: json['streetAddress'],
      postalAddress: json['postalAddress'],
      contactPerson: json['contactPerson'],
      telephone: json['telephone'],
      email: json['email'],
      numberOfChildren: json['numberOfChildren'] ?? 0,
      numberOfStaff: json['numberOfStaff'] ?? 0,
      landOwnership: json['landOwnership'],
      buildingOwnership: json['buildingOwnership'],
      leadScore: json['leadScore'] ?? 0,
      leadStatus: json['leadStatus'] ?? 'Prospect',
      pipelineStage: json['pipelineStage'] ?? 'Market',
      potentialMRR: (json['potentialMRR'] ?? 0).toDouble(),
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'])
          : null,
      nextFollowUpDate: json['nextFollowUpDate'] != null
          ? DateTime.parse(json['nextFollowUpDate'])
          : null,
      assignedSalesRep: json['assignedSalesRep'],
      salesTerritory: json['salesTerritory'],
      // NEW FIELDS
      isUsingCompetitor: json['isUsingCompetitor'] ?? false,
      competitorAppUsed: json['competitorAppUsed'],
      wonOverFromCompetitor: json['wonOverFromCompetitor'] ?? false,
      isMovedToPipeline: json['isMovedToPipeline'] ?? false,
      pipelineStatus: json['pipelineStatus'] != null
          ? (json['pipelineStatus'] as List)
          .map((p) => PipelineStatus.fromJson(p))
          .toList()
          : [],
      enrichmentData: json['enrichmentData'] != null
          ? EnrichmentData.fromJson(json['enrichmentData'])
          : null,
      conversionData: json['conversionData'] != null
          ? ConversionData.fromJson(json['conversionData'])
          : null,
      dataQuality: json['dataQuality'] != null
          ? DataQuality.fromJson(json['dataQuality'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'] != null
          ? (json['notes'] as List).map((n) => Note.fromJson(n)).toList()
          : null,
      tasks: json['tasks'] != null
          ? (json['tasks'] as List).map((t) => Task.fromJson(t)).toList()
          : null,
      dataSource: json['dataSource'],
      importedDate: json['importedDate'] != null
          ? DateTime.parse(json['importedDate'])
          : null,
      originalDataYear: json['originalDataYear'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecdName': ecdName,
      'operationalStatus': operationalStatus,
      'registrationStatus': registrationStatus,
      'registrationDate': registrationDate,
      'province': province,
      'provinceCode': provinceCode,
      'districtMunicipality': districtMunicipality,
      'localMunicipality': localMunicipality,
      'wardId': wardId,
      'gisLongitude': gisLongitude,
      'gisLatitude': gisLatitude,
      'location': location?.toJson(),
      'township': township,
      'suburb': suburb,
      'townCity': townCity,
      'streetAddress': streetAddress,
      'postalAddress': postalAddress,
      'contactPerson': contactPerson,
      'telephone': telephone,
      'email': email,
      'numberOfChildren': numberOfChildren,
      'numberOfStaff': numberOfStaff,
      'landOwnership': landOwnership,
      'buildingOwnership': buildingOwnership,
      'leadScore': leadScore,
      'leadStatus': leadStatus,
      'pipelineStage': pipelineStage,
      'potentialMRR': potentialMRR,
      'lastContactDate': lastContactDate?.toIso8601String(),
      'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
      'assignedSalesRep': assignedSalesRep,
      'salesTerritory': salesTerritory,
      // NEW FIELDS
      'isUsingCompetitor': isUsingCompetitor,
      'competitorAppUsed': competitorAppUsed,
      'wonOverFromCompetitor': wonOverFromCompetitor,
      'isMovedToPipeline': isMovedToPipeline,
      'pipelineStatus': pipelineStatus.map((p) => p.toJson()).toList(),
      'enrichmentData': enrichmentData?.toJson(),
      'conversionData': conversionData?.toJson(),
      'dataQuality': dataQuality?.toJson(),
      'tags': tags,
      'notes': notes?.map((n) => n.toJson()).toList(),
      'tasks': tasks?.map((t) => t.toJson()).toList(),
      'dataSource': dataSource,
      'importedDate': importedDate?.toIso8601String(),
      'originalDataYear': originalDataYear,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for updates
  ZAECDCenters copyWith({
    String? ecdName,
    String? registrationStatus,
    String? contactPerson,
    String? telephone,
    String? email,
    int? numberOfChildren,
    int? leadScore,
    String? leadStatus,
    String? pipelineStage,
    DateTime? lastContactDate,
    String? assignedSalesRep,
    List<String>? tags,
    // NEW FIELDS
    bool? isUsingCompetitor,
    String? competitorAppUsed,
    bool? wonOverFromCompetitor,
    bool? isMovedToPipeline,
    List<PipelineStatus>? pipelineStatus,
  }) {
    return ZAECDCenters(
      id: id,
      ecdName: ecdName ?? this.ecdName,
      operationalStatus: operationalStatus,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      registrationDate: registrationDate,
      province: province,
      provinceCode: provinceCode,
      districtMunicipality: districtMunicipality,
      localMunicipality: localMunicipality,
      wardId: wardId,
      gisLongitude: gisLongitude,
      gisLatitude: gisLatitude,
      location: location,
      township: township,
      suburb: suburb,
      townCity: townCity,
      streetAddress: streetAddress,
      postalAddress: postalAddress,
      contactPerson: contactPerson ?? this.contactPerson,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      numberOfStaff: numberOfStaff,
      landOwnership: landOwnership,
      buildingOwnership: buildingOwnership,
      leadScore: leadScore ?? this.leadScore,
      leadStatus: leadStatus ?? this.leadStatus,
      pipelineStage: pipelineStage ?? this.pipelineStage,
      potentialMRR: potentialMRR,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      nextFollowUpDate: nextFollowUpDate,
      assignedSalesRep: assignedSalesRep ?? this.assignedSalesRep,
      salesTerritory: salesTerritory,
      // NEW FIELDS
      isUsingCompetitor: isUsingCompetitor ?? this.isUsingCompetitor,
      competitorAppUsed: competitorAppUsed ?? this.competitorAppUsed,
      wonOverFromCompetitor: wonOverFromCompetitor ?? this.wonOverFromCompetitor,
      isMovedToPipeline: isMovedToPipeline ?? this.isMovedToPipeline,
      pipelineStatus: pipelineStatus ?? this.pipelineStatus,
      enrichmentData: enrichmentData,
      conversionData: conversionData,
      dataQuality: dataQuality,
      tags: tags ?? this.tags,
      notes: notes,
      tasks: tasks,
      dataSource: dataSource,
      importedDate: importedDate,
      originalDataYear: originalDataYear,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// Supporting Classes (unchanged from before)

class LocationCoordinates {
  final String type;
  final List<double> coordinates;

  LocationCoordinates({
    this.type = 'Point',
    required this.coordinates,
  });

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0;

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class EnrichmentData {
  final String? websiteUrl;
  final SocialMediaLinks? socialMediaLinks;
  final List<AdditionalContact>? additionalContacts;
  final List<String>? competitorProducts;
  final String? budgetRange;
  final String? decisionMaker;
  final List<String>? painPoints;
  final List<String>? interests;

  EnrichmentData({
    this.websiteUrl,
    this.socialMediaLinks,
    this.additionalContacts,
    this.competitorProducts,
    this.budgetRange,
    this.decisionMaker,
    this.painPoints,
    this.interests,
  });

  factory EnrichmentData.fromJson(Map<String, dynamic> json) {
    return EnrichmentData(
      websiteUrl: json['websiteUrl'],
      socialMediaLinks: json['socialMediaLinks'] != null
          ? SocialMediaLinks.fromJson(json['socialMediaLinks'])
          : null,
      additionalContacts: json['additionalContacts'] != null
          ? (json['additionalContacts'] as List)
          .map((c) => AdditionalContact.fromJson(c))
          .toList()
          : null,
      competitorProducts: List<String>.from(json['competitorProducts'] ?? []),
      budgetRange: json['budgetRange'],
      decisionMaker: json['decisionMaker'],
      painPoints: List<String>.from(json['painPoints'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteUrl': websiteUrl,
      'socialMediaLinks': socialMediaLinks?.toJson(),
      'additionalContacts': additionalContacts?.map((c) => c.toJson()).toList(),
      'competitorProducts': competitorProducts,
      'budgetRange': budgetRange,
      'decisionMaker': decisionMaker,
      'painPoints': painPoints,
      'interests': interests,
    };
  }
}

class SocialMediaLinks {
  final String? facebook;
  final String? linkedin;
  final String? twitter;

  SocialMediaLinks({
    this.facebook,
    this.linkedin,
    this.twitter,
  });

  factory SocialMediaLinks.fromJson(Map<String, dynamic> json) {
    return SocialMediaLinks(
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'linkedin': linkedin,
      'twitter': twitter,
    };
  }
}

class AdditionalContact {
  final String? name;
  final String? role;
  final String? phone;
  final String? email;

  AdditionalContact({
    this.name,
    this.role,
    this.phone,
    this.email,
  });

  factory AdditionalContact.fromJson(Map<String, dynamic> json) {
    return AdditionalContact(
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
    };
  }
}

class ConversionData {
  final bool convertedToTenant;
  final String? tenantId;
  final DateTime? conversionDate;
  final String? reasonWon;
  final String? reasonLost;
  final String? competitorWonLost;

  ConversionData({
    this.convertedToTenant = false,
    this.tenantId,
    this.conversionDate,
    this.reasonWon,
    this.reasonLost,
    this.competitorWonLost,
  });

  factory ConversionData.fromJson(Map<String, dynamic> json) {
    return ConversionData(
      convertedToTenant: json['convertedToTenant'] ?? false,
      tenantId: json['tenantId'],
      conversionDate: json['conversionDate'] != null
          ? DateTime.parse(json['conversionDate'])
          : null,
      reasonWon: json['reasonWon'],
      reasonLost: json['reasonLost'],
      competitorWonLost: json['competitorWonLost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'convertedToTenant': convertedToTenant,
      'tenantId': tenantId,
      'conversionDate': conversionDate?.toIso8601String(),
      'reasonWon': reasonWon,
      'reasonLost': reasonLost,
      'competitorWonLost': competitorWonLost,
    };
  }
}

class DataQuality {
  final bool hasValidPhone;
  final bool hasValidEmail;
  final bool hasCompleteAddress;
  final DateTime? lastVerifiedDate;
  final String? verificationSource;

  DataQuality({
    this.hasValidPhone = false,
    this.hasValidEmail = false,
    this.hasCompleteAddress = false,
    this.lastVerifiedDate,
    this.verificationSource,
  });

  factory DataQuality.fromJson(Map<String, dynamic> json) {
    return DataQuality(
      hasValidPhone: json['hasValidPhone'] ?? false,
      hasValidEmail: json['hasValidEmail'] ?? false,
      hasCompleteAddress: json['hasCompleteAddress'] ?? false,
      lastVerifiedDate: json['lastVerifiedDate'] != null
          ? DateTime.parse(json['lastVerifiedDate'])
          : null,
      verificationSource: json['verificationSource'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasValidPhone': hasValidPhone,
      'hasValidEmail': hasValidEmail,
      'hasCompleteAddress': hasCompleteAddress,
      'lastVerifiedDate': lastVerifiedDate?.toIso8601String(),
      'verificationSource': verificationSource,
    };
  }
}

class Note {
  final String content;
  final String? author;
  final DateTime createdAt;
  final String type;

  Note({
    required this.content,
    this.author,
    required this.createdAt,
    this.type = 'general',
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      content: json['content'] ?? '',
      author: json['author'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      type: json['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
    };
  }
}

class Task {
  final String? title;
  final String? description;
  final DateTime? dueDate;
  final bool completed;
  final String? assignedTo;
  final DateTime? completedDate;

  Task({
    this.title,
    this.description,
    this.dueDate,
    this.completed = false,
    this.assignedTo,
    this.completedDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      completed: json['completed'] ?? false,
      assignedTo: json['assignedTo'],
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
      'assignedTo': assignedTo,
      'completedDate': completedDate?.toIso8601String(),
    };
  }
}

// Analytics Models (updated with competitor stats)

class MarketAnalytics {
  final MarketOverall overall;
  final List<ProvinceStats> byProvince;
  final List<RegistrationStats> byRegistrationStatus;
  final List<PipelineStageStats> pipelineFunnel;
  final ConversionMetrics conversionMetrics;
  final List<ZAECDCenters> topOpportunities;
  // NEW: Competitor analytics
  final List<CompetitorStats> competitorAnalysis;
  final List<PipelineStatusStats> pipelineStatusDistribution;

  MarketAnalytics({
    required this.overall,
    required this.byProvince,
    required this.byRegistrationStatus,
    required this.pipelineFunnel,
    required this.conversionMetrics,
    required this.topOpportunities,
    required this.competitorAnalysis,
    required this.pipelineStatusDistribution,
  });

  factory MarketAnalytics.fromJson(Map<String, dynamic> json) {
    return MarketAnalytics(
      overall: MarketOverall.fromJson(json['overall'] ?? {}),
      byProvince: (json['byProvince'] as List? ?? [])
          .map((p) => ProvinceStats.fromJson(p))
          .toList(),
      byRegistrationStatus: (json['byRegistrationStatus'] as List? ?? [])
          .map((r) => RegistrationStats.fromJson(r))
          .toList(),
      pipelineFunnel: (json['pipelineFunnel'] as List? ?? [])
          .map((p) => PipelineStageStats.fromJson(p))
          .toList(),
      conversionMetrics: ConversionMetrics.fromJson(json['conversionMetrics'] ?? {}),
      topOpportunities: (json['topOpportunities'] as List? ?? [])
          .map((o) => ZAECDCenters.fromJson(o))
          .toList(),
      competitorAnalysis: (json['competitorAnalysis'] as List? ?? [])
          .map((c) => CompetitorStats.fromJson(c))
          .toList(),
      pipelineStatusDistribution: (json['pipelineStatusDistribution'] as List? ?? [])
          .map((p) => PipelineStatusStats.fromJson(p))
          .toList(),
    );
  }
}

class MarketOverall {
  final int totalCenters;
  final int totalChildren;
  final int totalStaff;
  final double totalPotentialMRR;
  // NEW: Competitor metrics
  final int usingCompetitors;
  final int wonFromCompetitors;
  final int movedToPipeline;

  MarketOverall({
    required this.totalCenters,
    required this.totalChildren,
    required this.totalStaff,
    required this.totalPotentialMRR,
    required this.usingCompetitors,
    required this.wonFromCompetitors,
    required this.movedToPipeline,
  });

  factory MarketOverall.fromJson(Map<String, dynamic> json) {
    return MarketOverall(
      totalCenters: json['totalCenters'] ?? 0,
      totalChildren: json['totalChildren'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
      totalPotentialMRR: (json['totalPotentialMRR'] ?? 0).toDouble(),
      usingCompetitors: json['usingCompetitors'] ?? 0,
      wonFromCompetitors: json['wonFromCompetitors'] ?? 0,
      movedToPipeline: json['movedToPipeline'] ?? 0,
    );
  }
}

class ProvinceStats {
  final String province;
  final int count;
  final int totalChildren;
  final double avgChildren;
  final double potentialMRR;
  final int registered;
  // NEW: Competitor data by province
  final int usingCompetitors;

  ProvinceStats({
    required this.province,
    required this.count,
    required this.totalChildren,
    required this.avgChildren,
    required this.potentialMRR,
    required this.registered,
    required this.usingCompetitors,
  });

  factory ProvinceStats.fromJson(Map<String, dynamic> json) {
    return ProvinceStats(
      province: json['_id'] ?? json['province'] ?? '',
      count: json['count'] ?? 0,
      totalChildren: json['totalChildren'] ?? 0,
      avgChildren: (json['avgChildren'] ?? 0).toDouble(),
      potentialMRR: (json['potentialMRR'] ?? 0).toDouble(),
      registered: json['registered'] ?? 0,
      usingCompetitors: json['usingCompetitors'] ?? 0,
    );
  }
}

class RegistrationStats {
  final String status;
  final int count;

  RegistrationStats({
    required this.status,
    required this.count,
  });

  factory RegistrationStats.fromJson(Map<String, dynamic> json) {
    return RegistrationStats(
      status: json['_id'] ?? json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class PipelineStageStats {
  final String stage;
  final int count;
  final double potentialMRR;
  final double avgLeadScore;

  PipelineStageStats({
    required this.stage,
    required this.count,
    required this.potentialMRR,
    required this.avgLeadScore,
  });

  factory PipelineStageStats.fromJson(Map<String, dynamic> json) {
    return PipelineStageStats(
      stage: json['_id'] ?? json['stage'] ?? '',
      count: json['count'] ?? 0,
      potentialMRR: (json['potentialMRR'] ?? 0).toDouble(),
      avgLeadScore: (json['avgLeadScore'] ?? 0).toDouble(),
    );
  }
}

class ConversionMetrics {
  final int totalLeads;
  final int converted;
  final int lost;
  final int inProgress;

  ConversionMetrics({
    required this.totalLeads,
    required this.converted,
    required this.lost,
    required this.inProgress,
  });

  double get conversionRate => totalLeads > 0 ? (converted / totalLeads) * 100 : 0;
  double get lossRate => totalLeads > 0 ? (lost / totalLeads) * 100 : 0;

  factory ConversionMetrics.fromJson(Map<String, dynamic> json) {
    return ConversionMetrics(
      totalLeads: json['totalLeads'] ?? 0,
      converted: json['converted'] ?? 0,
      lost: json['lost'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
    );
  }
}

// NEW: Competitor Analytics
class CompetitorStats {
  final String? competitorName;
  final int count;
  final int totalChildren;
  final double avgLeadScore;

  CompetitorStats({
    required this.competitorName,
    required this.count,
    required this.totalChildren,
    required this.avgLeadScore,
  });

  factory CompetitorStats.fromJson(Map<String, dynamic> json) {
    return CompetitorStats(
      competitorName: json['_id'],
      count: json['count'] ?? 0,
      totalChildren: json['totalChildren'] ?? 0,
      avgLeadScore: (json['avgLeadScore'] ?? 0).toDouble(),
    );
  }
}

// NEW: Pipeline Status Analytics
class PipelineStatusStats {
  final String status;
  final int count;

  PipelineStatusStats({
    required this.status,
    required this.count,
  });

  factory PipelineStatusStats.fromJson(Map<String, dynamic> json) {
    return PipelineStatusStats(
      status: json['_id'] ?? json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
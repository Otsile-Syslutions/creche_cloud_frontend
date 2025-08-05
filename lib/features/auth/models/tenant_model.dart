// lib/features/tenant/models/tenant_model.dart

class TenantModel {
  final String id;
  final String name;
  final String displayName;
  final String slug;
  final String? email;
  final String? phoneNumber;
  final TenantAddress? address;
  final TenantSubscription subscription;
  final TenantFeatures features;
  final TenantUsage usage;
  final TenantLimits limits;
  final bool isActive;
  final bool isSuspended;
  final bool isPlatformTenant;
  final String? apiKey;
  final DateTime? trialEndsAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TenantModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.slug,
    this.email,
    this.phoneNumber,
    this.address,
    required this.subscription,
    required this.features,
    required this.usage,
    required this.limits,
    required this.isActive,
    this.isSuspended = false,
    this.isPlatformTenant = false,
    this.apiKey,
    this.trialEndsAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  bool get isExpired => subscription.endDate.isBefore(DateTime.now());

  bool get isInTrial => subscription.plan == 'trial' &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());

  int get daysUntilExpiry {
    final now = DateTime.now();
    final diffTime = subscription.endDate.difference(now);
    return diffTime.inDays;
  }

  double get usagePercentage {
    if (usage.users.limit == 0) return 0;
    return (usage.users.current / usage.users.limit) * 100;
  }

  double get storagePercentage {
    if (usage.storageGB.limit == 0) return 0;
    return (usage.storageGB.current / usage.storageGB.limit) * 100;
  }

  // Business logic methods
  bool checkSubscriptionStatus() {
    if (isPlatformTenant) return true; // Platform tenant is always active
    if (isSuspended) return false;
    if (!isActive) return false;

    final now = DateTime.now();

    // Check if subscription has expired
    if (subscription.endDate.isBefore(now)) {
      return false;
    }

    // Check if in trial and trial has expired
    if (subscription.plan == 'trial' && trialEndsAt != null && trialEndsAt!.isBefore(now)) {
      return false;
    }

    return subscription.status == 'active' || subscription.status == 'trial';
  }

  bool hasFeature(String featureName) {
    if (isPlatformTenant) return true; // Platform tenant has all features
    return features.hasFeature(featureName);
  }

  bool checkUsageLimit(String resourceType) {
    if (isPlatformTenant) return true; // Platform tenant has unlimited usage

    switch (resourceType) {
      case 'users':
        return usage.users.current < usage.users.limit;
      case 'children':
        return usage.children.current < usage.children.limit;
      case 'storage':
        return usage.storageGB.current < usage.storageGB.limit;
      default:
        return true;
    }
  }

  String get subscriptionStatusDisplay {
    if (isPlatformTenant) return 'Platform';
    if (isSuspended) return 'Suspended';
    if (!isActive) return 'Inactive';
    if (isExpired) return 'Expired';
    if (isInTrial) return 'Trial';
    return subscription.status.toUpperCase();
  }

  String get planDisplayName {
    const planNames = {
      'trial': 'Trial',
      'basic': 'Basic',
      'standard': 'Standard',
      'premium': 'Premium',
      'enterprise': 'Enterprise',
      'platform': 'Platform'
    };
    return planNames[subscription.plan] ?? subscription.plan.toUpperCase();
  }

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      slug: json['slug'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'] != null
          ? TenantAddress.fromJson(json['address'])
          : null,
      subscription: TenantSubscription.fromJson(json['subscription'] ?? {}),
      features: TenantFeatures.fromJson(json['features'] ?? {}),
      usage: TenantUsage.fromJson(json['usage'] ?? {}),
      limits: TenantLimits.fromJson(json['limits'] ?? {}),
      isActive: json['isActive'] ?? true,
      isSuspended: json['isSuspended'] ?? false,
      isPlatformTenant: json['isPlatformTenant'] ?? false,
      apiKey: json['apiKey'],
      trialEndsAt: json['trialEndsAt'] != null
          ? DateTime.parse(json['trialEndsAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'slug': slug,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address?.toJson(),
      'subscription': subscription.toJson(),
      'features': features.toJson(),
      'usage': usage.toJson(),
      'limits': limits.toJson(),
      'isActive': isActive,
      'isSuspended': isSuspended,
      'isPlatformTenant': isPlatformTenant,
      'apiKey': apiKey,
      'trialEndsAt': trialEndsAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TenantModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? slug,
    String? email,
    String? phoneNumber,
    TenantAddress? address,
    TenantSubscription? subscription,
    TenantFeatures? features,
    TenantUsage? usage,
    TenantLimits? limits,
    bool? isActive,
    bool? isSuspended,
    bool? isPlatformTenant,
    String? apiKey,
    DateTime? trialEndsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      slug: slug ?? this.slug,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      subscription: subscription ?? this.subscription,
      features: features ?? this.features,
      usage: usage ?? this.usage,
      limits: limits ?? this.limits,
      isActive: isActive ?? this.isActive,
      isSuspended: isSuspended ?? this.isSuspended,
      isPlatformTenant: isPlatformTenant ?? this.isPlatformTenant,
      apiKey: apiKey ?? this.apiKey,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// =============================================================================
// TENANT SUBSCRIPTION MODEL
// =============================================================================

class TenantSubscription {
  final String plan;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? billingCycle;

  TenantSubscription({
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.billingCycle,
  });

  factory TenantSubscription.fromJson(Map<String, dynamic> json) {
    return TenantSubscription(
      plan: json['plan'] ?? 'trial',
      status: json['status'] ?? 'active',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(Duration(days: 30)).toIso8601String()),
      billingCycle: json['billingCycle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'billingCycle': billingCycle,
    };
  }
}

// =============================================================================
// TENANT FEATURES MODEL
// =============================================================================

class TenantFeatures {
  final bool dashboard;
  final bool children;
  final bool attendance;
  final bool meals;
  final bool activities;
  final bool reports;
  final bool communication;
  final bool media;
  final bool billing;
  final bool api;
  final bool customBranding;
  final bool advancedReports;

  TenantFeatures({
    this.dashboard = true,
    this.children = true,
    this.attendance = true,
    this.meals = true,
    this.activities = false,
    this.reports = false,
    this.communication = false,
    this.media = false,
    this.billing = false,
    this.api = false,
    this.customBranding = false,
    this.advancedReports = false,
  });

  bool hasFeature(String featureName) {
    switch (featureName) {
      case 'dashboard': return dashboard;
      case 'children': return children;
      case 'attendance': return attendance;
      case 'meals': return meals;
      case 'activities': return activities;
      case 'reports': return reports;
      case 'communication': return communication;
      case 'media': return media;
      case 'billing': return billing;
      case 'api': return api;
      case 'customBranding': return customBranding;
      case 'advancedReports': return advancedReports;
      default: return false;
    }
  }

  List<String> get enabledFeatures {
    final enabled = <String>[];
    if (dashboard) enabled.add('dashboard');
    if (children) enabled.add('children');
    if (attendance) enabled.add('attendance');
    if (meals) enabled.add('meals');
    if (activities) enabled.add('activities');
    if (reports) enabled.add('reports');
    if (communication) enabled.add('communication');
    if (media) enabled.add('media');
    if (billing) enabled.add('billing');
    if (api) enabled.add('api');
    if (customBranding) enabled.add('customBranding');
    if (advancedReports) enabled.add('advancedReports');
    return enabled;
  }

  factory TenantFeatures.fromJson(Map<String, dynamic> json) {
    return TenantFeatures(
      dashboard: json['dashboard'] ?? true,
      children: json['children'] ?? true,
      attendance: json['attendance'] ?? true,
      meals: json['meals'] ?? true,
      activities: json['activities'] ?? false,
      reports: json['reports'] ?? false,
      communication: json['communication'] ?? false,
      media: json['media'] ?? false,
      billing: json['billing'] ?? false,
      api: json['api'] ?? false,
      customBranding: json['customBranding'] ?? false,
      advancedReports: json['advancedReports'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard': dashboard,
      'children': children,
      'attendance': attendance,
      'meals': meals,
      'activities': activities,
      'reports': reports,
      'communication': communication,
      'media': media,
      'billing': billing,
      'api': api,
      'customBranding': customBranding,
      'advancedReports': advancedReports,
    };
  }
}

// =============================================================================
// TENANT USAGE MODEL
// =============================================================================

class TenantUsage {
  final UsageMetric users;
  final UsageMetric children;
  final UsageMetric storageGB;

  TenantUsage({
    required this.users,
    required this.children,
    required this.storageGB,
  });

  factory TenantUsage.fromJson(Map<String, dynamic> json) {
    return TenantUsage(
      users: UsageMetric.fromJson(json['users'] ?? {}),
      children: UsageMetric.fromJson(json['children'] ?? {}),
      storageGB: UsageMetric.fromJson(json['storageGB'] ?? json['storage'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.toJson(),
      'children': children.toJson(),
      'storageGB': storageGB.toJson(),
    };
  }
}

class UsageMetric {
  final int current;
  final int limit;

  UsageMetric({
    required this.current,
    required this.limit,
  });

  double get percentage => limit > 0 ? (current / limit) * 100 : 0;
  bool get isNearLimit => percentage > 80;
  bool get isAtLimit => current >= limit;
  int get remaining => limit - current;

  factory UsageMetric.fromJson(Map<String, dynamic> json) {
    return UsageMetric(
      current: json['current'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'limit': limit,
    };
  }
}

// =============================================================================
// TENANT LIMITS MODEL
// =============================================================================

class TenantLimits {
  final int maxUsers;
  final int maxChildren;
  final int maxStorage; // in GB
  final int maxApiCalls;
  final int maxFileSize; // in MB

  TenantLimits({
    required this.maxUsers,
    required this.maxChildren,
    required this.maxStorage,
    this.maxApiCalls = 0,
    this.maxFileSize = 50,
  });

  factory TenantLimits.fromJson(Map<String, dynamic> json) {
    return TenantLimits(
      maxUsers: json['maxUsers'] ?? 0,
      maxChildren: json['maxChildren'] ?? 0,
      maxStorage: json['maxStorage'] ?? 0,
      maxApiCalls: json['maxApiCalls'] ?? 0,
      maxFileSize: json['maxFileSize'] ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxUsers': maxUsers,
      'maxChildren': maxChildren,
      'maxStorage': maxStorage,
      'maxApiCalls': maxApiCalls,
      'maxFileSize': maxFileSize,
    };
  }
}

// =============================================================================
// TENANT ADDRESS MODEL
// =============================================================================

class TenantAddress {
  final String? street;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;

  TenantAddress({
    this.street,
    this.city,
    this.province,
    this.postalCode,
    this.country,
  });

  String get formatted {
    final parts = <String>[];
    if (street?.isNotEmpty == true) parts.add(street!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (province?.isNotEmpty == true) parts.add(province!);
    if (postalCode?.isNotEmpty == true) parts.add(postalCode!);
    if (country?.isNotEmpty == true) parts.add(country!);
    return parts.join(', ');
  }

  factory TenantAddress.fromJson(Map<String, dynamic> json) {
    return TenantAddress(
      street: json['street'],
      city: json['city'],
      province: json['province'],
      postalCode: json['postalCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

// =============================================================================
// TENANT STATISTICS MODEL (for dashboard/stats responses)
// =============================================================================

class TenantStatistics {
  final TenantModel tenant;
  final Map<String, dynamic> userStats;
  final Map<String, dynamic> childrenStats;
  final Map<String, dynamic> storageStats;
  final Map<String, dynamic> activityStats;

  TenantStatistics({
    required this.tenant,
    required this.userStats,
    required this.childrenStats,
    required this.storageStats,
    required this.activityStats,
  });

  factory TenantStatistics.fromJson(Map<String, dynamic> json) {
    return TenantStatistics(
      tenant: TenantModel.fromJson(json['tenant'] ?? {}),
      userStats: json['users'] ?? {},
      childrenStats: json['children'] ?? {},
      storageStats: json['storage'] ?? {},
      activityStats: json['activities'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant': tenant.toJson(),
      'users': userStats,
      'children': childrenStats,
      'storage': storageStats,
      'activities': activityStats,
    };
  }
}

// =============================================================================
// TENANT DASHBOARD MODEL
// =============================================================================

class TenantDashboard {
  final TenantModel tenant;
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> recentActivity;
  final Map<String, dynamic> alerts;
  final Map<String, dynamic> quickStats;

  TenantDashboard({
    required this.tenant,
    required this.overview,
    required this.recentActivity,
    required this.alerts,
    required this.quickStats,
  });

  factory TenantDashboard.fromJson(Map<String, dynamic> json) {
    return TenantDashboard(
      tenant: TenantModel.fromJson(json['tenant'] ?? {}),
      overview: json['overview'] ?? {},
      recentActivity: List<Map<String, dynamic>>.from(json['recentActivity'] ?? []),
      alerts: json['alerts'] ?? {},
      quickStats: json['quickStats'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant': tenant.toJson(),
      'overview': overview,
      'recentActivity': recentActivity,
      'alerts': alerts,
      'quickStats': quickStats,
    };
  }
}
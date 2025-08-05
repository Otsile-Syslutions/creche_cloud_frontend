// lib/features/auth/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final List<UserRole> roles;
  final List<String> permissions;
  final String? tenantId; // Reference to tenant
  final bool isActive;
  final bool isEmailVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> children;
  final UserMetadata? metadata;
  final bool isPlatformAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.roles,
    required this.permissions,
    this.tenantId,
    required this.isActive,
    required this.isEmailVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.children = const [],
    this.metadata,
    this.isPlatformAdmin = false,
  });

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';
  List<String> get roleNames => roles.map((role) => role.name).toList();

  // RBAC methods
  bool hasRole(String role) => roleNames.contains(role);

  bool hasPermission(String permission) {
    // Check explicit permissions
    if (permissions.contains(permission)) {
      return true;
    }

    // Check role-based permissions
    return _hasRoleBasedPermission(permission);
  }

  bool hasAnyRole(List<String> roleList) => roleList.any((role) => hasRole(role));

  bool hasAnyPermission(List<String> permissionList) =>
      permissionList.any((permission) => hasPermission(permission));

  bool _hasRoleBasedPermission(String permission) {
    // Define role-based permissions based on backend structure
    final rolePermissions = <String, List<String>>{
      'platform_admin': ['*'], // Platform admin has all permissions
      'super_admin': ['*'], // Super admin has all permissions
      'school_admin': [
        'user:read', 'user:create', 'user:update', 'user:delete',
        'child:read', 'child:create', 'child:update', 'child:delete',
        'activity:read', 'activity:create', 'activity:update', 'activity:delete',
        'report:read', 'report:create', 'report:export',
        'attendance:read', 'attendance:create', 'attendance:update',
        'communication:read', 'communication:create', 'communication:update',
        'billing:read', 'billing:update',
        'setting:read', 'setting:update',
        'meal:create', 'meal:read', 'meal:update',
        'media:create', 'media:read', 'media:update',
      ],
      'tenant_admin': [
        'user:read', 'user:create', 'user:update',
        'child:read', 'child:create', 'child:update', 'child:delete',
        'activity:read', 'activity:create', 'activity:update',
        'report:read', 'report:create',
        'attendance:read', 'attendance:create', 'attendance:update',
        'communication:read', 'communication:create',
        'setting:read', 'setting:update',
        'meal:create', 'meal:read',
        'media:read',
      ],
      'teacher': [
        'user:read',
        'child:read_assigned', 'child:update_assigned',
        'activity:read', 'activity:create', 'activity:update',
        'attendance:read', 'attendance:create', 'attendance:update',
        'communication:read', 'communication:create',
        'report:read',
        'meal:create', 'meal:read',
        'media:create', 'media:read',
      ],
      'assistant': [
        'child:read_assigned',
        'activity:read', 'activity:update',
        'attendance:read', 'attendance:update',
        'communication:read',
        'meal:create', 'meal:read',
        'media:read',
      ],
      'parent': [
        'child:read', // Only own children
        'activity:read',
        'attendance:read',
        'communication:read',
        'report:read', // Only own children's reports
      ],
      'staff': [
        'child:read_assigned',
        'activity:read',
        'attendance:read',
        'communication:read',
        'meal:read',
      ],
    };

    for (final roleName in roleNames) {
      final perms = rolePermissions[roleName] ?? [];
      if (perms.contains('*') || perms.contains(permission)) {
        return true;
      }
    }

    return false;
  }

  // Child access control methods
  bool canAccessChild(String childId) {
    // Platform/Super admin and school admin can access all children
    if (hasRole('platform_admin') || hasRole('super_admin') || hasRole('school_admin')) {
      return true;
    }

    // Teachers and assistants can access children assigned to them
    if (hasRole('teacher') || hasRole('assistant')) {
      return hasPermission('child:read_assigned') || hasPermission('child:read');
    }

    // Parents can only access their own children
    if (hasRole('parent')) {
      return children.contains(childId);
    }

    return false;
  }

  // Check if user can modify child data
  bool canModifyChild(String childId) {
    if (hasRole('platform_admin') || hasRole('super_admin') || hasRole('school_admin')) {
      return true;
    }

    if (hasRole('teacher') && canAccessChild(childId)) {
      return hasPermission('child:update') || hasPermission('child:update_assigned');
    }

    return false;
  }

  // Classroom access - derived from child access permissions
  bool canAccessClassroom(String classroomId) {
    // Platform/Super admin and school admin can access all classrooms
    if (hasRole('platform_admin') || hasRole('super_admin') || hasRole('school_admin')) {
      return true;
    }

    // Teachers can access classrooms if they have assigned child permissions
    if (hasRole('teacher')) {
      return hasPermission('child:read_assigned') || hasPermission('child:read');
    }

    // Teaching assistants can access classrooms they are assigned to
    if (hasRole('assistant')) {
      return hasPermission('child:read_assigned');
    }

    // School managers can access classrooms
    if (hasRole('school_manager')) {
      return hasPermission('child:read');
    }

    return false;
  }

  // User type helpers
  bool get isAdmin => hasRole('platform_admin') || hasRole('super_admin') || hasRole('school_admin');
  bool get isTeacher => hasRole('teacher');
  bool get isParent => hasRole('parent');
  bool get isStaff => hasRole('staff') || hasRole('assistant');
  bool get isTenantAdmin => hasRole('school_admin') || hasRole('tenant_admin');

  // Get user's primary role for display
  String get primaryRole {
    if (hasRole('platform_admin')) return 'Platform Admin';
    if (hasRole('super_admin')) return 'Super Admin';
    if (hasRole('school_admin')) return 'School Admin';
    if (hasRole('tenant_admin')) return 'Tenant Admin';
    if (hasRole('teacher')) return 'Teacher';
    if (hasRole('assistant')) return 'Assistant';
    if (hasRole('parent')) return 'Parent';
    if (hasRole('staff')) return 'Staff';
    return 'User';
  }

  // Get platform type for navigation
  String get platformType {
    if (hasRole('platform_admin') || hasRole('super_admin')) {
      return 'admin';
    }
    if (hasRole('school_admin') || hasRole('tenant_admin') || hasRole('teacher') || hasRole('assistant')) {
      return 'tenant';
    }
    if (hasRole('parent')) {
      return 'parent';
    }
    return 'tenant'; // Default fallback
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
      roles: _parseRoles(json['roles']),
      permissions: List<String>.from(json['permissions'] ?? []),
      tenantId: json['tenant'] is String
          ? json['tenant']
          : json['tenant']?['id'] ?? json['tenant']?['_id'],
      isActive: json['isActive'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      children: List<String>.from(json['children'] ?? []),
      metadata: json['metadata'] != null
          ? UserMetadata.fromJson(json['metadata'])
          : null,
      isPlatformAdmin: json['isPlatformAdmin'] ?? false,
    );
  }

  static List<UserRole> _parseRoles(dynamic rolesData) {
    if (rolesData == null) return [];

    if (rolesData is List) {
      return rolesData.map((role) {
        if (role is String) {
          // Simple string role
          return UserRole(id: '', name: role, displayName: _getDisplayName(role));
        } else if (role is Map<String, dynamic>) {
          // Full role object from backend
          return UserRole.fromJson(role);
        }
        return UserRole(id: '', name: 'user', displayName: 'User');
      }).toList();
    }

    return [];
  }

  static String _getDisplayName(String roleName) {
    const roleDisplayNames = {
      'platform_admin': 'Platform Admin',
      'super_admin': 'Super Admin',
      'school_admin': 'School Admin',
      'tenant_admin': 'Tenant Admin',
      'teacher': 'Teacher',
      'assistant': 'Assistant',
      'parent': 'Parent',
      'staff': 'Staff',
    };
    return roleDisplayNames[roleName] ?? roleName;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'roles': roles.map((role) => role.toJson()).toList(),
      'permissions': permissions,
      'tenant': tenantId,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'children': children,
      'metadata': metadata?.toJson(),
      'isPlatformAdmin': isPlatformAdmin,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    List<UserRole>? roles,
    List<String>? permissions,
    String? tenantId,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? children,
    UserMetadata? metadata,
    bool? isPlatformAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      tenantId: tenantId ?? this.tenantId,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
      metadata: metadata ?? this.metadata,
      isPlatformAdmin: isPlatformAdmin ?? this.isPlatformAdmin,
    );
  }
}

// =============================================================================
// SUPPORTING CLASSES
// =============================================================================

class UserRole {
  final String id;
  final String name;
  final String displayName;
  final List<String>? permissions;

  UserRole({
    required this.id,
    required this.name,
    required this.displayName,
    this.permissions,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'permissions': permissions,
    };
  }
}

class UserMetadata {
  final String? phoneNumber;
  final String? address;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? profileData;

  UserMetadata({
    this.phoneNumber,
    this.address,
    this.preferences,
    this.profileData,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      preferences: json['preferences'],
      profileData: json['profileData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'address': address,
      'preferences': preferences,
      'profileData': profileData,
    };
  }

  UserMetadata copyWith({
    String? phoneNumber,
    String? address,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? profileData,
  }) {
    return UserMetadata(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
      profileData: profileData ?? this.profileData,
    );
  }
}
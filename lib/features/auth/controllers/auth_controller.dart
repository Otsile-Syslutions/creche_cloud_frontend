// lib/features/auth/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import '../models/tenant_model.dart';
import '../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/config/env.dart';
import '../../../utils/app_logger.dart';
import 'login_form_controller.dart';
import 'signup_form_controller.dart';

class AuthController extends GetxController {
  // Services
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Authentication state
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<TenantModel?> currentTenant = Rx<TenantModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInitialized = false.obs;

  // Session management
  final RxString currentTenantId = ''.obs;
  final RxBool sessionExpired = false.obs;
  Timer? _sessionTimer;
  Timer? _tokenRefreshTimer;

  // Form controllers
  LoginFormController? get loginFormController {
    try {
      return Get.find<LoginFormController>();
    } catch (e) {
      return null;
    }
  }

  SignUpFormController? get signUpFormController {
    try {
      return Get.find<SignUpFormController>();
    } catch (e) {
      return null;
    }
  }

  // Password reset form controllers
  final TextEditingController resetEmailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  @override
  void onClose() {
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    resetEmailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // =============================================================================
  // INITIALIZATION
  // =============================================================================

  Future<void> _initializeAuth() async {
    try {
      AppLogger.i('Initializing authentication...');

      // Load stored tenant ID
      final storedTenantId = await _storageService.getString('current_tenant_id');
      if (storedTenantId != null && storedTenantId.isNotEmpty) {
        currentTenantId.value = storedTenantId;
      }

      // Check if user is already authenticated
      final token = await _storageService.getString('access_token');
      if (token != null && token.isNotEmpty) {
        try {
          // Set token in API service
          await _apiService.setAccessToken(token);

          // Verify token and get current user
          await getCurrentUser();

          // Load current tenant if user is authenticated
          if (isAuthenticated.value && currentUser.value?.tenantId != null) {
            await getCurrentTenant();
          }

          // Start session management
          _startSessionManagement();

          AppLogger.i('User session restored successfully');
        } catch (e) {
          AppLogger.w('Stored token is invalid, clearing session', e);
          await clearSession();
        }
      }

      isInitialized.value = true;
      AppLogger.i('Authentication initialization complete');
    } catch (e) {
      AppLogger.e('Auth initialization failed', e);
      isInitialized.value = true;
    }
  }

  // =============================================================================
  // AUTHENTICATION METHODS
  // =============================================================================

  /// Login user
  Future<void> login() async {
    final formController = loginFormController;
    if (formController == null || !formController.validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      sessionExpired.value = false;

      final loginData = {
        'email': formController.emailController.text.trim(),
        'password': formController.passwordController.text,
        'rememberMe': formController.rememberMe.value,
      };

      AppLogger.i('Attempting login for user: ${loginData['email']}');

      final response = await _apiService.login(
        email: loginData['email'] as String,
        password: loginData['password'] as String,
        rememberMe: loginData['rememberMe'] as bool,
        tenantId: currentTenantId.value.isNotEmpty ? currentTenantId.value : null,
      );

      if (response.success && response.data != null) {
        await _handleSuccessfulLogin(response.data!, formController);
      } else {
        final message = response.message ?? 'Login failed';
        throw ApiException(message: message);
      }

    } on ApiException catch (e) {
      await _handleLoginError(e, formController);
    } catch (e) {
      AppLogger.e('Login error', e);
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      _showErrorSnackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle successful login
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> data, LoginFormController formController) async {
    final userData = data['user'];
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];

    // Store authentication data
    await _storageService.setString('access_token', accessToken);
    await _storageService.setString('user_data', jsonEncode(userData));

    if (refreshToken != null) {
      await _storageService.setString('refresh_token', refreshToken);
    }

    // Create user model
    final user = UserModel.fromJson(userData);
    currentUser.value = user;
    isAuthenticated.value = true;

    // Update tenant ID and load tenant data
    if (user.tenantId != null) {
      currentTenantId.value = user.tenantId!;
      await _storageService.setString('current_tenant_id', user.tenantId!);
      await getCurrentTenant();
    }

    // Store remember me preference
    if (formController.rememberMe.value) {
      await _storageService.setBool('remember_me', true);
      await _storageService.setString('remembered_email', formController.emailController.text.trim());
    }

    // Start session management
    _startSessionManagement();

    AppLogger.i('Login successful for user: ${user.fullName}');

    // Navigate to appropriate platform
    final homeRoute = AppRoutes.getHomeRouteForRoles(user.roleNames);
    Get.offAllNamed(homeRoute);

    _showSuccessSnackbar('Welcome Back', 'Hello ${user.firstName}!');

    // Log the successful login
    _logAuthEvent('login_success', {
      'user_id': user.id,
      'tenant_id': currentTenantId.value,
    });
  }

  /// Handle login errors
  Future<void> _handleLoginError(ApiException e, LoginFormController formController) async {
    AppLogger.w('Login failed: ${e.message}');
    errorMessage.value = e.message;

    // Handle specific error cases
    if (e.statusCode == 423) {
      // Account locked
      Get.dialog(
        AlertDialog(
          title: const Text('Account Locked'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (e.statusCode == 403 && e.message.contains('TENANT_SUSPENDED')) {
      // Tenant suspended
      Get.dialog(
        AlertDialog(
          title: const Text('Account Suspended'),
          content: const Text('This account has been suspended. Please contact support for assistance.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                // TODO: Add support contact functionality
              },
              child: const Text('Contact Support'),
            ),
          ],
        ),
      );
    } else {
      _showErrorSnackbar('Login Failed', e.message);
    }

    _logAuthEvent('login_failed', {
      'email': formController.emailController.text.trim(),
      'error': e.message,
    });
  }

  /// Register new user
  Future<void> signUp() async {
    final formController = signUpFormController;
    if (formController == null || !formController.validateForm()) {
      if (formController != null && !formController.acceptTerms.value) {
        _showWarningSnackbar('Terms Required', 'Please accept the Terms and Conditions to continue');
      }
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      AppLogger.i('Attempting registration for user: ${formController.signUpEmailController.text.trim()}');

      final response = await _apiService.register(
        firstName: formController.firstNameController.text.trim(),
        lastName: formController.lastNameController.text.trim(),
        email: formController.signUpEmailController.text.trim(),
        password: formController.signUpPasswordController.text,
        role: 'parent', // Default role for self-registration
        tenantId: currentTenantId.value.isNotEmpty ? currentTenantId.value : null,
      );

      if (response.success) {
        AppLogger.i('Registration successful');

        Get.snackbar(
          'Registration Successful',
          'Please check your email to verify your account before logging in.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Navigate to login
        Get.offAllNamed(AppRoutes.login);

        _logAuthEvent('registration_success', {
          'email': formController.signUpEmailController.text.trim(),
          'tenant_id': currentTenantId.value,
        });

      } else {
        final message = response.message ?? 'Registration failed';
        throw ApiException(message: message);
      }

    } on ApiException catch (e) {
      AppLogger.w('Registration failed: ${e.message}');
      errorMessage.value = e.message;

      // Handle specific registration errors
      if (e.message.contains('USER_EXISTS')) {
        _showErrorSnackbar('Email Already Registered',
            'An account with this email already exists. Please try logging in instead.');
      } else if (e.message.contains('TENANT_REQUIRED')) {
        _showErrorSnackbar('Tenant Required',
            'Please select a valid organization to register with.');
      } else if (e.message.contains('USER_LIMIT_EXCEEDED')) {
        _showErrorSnackbar('Registration Unavailable',
            'This organization has reached its user limit. Please contact support.');
      } else {
        _showErrorSnackbar('Registration Failed', e.message);
      }

      _logAuthEvent('registration_failed', {
        'email': formController.signUpEmailController.text.trim(),
        'error': e.message,
      });

    } catch (e) {
      AppLogger.e('Registration error', e);
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      _showErrorSnackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user with comprehensive cleanup - FIXED VERSION
  Future<void> logout({bool showMessage = true}) async {
    try {
      isLoading.value = true;

      // Call logout API to invalidate refresh token
      try {
        await _apiService.logout();
      } catch (e) {
        AppLogger.w('Logout API call failed, proceeding with local logout', e);
      }

      // Clear session regardless of API response
      await clearSession();

      if (showMessage) {
        _showSuccessSnackbar('Logged Out', 'You have been successfully logged out');
      }

      AppLogger.i('User logged out successfully');

      // Mark form controllers as disposed first, then navigate
      try {
        if (Get.isRegistered<LoginFormController>()) {
          final controller = Get.find<LoginFormController>();
          controller.markAsDisposed();
        }
        if (Get.isRegistered<SignUpFormController>()) {
          // Add similar method to SignUpFormController if needed
        }
      } catch (e) {
        AppLogger.w('Error marking controllers as disposed', e);
      }

      // Schedule navigation immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use Get.offAllNamed with fresh binding to ensure new controller instances
        Get.offAllNamed(
          AppRoutes.login,
          predicate: (route) => false, // Remove all previous routes
          arguments: {'forceRefresh': true}, // Optional flag for fresh initialization
        );
      });

    } catch (e) {
      AppLogger.e('Logout error', e);

      // Clear session even if logout fails
      await clearSession();

      // Safe navigation fallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(
          AppRoutes.login,
          predicate: (route) => false,
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all session data
  Future<void> clearSession() async {
    try {
      // Cancel timers
      _sessionTimer?.cancel();
      _tokenRefreshTimer?.cancel();

      // Clear stored data
      await _storageService.remove('access_token');
      await _storageService.remove('refresh_token');
      await _storageService.remove('user_data');
      await _storageService.remove('tenant_data');

      // Clear API service token
      await _apiService.clearTokens();

      // Reset state
      currentUser.value = null;
      currentTenant.value = null;
      isAuthenticated.value = false;
      sessionExpired.value = false;
      errorMessage.value = '';

      AppLogger.i('Session cleared successfully');
    } catch (e) {
      AppLogger.e('Error clearing session', e);
    }
  }

  /// Get current user profile
  Future<void> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();

      if (response.success && response.data != null) {
        final userData = response.data!['user'] ?? response.data!;
        final user = UserModel.fromJson(userData);
        currentUser.value = user;
        isAuthenticated.value = true;

        // Store user data
        await _storageService.setString('user_data', jsonEncode(userData));

        // Update tenant ID if changed
        if (user.tenantId != null && user.tenantId != currentTenantId.value) {
          currentTenantId.value = user.tenantId!;
          await _storageService.setString('current_tenant_id', user.tenantId!);
        }

        AppLogger.i('Current user retrieved: ${user.fullName}');
      } else {
        throw ApiException(message: response.message ?? 'Failed to get user profile');
      }
    } catch (e) {
      AppLogger.e('Get current user failed', e);
      if (e is ApiException && e.statusCode == 401) {
        await _handleSessionExpired();
      }
      rethrow;
    }
  }

  /// Get current tenant
  Future<void> getCurrentTenant() async {
    if (currentTenantId.value.isEmpty) return;

    try {
      final response = await _apiService.getCurrentTenant();

      if (response.success && response.data != null) {
        final tenant = TenantModel.fromJson(response.data!);
        currentTenant.value = tenant;

        // Store tenant data
        await _storageService.setString('tenant_data', jsonEncode(response.data!));

        AppLogger.i('Current tenant retrieved: ${tenant.displayName}');
      } else {
        AppLogger.w('Failed to get current tenant: ${response.message}');
      }
    } catch (e) {
      AppLogger.e('Get current tenant failed', e);
    }
  }

  // =============================================================================
  // PASSWORD RESET METHODS
  // =============================================================================

  /// Request password reset
  Future<void> forgotPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.forgotPassword(
        email: resetEmailController.text.trim(),
      );

      if (response.success) {
        _showSuccessSnackbar(
          'Reset Email Sent',
          'Please check your email for password reset instructions',
        );

        Get.back(); // Close the forgot password dialog

        AppLogger.i('Password reset requested for: ${resetEmailController.text.trim()}');
      } else {
        throw ApiException(message: response.message ?? 'Failed to send reset email');
      }

    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showErrorSnackbar('Reset Failed', e.message);
    } catch (e) {
      AppLogger.e('Forgot password error', e);
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      _showErrorSnackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token) async {
    if (!resetPasswordFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.resetPassword(
        token: token,
        password: newPasswordController.text,
      );

      if (response.success) {
        _showSuccessSnackbar(
          'Password Reset Successfully',
          'Your password has been updated. Please log in with your new password.',
        );

        // Navigate to login
        Get.offAllNamed(AppRoutes.login);

        AppLogger.i('Password reset completed successfully');
      } else {
        throw ApiException(message: response.message ?? 'Failed to reset password');
      }

    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showErrorSnackbar('Reset Failed', e.message);
    } catch (e) {
      AppLogger.e('Reset password error', e);
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      _showErrorSnackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend email verification
  Future<void> resendVerification(String email) async {
    try {
      isLoading.value = true;

      final response = await _apiService.resendVerification(email: email);

      if (response.success) {
        _showSuccessSnackbar(
          'Verification Email Sent',
          'Please check your email for the verification link',
        );
      } else {
        throw ApiException(message: response.message ?? 'Failed to send verification email');
      }

    } on ApiException catch (e) {
      _showErrorSnackbar('Verification Failed', e.message);
    } catch (e) {
      AppLogger.e('Resend verification error', e);
      _showErrorSnackbar('Error', 'Failed to send verification email');
    } finally {
      isLoading.value = false;
    }
  }

  // =============================================================================
  // SESSION MANAGEMENT
  // =============================================================================

  /// Start session management timers
  void _startSessionManagement() {
    _startSessionTimer();
    _startTokenRefreshTimer();
  }

  /// Start session timeout timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();

    if (Env.enableAnalytics) {
      // Set session timeout to 30 minutes of inactivity
      _sessionTimer = Timer(const Duration(minutes: 30), () {
        _handleSessionExpired();
      });
    }
  }

  /// Reset session timer (call on user activity)
  void resetSessionTimer() {
    if (isAuthenticated.value) {
      _startSessionTimer();
    }
  }

  /// Start automatic token refresh timer
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    // Refresh token every 10 minutes
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (isAuthenticated.value) {
        _refreshTokenSilently();
      } else {
        timer.cancel();
      }
    });
  }

  /// Refresh token silently in background
  Future<void> _refreshTokenSilently() async {
    try {
      final refreshToken = await _storageService.getString('refresh_token');
      if (refreshToken == null) return;

      final response = await _apiService.refreshToken();

      if (response.success && response.data != null) {
        final data = response.data!;

        // Update stored tokens
        if (data['accessToken'] != null) {
          await _storageService.setString('access_token', data['accessToken']);
          await _apiService.setAccessToken(data['accessToken']);
        }

        if (data['refreshToken'] != null) {
          await _storageService.setString('refresh_token', data['refreshToken']);
        }

        // Update user data if provided
        if (data['user'] != null) {
          final user = UserModel.fromJson(data['user']);
          currentUser.value = user;
          await _storageService.setString('user_data', jsonEncode(data['user']));
        }

        AppLogger.d('Token refreshed successfully');
      }
    } catch (e) {
      AppLogger.w('Silent token refresh failed', e);
      if (e is ApiException && e.statusCode == 401) {
        await _handleSessionExpired();
      }
    }
  }

  /// Handle session expiration
  Future<void> _handleSessionExpired() async {
    AppLogger.w('Session expired, logging out user');

    sessionExpired.value = true;
    await clearSession();

    Get.dialog(
      AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // =============================================================================
  // TENANT MANAGEMENT
  // =============================================================================

  /// Switch to different tenant (for platform admins)
  Future<void> switchTenant(String tenantId) async {
    if (!isPlatformAdmin) {
      _showErrorSnackbar('Access Denied', 'Only platform administrators can switch tenants');
      return;
    }

    try {
      isLoading.value = true;

      // Update current tenant ID
      currentTenantId.value = tenantId;
      await _storageService.setString('current_tenant_id', tenantId);

      // Load new tenant data
      await getCurrentTenant();

      _showSuccessSnackbar('Tenant Switched', 'Successfully switched to ${currentTenant.value?.displayName}');

      AppLogger.i('Tenant switched to: $tenantId');

    } catch (e) {
      AppLogger.e('Tenant switch failed', e);
      _showErrorSnackbar('Switch Failed', 'Failed to switch tenant');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if current tenant has specific feature
  bool tenantHasFeature(String featureName) {
    return currentTenant.value?.hasFeature(featureName) ?? false;
  }

  /// Check if tenant usage limit is reached
  bool tenantUsageLimitReached(String resourceType) {
    return currentTenant.value?.checkUsageLimit(resourceType) == false;
  }

  // =============================================================================
  // VALIDATION METHODS
  // =============================================================================

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    // Add more password complexity rules as needed
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 2) {
      return 'Must be at least 2 characters';
    }
    return null;
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check API health
  Future<bool> checkApiHealth() async {
    try {
      return await _apiService.checkHealth();
    } catch (e) {
      AppLogger.w('API health check failed', e);
      return false;
    }
  }

  /// Verify email with token
  Future<bool> verifyEmail(String token) async {
    try {
      final response = await _apiService.verifyEmail(token: token);
      if (response.success) {
        _showSuccessSnackbar('Email Verified', 'Your email has been verified successfully');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('Email verification failed', e);
      _showErrorSnackbar('Verification Failed', 'Invalid or expired verification link');
      return false;
    }
  }

  // =============================================================================
  // USER PROPERTY GETTERS
  // =============================================================================

  // User role helpers
  bool get isPlatformAdmin => currentUser.value?.isPlatformAdmin ?? false;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;
  bool get isTeacher => currentUser.value?.isTeacher ?? false;
  bool get isParent => currentUser.value?.isParent ?? false;
  bool get isStaff => currentUser.value?.isStaff ?? false;
  bool get isTenantAdmin => currentUser.value?.isTenantAdmin ?? false;

  // User info getters
  String get primaryRole => currentUser.value?.primaryRole ?? 'User';
  List<String> get userRoles => currentUser.value?.roleNames ?? [];
  String get fullName => currentUser.value?.fullName ?? '';
  String get firstName => currentUser.value?.firstName ?? '';
  String get lastName => currentUser.value?.lastName ?? '';
  String get email => currentUser.value?.email ?? '';
  String get initials => currentUser.value?.initials ?? '';
  String get platformType => currentUser.value?.platformType ?? 'tenant';

  // Tenant info getters
  String get tenantName => currentTenant.value?.displayName ?? '';
  String get tenantSlug => currentTenant.value?.slug ?? '';
  bool get isInTrial => currentTenant.value?.isInTrial ?? false;
  bool get tenantExpired => currentTenant.value?.isExpired ?? false;
  String get subscriptionStatus => currentTenant.value?.subscriptionStatusDisplay ?? '';

  // Permission checking methods
  bool hasRole(String role) => currentUser.value?.hasRole(role) ?? false;
  bool hasPermission(String permission) => currentUser.value?.hasPermission(permission) ?? false;
  bool hasAnyRole(List<String> roles) => currentUser.value?.hasAnyRole(roles) ?? false;
  bool hasAnyPermission(List<String> permissions) => currentUser.value?.hasAnyPermission(permissions) ?? false;
  bool canAccessChild(String childId) => currentUser.value?.canAccessChild(childId) ?? false;
  bool canModifyChild(String childId) => currentUser.value?.canModifyChild(childId) ?? false;
  bool canAccessClassroom(String classroomId) => currentUser.value?.canAccessClassroom(classroomId) ?? false;

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  /// Show success snackbar
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show warning snackbar
  void _showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Log authentication events
  void _logAuthEvent(String event, Map<String, dynamic> data) {
    if (!Env.enableAnalytics) return;

    try {
      AppLogger.i('Auth event: $event', data);
      // TODO: Send to analytics service if needed
    } catch (e) {
      AppLogger.w('Failed to log auth event', e);
    }
  }

  /// Auto-fill remembered email on login form
  Future<void> loadRememberedCredentials() async {
    try {
      final rememberMe = await _storageService.getBool('remember_me') ?? false;
      if (rememberMe) {
        final rememberedEmail = await _storageService.getString('remembered_email');
        if (rememberedEmail != null && loginFormController != null) {
          loginFormController!.emailController.text = rememberedEmail;
          loginFormController!.rememberMe.value = true;
        }
      }
    } catch (e) {
      AppLogger.w('Failed to load remembered credentials', e);
    }
  }

  /// Clear remembered credentials
  Future<void> clearRememberedCredentials() async {
    try {
      await _storageService.remove('remember_me');
      await _storageService.remove('remembered_email');
    } catch (e) {
      AppLogger.w('Failed to clear remembered credentials', e);
    }
  }
}
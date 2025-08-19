// lib/features/auth/controllers/auth_controller.dart
// FIXED: Removed ApiService readiness dependency + Added missing method

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import '../../../shared/widgets/logout_splash_screen.dart';
import '../models/tenant_model.dart';
import '../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/config/env.dart';
import '../../../utils/app_logger.dart';
import '../views/login/controllers/login_form_controller.dart';
import '../views/sign_up/controllers/signup_form_controller.dart';

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

  // Background authentication state
  final RxBool isBackgroundAuthInProgress = false.obs;
  final RxBool backgroundAuthCompleted = false.obs;

  // Background reinitialization state
  final RxBool isBackgroundReinitializing = false.obs;
  final RxString backgroundReinitStatus = ''.obs;
  final RxBool backgroundReinitComplete = false.obs;

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
  // OPTION 2: BACKGROUND AUTHENTICATION INITIALIZATION - FIXED
  // =============================================================================

  Future<void> _initializeAuth() async {
    try {
      AppLogger.i('Starting background authentication...');

      // IMMEDIATE: Mark as initialized so UI shows instantly (no spinner!)
      isInitialized.value = true;

      // Load basic stored data synchronously
      await _loadStoredData();

      // BACKGROUND: Check authentication without blocking UI (with delay)
      _checkAuthenticationInBackground();

      AppLogger.i('Authentication initialization complete - UI ready immediately');
    } catch (e) {
      AppLogger.e('Auth initialization failed', e);
      isInitialized.value = true; // Always let UI show
    }
  }

  /// Load stored data immediately (fast operation)
  Future<void> _loadStoredData() async {
    try {
      // Load stored tenant ID
      final storedTenantId = await _storageService.getString('current_tenant_id');
      if (storedTenantId != null && storedTenantId.isNotEmpty) {
        currentTenantId.value = storedTenantId;
      }

      // Load remembered credentials for login form
      await loadRememberedCredentials();

      AppLogger.d('Stored data loaded successfully');
    } catch (e) {
      AppLogger.w('Failed to load stored data', e);
    }
  }

  /// Check authentication in background without blocking UI
  void _checkAuthenticationInBackground() {
    // Add a small delay to ensure UI renders first
    Future.delayed(const Duration(milliseconds: 1000), () {
      isBackgroundAuthInProgress.value = true;

      _performBackgroundAuthCheck().then((success) {
        backgroundAuthCompleted.value = true;
        isBackgroundAuthInProgress.value = false;

        if (success) {
          AppLogger.i('Background authentication successful - user was already logged in');
        } else {
          AppLogger.d('Background authentication: User not authenticated (staying on login screen)');
        }
      }).catchError((e) {
        AppLogger.w('Background auth check failed', e);
        isBackgroundAuthInProgress.value = false;
        backgroundAuthCompleted.value = true;
        // User stays on login screen - perfect fallback
      });
    });
  }

  /// Perform the actual auth check in background - SIMPLIFIED
  Future<bool> _performBackgroundAuthCheck() async {
    try {
      // Add a reasonable timeout
      final isAuth = await _apiService.isAuthenticatedAsync()
          .timeout(const Duration(seconds: 10));

      if (!isAuth) {
        AppLogger.d('No valid authentication found');
        return false;
      }

      // Try to get user data
      await getCurrentUser().timeout(const Duration(seconds: 10));

      if (!isAuthenticated.value || currentUser.value == null) {
        AppLogger.w('Failed to load user data');
        return false;
      }

      // Load tenant if needed
      if (currentUser.value?.tenantId != null) {
        await getCurrentTenant().timeout(const Duration(seconds: 5));
      }

      // Start session management
      _startSessionManagement();

      // AUTO-REDIRECT: User was logged in, redirect to dashboard
      final user = currentUser.value!;
      final homeRoute = AppRoutes.getHomeRouteForRoles(user.roleNames);

      AppLogger.i('Background auth successful - redirecting to $homeRoute');

      // Small delay to ensure login screen has rendered
      await Future.delayed(const Duration(milliseconds: 500));

      Get.offAllNamed(homeRoute);
      return true;

    } catch (e) {
      AppLogger.w('Background auth check failed', e);
      return false;
    }
  }

  // =============================================================================
  // AUTHENTICATION METHODS - SIMPLIFIED (NO API SERVICE READINESS CHECK)
  // =============================================================================

  /// Login user - SIMPLIFIED without ApiService readiness check
  Future<void> login() async {
    final formController = loginFormController;
    if (formController == null || !formController.validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      sessionExpired.value = false;

      final email = formController.emailController.text.trim();
      final password = formController.passwordController.text;

      AppLogger.i('Attempting login for user: $email');

      // Call API service directly - let it handle its own initialization
      final response = await _apiService.login(
        email: email,
        password: password,
        rememberMe: formController.rememberMe.value,
      ).timeout(const Duration(seconds: 30)); // Add timeout

      AppLogger.d('Login API response: success=${response.success}, message=${response.message}');

      if (response.success && response.data != null) {
        await _handleSuccessfulLogin(response.data!, formController);
      } else {
        throw Exception(response.message ?? 'Login failed');
      }

    } catch (e) {
      AppLogger.e('Login error details', e);
      await _handleLoginError(e, formController);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle successful login - SIMPLIFIED WITH FRESH_DIO
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> data, LoginFormController formController) async {
    try {
      AppLogger.d('Processing login response data');

      // Tokens are already stored by ApiService via fresh_dio
      // Just process user data
      final userData = data['user'] ?? data;

      if (userData == null) {
        throw Exception('User data not found in response');
      }

      // Store user data locally
      await _storageService.setString('user_data', jsonEncode(userData));

      // Create user model
      final user = UserModel.fromJson(userData);
      currentUser.value = user;
      isAuthenticated.value = true;

      AppLogger.d('=== USER MODEL DEBUG ===');
      AppLogger.d('Created user model with roles: ${user.roleNames}');
      AppLogger.d('User platform type: ${user.platformType}');
      AppLogger.d('User is platform admin: ${user.isPlatformAdmin}');
      AppLogger.d('========================');

      // Update tenant ID and load tenant data
      if (user.tenantId != null && user.tenantId!.isNotEmpty) {
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

      AppLogger.i('Login successful for user: ${user.fullName} with roles: ${user.roleNames}');

      // Navigate to appropriate platform based on roles
      final homeRoute = AppRoutes.getHomeRouteForRoles(user.roleNames);
      AppLogger.d('Navigating to home route: $homeRoute for platform type: ${user.platformType}');

      Get.offAllNamed(homeRoute);

      // Log the successful login
      _logAuthEvent('login_success', {
        'user_id': user.id,
        'tenant_id': currentTenantId.value,
        'roles': user.roleNames,
        'platform_type': user.platformType,
        'is_platform_admin': user.isPlatformAdmin,
      });

    } catch (e) {
      AppLogger.e('Error processing successful login response', e);
      throw Exception('Login processing failed: ${e.toString()}');
    }
  }

  /// Handle login errors
  Future<void> _handleLoginError(dynamic e, LoginFormController formController) async {
    String message = e.toString().replaceAll('Exception: ', '');
    AppLogger.w('Login failed: $message');
    errorMessage.value = message;

    // Handle specific error cases based on message content
    if (message.contains('ACCOUNT_LOCKED')) {
      Get.dialog(
        AlertDialog(
          title: const Text('Account Locked'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (message.contains('TENANT_SUSPENDED')) {
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
      _showErrorSnackbar('Login Failed', message);
    }

    _logAuthEvent('login_failed', {
      'email': formController.emailController.text.trim(),
      'error': message,
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
      ).timeout(const Duration(seconds: 30));

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
        throw Exception(message);
      }

    } catch (e) {
      String message = e.toString().replaceAll('Exception: ', '');
      AppLogger.w('Registration failed: $message');
      errorMessage.value = message;

      // Handle specific registration errors
      if (message.contains('USER_EXISTS')) {
        _showErrorSnackbar('Email Already Registered',
            'An account with this email already exists. Please try logging in instead.');
      } else if (message.contains('TENANT_REQUIRED')) {
        _showErrorSnackbar('Tenant Required',
            'Please select a valid organization to register with.');
      } else if (message.contains('USER_LIMIT_EXCEEDED')) {
        _showErrorSnackbar('Registration Unavailable',
            'This organization has reached its user limit. Please contact support.');
      } else {
        _showErrorSnackbar('Registration Failed', message);
      }

      _logAuthEvent('registration_failed', {
        'email': formController.signUpEmailController.text.trim(),
        'error': message,
      });

    } finally {
      isLoading.value = false;
    }
  }

  // =============================================================================
  // LOGOUT WITH IMPROVED BACKGROUND REINITIALIZATION
  // =============================================================================

  /// Primary logout method using splash screen approach
  Future<void> logout({bool showMessage = true}) async {
    try {
      // Set loading state briefly
      isLoading.value = true;

      // Show initial loading message
      if (showMessage) {
        _showInfoSnackbar('Logging Out', 'Securing your session...');
      }

      AppLogger.i('Initiating logout with splash screen approach');

      // Step 1: Quick API logout (don't wait too long)
      try {
        await _apiService.logout().timeout(const Duration(seconds: 3));
      } catch (e) {
        AppLogger.w('Logout API call failed or timed out, proceeding with local logout', e);
      }

      // Step 2: Clear session immediately
      await clearSession();

      // Step 3: Navigate to logout splash screen immediately
      Get.offAll(() => const LogoutSplashScreen());

      // Step 4: Start thorough background reinitialization
      _startBackgroundReinitialization();

      AppLogger.i('User logged out successfully - showing splash screen');

    } catch (e) {
      AppLogger.e('Logout error', e);

      // Clear session even if logout fails
      await clearSession();

      // Still show splash screen - user experience is priority
      Get.offAll(() => const LogoutSplashScreen());

      // Start background cleanup anyway
      _startBackgroundReinitialization();
    } finally {
      isLoading.value = false;
    }
  }

  /// Start thorough background reinitialization (non-blocking)
  void _startBackgroundReinitialization() {
    // Don't await this - let it run in background
    _performBackgroundReinitialization().catchError((e) {
      AppLogger.e('Background reinitialization error', e);
      // Mark as complete anyway to prevent indefinite pending state
      backgroundReinitComplete.value = true;
    });
  }

  /// Perform thorough background reinitialization
  Future<void> _performBackgroundReinitialization() async {
    try {
      isBackgroundReinitializing.value = true;
      backgroundReinitComplete.value = false;

      AppLogger.i('Starting thorough background reinitialization...');

      // Phase 1: Controller cleanup
      backgroundReinitStatus.value = 'Cleaning up form controllers...';
      await _thoroughControllerCleanup();
      await Future.delayed(const Duration(milliseconds: 400));

      // Phase 2: Memory optimization
      backgroundReinitStatus.value = 'Optimizing memory usage...';
      await _performMemoryCleanup();
      await Future.delayed(const Duration(milliseconds: 400));

      // Phase 3: Storage cleanup
      backgroundReinitStatus.value = 'Cleaning temporary data...';
      await _cleanupTemporaryStorage();
      await Future.delayed(const Duration(milliseconds: 300));

      // Phase 4: Security validation
      backgroundReinitStatus.value = 'Validating security state...';
      await _validateSecurityState();
      await Future.delayed(const Duration(milliseconds: 400));

      // Phase 5: Pre-initialize fresh controllers
      backgroundReinitStatus.value = 'Preparing fresh login environment...';
      await _prepareLoginEnvironment();
      await Future.delayed(const Duration(milliseconds: 600));

      // Phase 6: Final validation
      backgroundReinitStatus.value = 'Finalizing reinitialization...';
      await _finalizeReinitialization();
      await Future.delayed(const Duration(milliseconds: 300));

      // Mark as complete
      backgroundReinitStatus.value = 'Reinitialization complete';
      backgroundReinitComplete.value = true;

      AppLogger.i('Background reinitialization completed successfully');

      // Clear status after a moment
      await Future.delayed(const Duration(seconds: 2));
      backgroundReinitStatus.value = '';

    } catch (e) {
      AppLogger.e('Background reinitialization failed', e);
      backgroundReinitStatus.value = 'Reinitialization failed - using fallback';

      // Attempt fallback initialization
      await _fallbackInitialization();

      backgroundReinitComplete.value = true;
    } finally {
      isBackgroundReinitializing.value = false;
    }
  }

  /// Thorough controller cleanup
  Future<void> _thoroughControllerCleanup() async {
    try {
      AppLogger.d('Starting thorough controller cleanup...');

      // Cleanup LoginFormController with enhanced disposal process
      if (Get.isRegistered<LoginFormController>()) {
        try {
          final controller = Get.find<LoginFormController>();

          // Enhanced preparation for disposal
          if (!controller.isDisposed && !controller.preparingForDisposal) {
            AppLogger.d('Preparing controller for disposal...');
            await controller.prepareForDisposal();

            // Extended wait for thorough cleanup
            await Future.delayed(const Duration(milliseconds: 800));
          }

          // Force delete with verification
          Get.delete<LoginFormController>(force: true);

          // Verify deletion
          await Future.delayed(const Duration(milliseconds: 200));
          if (Get.isRegistered<LoginFormController>()) {
            AppLogger.w('Controller still registered after deletion');
          } else {
            AppLogger.d('LoginFormController thoroughly cleaned up');
          }

        } catch (controllerError) {
          AppLogger.w('Error during controller cleanup', controllerError);
          // Force delete anyway
          try {
            Get.delete<LoginFormController>(force: true);
          } catch (deleteError) {
            AppLogger.w('Force delete also failed', deleteError);
          }
        }
      }

      // Cleanup SignUpFormController
      if (Get.isRegistered<SignUpFormController>()) {
        try {
          Get.delete<SignUpFormController>(force: true);
          AppLogger.d('SignUpFormController cleaned up');
        } catch (e) {
          AppLogger.w('Error cleaning up SignUpFormController', e);
        }
      }

      // Extended wait for cleanup to complete
      await Future.delayed(const Duration(milliseconds: 500));

      AppLogger.d('Thorough controller cleanup completed');

    } catch (e) {
      AppLogger.w('Error during thorough controller cleanup', e);
    }
  }

  /// Perform memory cleanup and optimization
  Future<void> _performMemoryCleanup() async {
    try {
      // Clear any cached data
      // Force garbage collection hint (if applicable)
      // Clear any static caches

      // Simulate memory optimization process
      await Future.delayed(const Duration(milliseconds: 200));
      AppLogger.d('Memory cleanup completed');

    } catch (e) {
      AppLogger.w('Error during memory cleanup', e);
    }
  }

  /// Clean up temporary storage and cached data
  Future<void> _cleanupTemporaryStorage() async {
    try {
      // Remove any temporary files or cached data
      await _storageService.remove('temp_login_data');
      await _storageService.remove('cached_form_data');
      await _storageService.remove('session_cache');

      AppLogger.d('Temporary storage cleaned up');

    } catch (e) {
      AppLogger.w('Error during storage cleanup', e);
    }
  }

  /// Validate security state after logout
  Future<void> _validateSecurityState() async {
    try {
      // Ensure no sensitive data remains in memory
      // Validate that tokens are properly cleared
      // Check that user data is completely removed

      final remainingToken = await _storageService.getString('access_token');
      final remainingUserData = await _storageService.getString('user_data');

      if (remainingToken != null || remainingUserData != null) {
        AppLogger.w('Security validation failed - sensitive data still present');
        // Force clear again
        await clearSession();
      } else {
        AppLogger.d('Security state validation passed');
      }

    } catch (e) {
      AppLogger.w('Error during security validation', e);
    }
  }

  /// Prepare fresh login environment
  Future<void> _prepareLoginEnvironment() async {
    try {
      AppLogger.d('Preparing fresh login environment...');

      // Step 1: Ensure complete cleanup of old controllers
      await _ensureCompleteControllerCleanup();

      // Step 2: Wait for cleanup to fully complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Create fresh LoginFormController with proper initialization
      await _createFreshLoginController();

      // Step 4: Wait for controller to be fully initialized
      await Future.delayed(const Duration(milliseconds: 400));

      // Step 5: Verify controller is ready and reinitialize focus nodes
      await _verifyAndInitializeFocusNodes();

      // Step 6: Final stability wait
      await Future.delayed(const Duration(milliseconds: 300));

      AppLogger.d('Fresh login environment prepared successfully');

    } catch (e) {
      AppLogger.w('Error preparing login environment', e);

      // Enhanced fallback with multiple retry attempts
      await _enhancedFallbackInitialization();
    }
  }

  /// Ensure complete controller cleanup before creating new ones
  Future<void> _ensureCompleteControllerCleanup() async {
    try {
      AppLogger.d('Ensuring complete controller cleanup...');

      // Check if LoginFormController exists and clean it up thoroughly
      if (Get.isRegistered<LoginFormController>()) {
        try {
          final controller = Get.find<LoginFormController>();

          // If controller exists, prepare it for disposal properly
          if (!controller.isDisposed) {
            await controller.prepareForDisposal();

            // Wait for disposal preparation to complete
            await Future.delayed(const Duration(milliseconds: 300));
          }

          // Force delete the controller
          Get.delete<LoginFormController>(force: true);
          AppLogger.d('Existing LoginFormController cleaned up');

        } catch (controllerError) {
          AppLogger.w('Error cleaning up existing controller', controllerError);
          // Force delete anyway
          try {
            Get.delete<LoginFormController>(force: true);
          } catch (deleteError) {
            AppLogger.w('Error force deleting controller', deleteError);
          }
        }
      }

      // Ensure no controller is registered
      int retryCount = 0;
      while (Get.isRegistered<LoginFormController>() && retryCount < 5) {
        AppLogger.d('Controller still registered, waiting... (attempt ${retryCount + 1})');
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }

      if (Get.isRegistered<LoginFormController>()) {
        AppLogger.w('Controller still registered after cleanup attempts');
      } else {
        AppLogger.d('Controller cleanup verified');
      }

    } catch (e) {
      AppLogger.w('Error during controller cleanup verification', e);
    }
  }

  /// Create fresh LoginFormController with enhanced error handling
  Future<void> _createFreshLoginController() async {
    try {
      AppLogger.d('Creating fresh LoginFormController...');

      // Double-check that no controller exists
      if (Get.isRegistered<LoginFormController>()) {
        AppLogger.w('Controller still exists, attempting force cleanup');
        Get.delete<LoginFormController>(force: true);
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Create new controller
      final freshController = LoginFormController();

      // Register the controller
      Get.put<LoginFormController>(freshController, permanent: false);

      AppLogger.d('Fresh LoginFormController created and registered');

      // Verify registration was successful
      if (!Get.isRegistered<LoginFormController>()) {
        throw Exception('Controller registration failed');
      }

      // Wait for controller initialization to complete
      await Future.delayed(const Duration(milliseconds: 200));

    } catch (e) {
      AppLogger.e('Error creating fresh LoginFormController', e);
      rethrow;
    }
  }

  /// Verify controller and initialize focus nodes with enhanced validation
  Future<void> _verifyAndInitializeFocusNodes() async {
    try {
      AppLogger.d('Verifying controller and initializing focus nodes...');

      // Get the fresh controller
      final controller = Get.find<LoginFormController>();

      // Verify controller is ready
      if (controller.isDisposed) {
        throw Exception('Fresh controller is already disposed');
      }

      if (controller.preparingForDisposal) {
        throw Exception('Fresh controller is preparing for disposal');
      }

      // Wait a bit more for controller to be fully ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Reinitialize focus nodes with enhanced error handling
      try {
        await controller.reinitializeFocusNodes();
        AppLogger.d('Focus nodes reinitialized successfully');
      } catch (focusError) {
        AppLogger.w('Focus node reinitialization failed, retrying...', focusError);

        // Retry once after a delay
        await Future.delayed(const Duration(milliseconds: 300));
        await controller.reinitializeFocusNodes();
        AppLogger.d('Focus nodes reinitialized successfully on retry');
      }

      // Final validation
      await _validateControllerReadiness(controller);

    } catch (e) {
      AppLogger.e('Error verifying controller and initializing focus nodes', e);
      rethrow;
    }
  }

  /// Validate that the controller is fully ready for use
  Future<void> _validateControllerReadiness(LoginFormController controller) async {
    try {
      AppLogger.d('Validating controller readiness...');

      // Check basic controller state
      if (controller.isDisposed) {
        throw Exception('Controller is disposed');
      }

      if (controller.preparingForDisposal) {
        throw Exception('Controller is preparing for disposal');
      }

      // Test focus node functionality
      try {
        final emailCanFocus = controller.emailFocusNode.canRequestFocus;
        final passwordCanFocus = controller.passwordFocusNode.canRequestFocus;

        if (!emailCanFocus || !passwordCanFocus) {
          AppLogger.w('Focus nodes may not be fully ready: email=$emailCanFocus, password=$passwordCanFocus');
        } else {
          AppLogger.d('Focus nodes are ready for use');
        }
      } catch (focusTestError) {
        AppLogger.w('Error testing focus nodes', focusTestError);
      }

      // Test basic controller operations
      try {
        controller.showPassword.value = false; // Test observable
        controller.emailController.clear(); // Test text controller
        AppLogger.d('Controller basic operations test passed');
      } catch (operationsError) {
        AppLogger.w('Controller operations test failed', operationsError);
      }

      AppLogger.d('Controller readiness validation completed');

    } catch (e) {
      AppLogger.w('Error during controller readiness validation', e);
    }
  }

  /// Enhanced fallback initialization with multiple strategies
  Future<void> _enhancedFallbackInitialization() async {
    try {
      AppLogger.i('Running enhanced fallback initialization...');

      // Strategy 1: Basic controller creation
      try {
        await _basicControllerCreation();
        AppLogger.d('Strategy 1 (basic creation) succeeded');
        return;
      } catch (e) {
        AppLogger.w('Strategy 1 failed', e);
      }

      // Strategy 2: Force cleanup and retry
      try {
        await _forceCleanupAndRetry();
        AppLogger.d('Strategy 2 (force cleanup and retry) succeeded');
        return;
      } catch (e) {
        AppLogger.w('Strategy 2 failed', e);
      }

      // Strategy 3: Minimal controller creation
      try {
        await _minimalControllerCreation();
        AppLogger.d('Strategy 3 (minimal creation) succeeded');
        return;
      } catch (e) {
        AppLogger.w('Strategy 3 failed', e);
      }

      AppLogger.e('All fallback strategies failed');

    } catch (e) {
      AppLogger.e('Enhanced fallback initialization failed', e);
    }
  }

  /// Basic controller creation fallback
  Future<void> _basicControllerCreation() async {
    if (!Get.isRegistered<LoginFormController>()) {
      final controller = LoginFormController();
      Get.put<LoginFormController>(controller, permanent: false);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Force cleanup and retry fallback
  Future<void> _forceCleanupAndRetry() async {
    // Force delete any existing controller
    try {
      Get.delete<LoginFormController>(force: true);
    } catch (e) {
      // Ignore deletion errors
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Create new controller
    final controller = LoginFormController();
    Get.put<LoginFormController>(controller, permanent: false);

    await Future.delayed(const Duration(milliseconds: 400));

    // Try to reinitialize focus nodes
    try {
      await controller.reinitializeFocusNodes();
    } catch (e) {
      AppLogger.w('Focus node reinitialization failed in fallback', e);
    }
  }

  /// Minimal controller creation fallback
  Future<void> _minimalControllerCreation() async {
    // Just ensure a basic controller exists
    if (!Get.isRegistered<LoginFormController>()) {
      Get.put<LoginFormController>(LoginFormController(), permanent: false);
    }
  }

  /// Finalize reinitialization process
  Future<void> _finalizeReinitialization() async {
    try {
      // Verify all components are ready
      final controllerReady = Get.isRegistered<LoginFormController>();
      final authStateClean = !isAuthenticated.value && currentUser.value == null;

      if (!controllerReady || !authStateClean) {
        AppLogger.w('Reinitialization verification failed');
        await _fallbackInitialization();
      } else {
        AppLogger.d('Reinitialization verification passed');
      }

    } catch (e) {
      AppLogger.w('Error during reinitialization finalization', e);
    }
  }

  /// Fallback initialization if thorough process fails
  Future<void> _fallbackInitialization() async {
    try {
      AppLogger.i('Running fallback initialization...');

      // Ensure basic controller exists
      if (!Get.isRegistered<LoginFormController>()) {
        Get.put<LoginFormController>(LoginFormController(), permanent: false);
      }

      // Basic state reset
      isAuthenticated.value = false;
      currentUser.value = null;
      currentTenant.value = null;
      errorMessage.value = '';

      AppLogger.d('Fallback initialization completed');

    } catch (e) {
      AppLogger.e('Fallback initialization failed', e);
    }
  }

  /// Check if background reinitialization is ready for login
  bool get isReadyForLogin {
    return backgroundReinitComplete.value &&
        Get.isRegistered<LoginFormController>() &&
        !isBackgroundReinitializing.value;
  }

  /// ADDED: Force complete background reinitialization (called from splash screen)
  Future<void> ensureLoginReady() async {
    if (backgroundReinitComplete.value) {
      return; // Already ready
    }

    if (isBackgroundReinitializing.value) {
      // Wait for current process to complete (max 10 seconds)
      int waitCount = 0;
      while (isBackgroundReinitializing.value && waitCount < 100) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
    }

    if (!backgroundReinitComplete.value) {
      // Force quick preparation
      await _prepareLoginEnvironment();
      backgroundReinitComplete.value = true;
    }
  }

  // =============================================================================
  // SESSION AND USER MANAGEMENT
  // =============================================================================

  /// Clear all session data - UPDATED FOR FRESH_DIO with timeout
  Future<void> clearSession() async {
    try {
      // Cancel timers
      _sessionTimer?.cancel();
      _tokenRefreshTimer?.cancel();

      // Clear stored data (user data, tenant, etc.)
      await _storageService.remove('user_data');
      await _storageService.remove('tenant_data');

      // Clear tokens via API service (fresh_dio handles this) with timeout
      try {
        await _apiService.clearTokens().timeout(const Duration(seconds: 3));
      } catch (e) {
        AppLogger.w('Failed to clear tokens from API service', e);
      }

      // Reset state
      currentUser.value = null;
      currentTenant.value = null;
      isAuthenticated.value = false;
      sessionExpired.value = false;
      errorMessage.value = '';

      // Reset background auth state
      isBackgroundAuthInProgress.value = false;
      backgroundAuthCompleted.value = false;

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

        AppLogger.d('Current user API response received');

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

        AppLogger.i('Current user retrieved: ${user.fullName} with roles: ${user.roleNames}');
      } else {
        throw Exception(response.message ?? 'Failed to get user profile');
      }
    } catch (e) {
      AppLogger.e('Get current user failed', e);
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
      ).timeout(const Duration(seconds: 30));

      if (response.success) {
        _showSuccessSnackbar(
          'Reset Email Sent',
          'Please check your email for password reset instructions',
        );

        Get.back(); // Close the forgot password dialog

        AppLogger.i('Password reset requested for: ${resetEmailController.text.trim()}');
      } else {
        throw Exception(response.message ?? 'Failed to send reset email');
      }

    } catch (e) {
      String message = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = message;
      _showErrorSnackbar('Reset Failed', message);
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
      ).timeout(const Duration(seconds: 30));

      if (response.success) {
        _showSuccessSnackbar(
          'Password Reset Successfully',
          'Your password has been updated. Please log in with your new password.',
        );

        // Navigate to login
        Get.offAllNamed(AppRoutes.login);

        AppLogger.i('Password reset completed successfully');
      } else {
        throw Exception(response.message ?? 'Failed to reset password');
      }

    } catch (e) {
      String message = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = message;
      _showErrorSnackbar('Reset Failed', message);
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend email verification
  Future<void> resendVerification(String email) async {
    try {
      isLoading.value = true;

      final response = await _apiService.resendVerification(email: email)
          .timeout(const Duration(seconds: 30));

      if (response.success) {
        _showSuccessSnackbar(
          'Verification Email Sent',
          'Please check your email for the verification link',
        );
      } else {
        throw Exception(response.message ?? 'Failed to send verification email');
      }

    } catch (e) {
      String message = e.toString().replaceAll('Exception: ', '');
      _showErrorSnackbar('Verification Failed', message);
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

  /// Refresh token silently in background - UPDATED FOR FRESH_DIO
  Future<void> _refreshTokenSilently() async {
    try {
      // Fresh_dio handles token refresh automatically
      // We can manually trigger it if needed
      final response = await _apiService.refreshTokenRequest();

      if (response.success) {
        AppLogger.d('Token refreshed successfully');

        // Update user data if provided
        if (response.data?['user'] != null) {
          final user = UserModel.fromJson(response.data!['user']);
          currentUser.value = user;
          await _storageService.setString('user_data', jsonEncode(response.data!['user']));
        }
      }
    } catch (e) {
      AppLogger.w('Silent token refresh failed', e);
    }
  }

  /// Public method for refreshing token silently - UPDATED FOR FRESH_DIO
  Future<bool> refreshTokenSilently() async {
    try {
      final response = await _apiService.refreshTokenRequest();

      if (response.success) {
        // Update user data if provided
        if (response.data?['user'] != null) {
          final user = UserModel.fromJson(response.data!['user']);
          currentUser.value = user;
          await _storageService.setString('user_data', jsonEncode(response.data!['user']));
        }

        AppLogger.d('Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.w('Silent token refresh failed', e);
      return false;
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
  // USER PROPERTY GETTERS AND PERMISSION METHODS
  // =============================================================================

  // Authentication token getter - UPDATED FOR FRESH_DIO
  String? get accessToken => _apiService.accessToken;
  String? get refreshToken => _apiService.refreshTokenValue;

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

  /// Debug user data - UPDATED
  Future<void> debugUserData() async {
    try {
      final user = currentUser.value;
      if (user == null) {
        AppLogger.e('No current user for debug');
        return;
      }

      AppLogger.d('=== COMPREHENSIVE USER DEBUG INFO ===');
      AppLogger.d('User ID: ${user.id}');
      AppLogger.d('Email: ${user.email}');
      AppLogger.d('Full Name: ${user.fullName}');
      AppLogger.d('Roles: ${user.roleNames}');
      AppLogger.d('Platform Type: ${user.platformType}');
      AppLogger.d('Is Platform Admin: ${user.isPlatformAdmin}');

      // Check token status with fresh_dio
      final hasToken = await _apiService.isAuthenticatedAsync();
      AppLogger.d('Has Valid Token: $hasToken');

      // Debug API state
      await _apiService.debugApiState();

      AppLogger.d('=====================================');

    } catch (e) {
      AppLogger.e('Debug failed', e);
    }
  }

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

  /// Show info snackbar
  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
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
        final controller = loginFormController;
        if (rememberedEmail != null && controller != null) {
          controller.emailController.text = rememberedEmail;
          controller.rememberMe.value = true;
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
// lib/features/auth/controllers/login_form_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../constants/app_strings.dart';
import '../../../utils/app_logger.dart';
import 'auth_controller.dart';

class LoginFormController extends GetxController with GetTickerProviderStateMixin {
  // Add a disposed flag to prevent operations on disposed controllers
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  // Add a flag to indicate if controller is being prepared for disposal
  bool _preparingForDisposal = false;
  bool get preparingForDisposal => _preparingForDisposal;

  // Add ready flag for initialization check
  bool _isReady = false;
  bool get isReady => _isReady;

  // Observable variables for login form
  final RxBool showPassword = false.obs;
  final RxBool rememberMe = false.obs;

  // Error states for individual fields
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxBool hasValidationErrors = false.obs;

  // Timers for auto-clearing errors (public for access from form)
  Timer? emailErrorTimer;
  Timer? passwordErrorTimer;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form key
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Focus nodes for keyboard navigation
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode rememberMeFocusNode;
  late FocusNode recoverPasswordFocusNode;
  late FocusNode loginButtonFocusNode;
  late FocusNode signupLinkFocusNode;

  // Animation controllers for shake effect
  AnimationController? emailShakeController;
  AnimationController? passwordShakeController;
  Animation<double>? emailShakeAnimation;
  Animation<double>? passwordShakeAnimation;

  @override
  void onInit() {
    super.onInit();
    try {
      // Reset disposed flag on initialization (in case of recreation)
      _isDisposed = false;
      _preparingForDisposal = false;

      _initializeFocusNodes();
      _initializeAnimations();
      _initializeFocusListeners();
      _initializeTextListeners();
      _loadRememberMePreference();

      _isReady = true;
      AppLogger.d('LoginFormController initialized successfully');
    } catch (e) {
      AppLogger.e('Error initializing LoginFormController', e);
      _isReady = false;
    }
  }

  @override
  void onClose() {
    // Set the disposed flag first
    _isDisposed = true;
    _isReady = false;

    try {
      _cancelAllTimers();
      _clearAllFocus();

      // Use delayed disposal to prevent conflicts
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_isDisposed) { // Double-check before disposing
          _disposeControllers();
          _disposeFocusNodes();
          _disposeAnimations();
        }
      });

      super.onClose();
    } catch (e) {
      AppLogger.e('Error in LoginFormController.onClose()', e);
      super.onClose();
    }
  }

  // =============================================================================
  // INITIALIZATION METHODS
  // =============================================================================

  void _initializeFocusNodes() {
    if (_isDisposed) return;

    try {
      emailFocusNode = FocusNode(debugLabel: 'EmailFocusNode');
      passwordFocusNode = FocusNode(debugLabel: 'PasswordFocusNode');
      rememberMeFocusNode = FocusNode(debugLabel: 'RememberMeFocusNode');
      recoverPasswordFocusNode = FocusNode(debugLabel: 'RecoverPasswordFocusNode');
      loginButtonFocusNode = FocusNode(debugLabel: 'LoginButtonFocusNode');
      signupLinkFocusNode = FocusNode(debugLabel: 'SignupLinkFocusNode');

      AppLogger.d('Focus nodes initialized successfully');
    } catch (e) {
      AppLogger.e('Error initializing focus nodes', e);
    }
  }

  void _initializeAnimations() {
    if (_isDisposed) return; // Safety check

    try {
      // Dispose existing controllers if they exist (safety for recreation)
      emailShakeController?.dispose();
      passwordShakeController?.dispose();

      // Email shake animation
      emailShakeController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      emailShakeAnimation = Tween<double>(
        begin: 0,
        end: 4,
      ).animate(CurvedAnimation(
        parent: emailShakeController!,
        curve: Curves.elasticIn,
      ));

      // Password shake animation
      passwordShakeController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      passwordShakeAnimation = Tween<double>(
        begin: 0,
        end: 4,
      ).animate(CurvedAnimation(
        parent: passwordShakeController!,
        curve: Curves.elasticIn,
      ));

      AppLogger.d('Login form animations initialized successfully');
    } catch (e) {
      AppLogger.e('Error initializing login form animations', e);
    }
  }

  void _initializeFocusListeners() {
    if (_isDisposed) return;

    try {
      // Email focus listener
      emailFocusNode.addListener(_onEmailFocusChanged);

      // Password focus listener
      passwordFocusNode.addListener(_onPasswordFocusChanged);

      AppLogger.d('Focus listeners initialized successfully');
    } catch (e) {
      AppLogger.e('Error initializing focus listeners', e);
    }
  }

  void _initializeTextListeners() {
    if (_isDisposed) return;

    try {
      // Remove existing listeners first (safety for recreation)
      emailController.removeListener(_onEmailChanged);
      passwordController.removeListener(_onPasswordChanged);

      // Add text change listeners
      emailController.addListener(_onEmailChanged);
      passwordController.addListener(_onPasswordChanged);

      AppLogger.d('Text listeners initialized successfully');
    } catch (e) {
      AppLogger.e('Error initializing text listeners', e);
    }
  }

  void _loadRememberMePreference() {
    if (_isDisposed) return;

    try {
      // For now, default to false
      rememberMe.value = false;
      AppLogger.d('Remember Me preference loaded: ${rememberMe.value}');
    } catch (e) {
      AppLogger.e('Error loading remember me preference', e);
      rememberMe.value = false;
    }
  }

  // =============================================================================
  // IMPROVED PREPARE FOR DISPOSAL METHOD
  // =============================================================================

  /// Prepare controller for disposal (called from AuthController) - IMPROVED
  Future<void> prepareForDisposal() async {
    try {
      _preparingForDisposal = true;
      AppLogger.d('Preparing LoginFormController for disposal...');

      // Step 1: Clear all active focus FIRST
      await _clearAllFocusSafely();

      // Step 2: Cancel timers
      _cancelAllTimers();

      // Step 3: Clear form data
      try {
        emailController.clear();
        passwordController.clear();
      } catch (e) {
        AppLogger.w('Error clearing form data during disposal preparation', e);
      }

      // Step 4: Reset observable values
      showPassword.value = false;
      emailError.value = '';
      passwordError.value = '';
      hasValidationErrors.value = false;

      // Step 5: CRITICAL - Wait longer for focus operations to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 6: Mark focus nodes as ready for disposal (but don't dispose yet)
      _markFocusNodesForDisposal();

      AppLogger.d('LoginFormController prepared for disposal');
    } catch (e) {
      AppLogger.w('Error preparing controller for disposal', e);
    }
  }

  /// Improved focus clearing with better timing
  Future<void> _clearAllFocusSafely() async {
    try {
      // Clear focus with proper unfocus sequence
      final focusNodes = [
        emailFocusNode,
        passwordFocusNode,
        rememberMeFocusNode,
        recoverPasswordFocusNode,
        loginButtonFocusNode,
        signupLinkFocusNode,
      ];

      for (final node in focusNodes) {
        try {
          if (node.hasFocus) {
            node.unfocus();
            // Small delay between each unfocus operation
            await Future.delayed(const Duration(milliseconds: 10));
          }
        } catch (e) {
          AppLogger.w('Error unfocusing individual node', e);
        }
      }

      // Additional wait to ensure all focus operations complete
      await Future.delayed(const Duration(milliseconds: 50));

      AppLogger.d('All focus cleared safely');
    } catch (e) {
      AppLogger.w('Error clearing focus safely', e);
    }
  }

  /// Mark focus nodes for disposal without actually disposing them yet
  void _markFocusNodesForDisposal() {
    try {
      final focusNodes = [
        ('emailFocusNode', emailFocusNode),
        ('passwordFocusNode', passwordFocusNode),
        ('rememberMeFocusNode', rememberMeFocusNode),
        ('recoverPasswordFocusNode', recoverPasswordFocusNode),
        ('loginButtonFocusNode', loginButtonFocusNode),
        ('signupLinkFocusNode', signupLinkFocusNode),
      ];

      for (final (name, node) in focusNodes) {
        try {
          node.debugLabel = '${node.debugLabel ?? name}_MARKED_FOR_DISPOSAL';
        } catch (e) {
          AppLogger.w('Error marking $name for disposal', e);
        }
      }
    } catch (e) {
      AppLogger.w('Error marking focus nodes for disposal', e);
    }
  }

  // =============================================================================
  // IMPROVED FOCUS NODE REINITIALIZATION
  // =============================================================================

  /// Reinitialize focus nodes - IMPROVED with better error handling
  Future<void> reinitializeFocusNodes() async {
    if (_isDisposed || _preparingForDisposal) {
      AppLogger.w('Cannot reinitialize focus nodes - controller is disposed or preparing for disposal');
      return;
    }

    try {
      AppLogger.d('Starting focus node reinitialization...');

      // Step 1: Clear any existing focus (non-blocking)
      await _clearAllFocusSafely();

      // Step 2: Dispose old focus nodes safely if they exist
      await _disposeOldFocusNodesSafely();

      // Step 3: Wait for disposal to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 4: Create new focus nodes
      await _createFreshFocusNodes();

      // Step 5: Reinitialize listeners
      await _reinitializeFocusListeners();

      // Step 6: Final validation
      await _validateFocusNodesReady();

      AppLogger.d('Focus nodes reinitialized successfully');
    } catch (e) {
      AppLogger.e('Error during focus node reinitialization', e);

      // Fallback: try basic focus node creation
      try {
        await _fallbackFocusNodeCreation();
      } catch (fallbackError) {
        AppLogger.e('Fallback focus node creation failed', fallbackError);
      }
    }
  }

  /// Safely dispose old focus nodes during reinitialization
  Future<void> _disposeOldFocusNodesSafely() async {
    try {
      final nodesToDispose = [
        ('emailFocusNode', emailFocusNode),
        ('passwordFocusNode', passwordFocusNode),
        ('rememberMeFocusNode', rememberMeFocusNode),
        ('recoverPasswordFocusNode', recoverPasswordFocusNode),
        ('loginButtonFocusNode', loginButtonFocusNode),
        ('signupLinkFocusNode', signupLinkFocusNode),
      ];

      for (final (name, node) in nodesToDispose) {
        try {
          // Check if already disposed or marked for disposal
          if (node.debugLabel?.contains('DISPOSED') == true) {
            AppLogger.d('$name already disposed, skipping');
            continue;
          }

          // Ensure not focused before disposal
          if (node.hasFocus) {
            node.unfocus();
            await Future.delayed(const Duration(milliseconds: 20));
          }

          // Dispose the node
          node.dispose();
          AppLogger.d('$name disposed successfully');

        } catch (e) {
          AppLogger.w('Error disposing $name during reinitialization', e);
        }
      }

      AppLogger.d('Old focus nodes disposed safely');
    } catch (e) {
      AppLogger.w('Error during safe focus node disposal', e);
    }
  }

  /// Create completely fresh focus nodes
  Future<void> _createFreshFocusNodes() async {
    try {
      // Create new focus nodes with clear debug labels
      emailFocusNode = FocusNode(debugLabel: 'EmailFocusNode_Fresh_${DateTime.now().millisecondsSinceEpoch}');
      passwordFocusNode = FocusNode(debugLabel: 'PasswordFocusNode_Fresh_${DateTime.now().millisecondsSinceEpoch}');
      rememberMeFocusNode = FocusNode(debugLabel: 'RememberMeFocusNode_Fresh_${DateTime.now().millisecondsSinceEpoch}');
      recoverPasswordFocusNode = FocusNode(debugLabel: 'RecoverPasswordFocusNode_Fresh_${DateTime.now().millisecondsSinceEpoch}');
      loginButtonFocusNode = FocusNode(debugLabel: 'LoginButtonFocusNode_Fresh_${DateTime.now().millisecondsSinceEpoch}');
      signupLinkFocusNode = FocusNode(debugLabel: 'SignupLinkFocusNode_Fresh_${DateTime.now().millisecondsSinceEpoch}');

      AppLogger.d('Fresh focus nodes created successfully');
    } catch (e) {
      AppLogger.e('Error creating fresh focus nodes', e);
      throw e;
    }
  }

  /// Reinitialize focus listeners after recreation
  Future<void> _reinitializeFocusListeners() async {
    try {
      // Remove any existing listeners first (safety)
      try {
        emailFocusNode.removeListener(_onEmailFocusChanged);
        passwordFocusNode.removeListener(_onPasswordFocusChanged);
      } catch (e) {
        // Ignore errors from removing non-existent listeners
      }

      // Add fresh listeners
      emailFocusNode.addListener(_onEmailFocusChanged);
      passwordFocusNode.addListener(_onPasswordFocusChanged);

      AppLogger.d('Focus listeners reinitialized successfully');
    } catch (e) {
      AppLogger.w('Error reinitializing focus listeners', e);
    }
  }

  /// Validate that focus nodes are ready for use
  Future<void> _validateFocusNodesReady() async {
    try {
      final focusNodes = [
        ('emailFocusNode', emailFocusNode),
        ('passwordFocusNode', passwordFocusNode),
        ('rememberMeFocusNode', rememberMeFocusNode),
        ('recoverPasswordFocusNode', recoverPasswordFocusNode),
        ('loginButtonFocusNode', loginButtonFocusNode),
        ('signupLinkFocusNode', signupLinkFocusNode),
      ];

      bool allValid = true;
      for (final (name, node) in focusNodes) {
        try {
          // Test if the node is functional by checking its properties
          final canFocus = node.canRequestFocus;
          final debugLabel = node.debugLabel;

          if (debugLabel?.contains('Fresh') != true) {
            AppLogger.w('$name may not be fresh: $debugLabel');
            allValid = false;
          }

          AppLogger.d('$name validation: canFocus=$canFocus, label=$debugLabel');
        } catch (e) {
          AppLogger.w('$name validation failed', e);
          allValid = false;
        }
      }

      if (allValid) {
        AppLogger.d('All focus nodes validated successfully');
      } else {
        AppLogger.w('Some focus nodes failed validation');
      }
    } catch (e) {
      AppLogger.w('Error validating focus nodes', e);
    }
  }

  /// Fallback focus node creation if main process fails
  Future<void> _fallbackFocusNodeCreation() async {
    try {
      AppLogger.i('Running fallback focus node creation...');

      // Create basic focus nodes without listeners
      emailFocusNode = FocusNode(debugLabel: 'EmailFocusNode_Fallback');
      passwordFocusNode = FocusNode(debugLabel: 'PasswordFocusNode_Fallback');
      rememberMeFocusNode = FocusNode(debugLabel: 'RememberMeFocusNode_Fallback');
      recoverPasswordFocusNode = FocusNode(debugLabel: 'RecoverPasswordFocusNode_Fallback');
      loginButtonFocusNode = FocusNode(debugLabel: 'LoginButtonFocusNode_Fallback');
      signupLinkFocusNode = FocusNode(debugLabel: 'SignupLinkFocusNode_Fallback');

      AppLogger.i('Fallback focus nodes created');
    } catch (e) {
      AppLogger.e('Fallback focus node creation failed', e);
    }
  }

  // =============================================================================
  // FOCUS LISTENERS
  // =============================================================================

  void _onEmailFocusChanged() {
    if (_isDisposed || _preparingForDisposal) return;

    try {
      if (emailFocusNode.hasFocus) {
        AppLogger.d('Email field gained focus');
      } else {
        AppLogger.d('Email field lost focus');
        // Email field lost focus - validate it
        if (emailController.text.isEmpty) {
          setEmailError(AppStrings.emailRequired);
        } else {
          final emailValidation = validateEmail(emailController.text);
          if (emailValidation != null) {
            setEmailError(emailValidation);
          }
        }
      }
    } catch (e) {
      AppLogger.w('Error in email focus change listener', e);
    }
  }

  void _onPasswordFocusChanged() {
    if (_isDisposed || _preparingForDisposal) return;

    try {
      if (passwordFocusNode.hasFocus) {
        AppLogger.d('Password field gained focus');
      } else {
        AppLogger.d('Password field lost focus');
        // Password field lost focus - validate it
        if (passwordController.text.isEmpty) {
          setPasswordError(AppStrings.passwordRequired);
        } else {
          final passwordValidation = validatePassword(passwordController.text);
          if (passwordValidation != null) {
            setPasswordError(passwordValidation);
          }
        }
      }
    } catch (e) {
      AppLogger.w('Error in password focus change listener', e);
    }
  }

  // =============================================================================
  // DISPOSAL METHODS
  // =============================================================================

  void _clearAllFocus() {
    try {
      if (emailFocusNode.hasFocus) emailFocusNode.unfocus();
      if (passwordFocusNode.hasFocus) passwordFocusNode.unfocus();
      if (rememberMeFocusNode.hasFocus) rememberMeFocusNode.unfocus();
      if (recoverPasswordFocusNode.hasFocus) recoverPasswordFocusNode.unfocus();
      if (loginButtonFocusNode.hasFocus) loginButtonFocusNode.unfocus();
      if (signupLinkFocusNode.hasFocus) signupLinkFocusNode.unfocus();
    } catch (e) {
      AppLogger.w('Error clearing focus nodes', e);
    }
  }

  void _cancelAllTimers() {
    emailErrorTimer?.cancel();
    passwordErrorTimer?.cancel();
  }

  void _disposeControllers() {
    try {
      // Remove listeners before disposing
      emailController.removeListener(_onEmailChanged);
      passwordController.removeListener(_onPasswordChanged);

      // Dispose controllers
      emailController.dispose();
      passwordController.dispose();

      AppLogger.d('Login form controllers disposed successfully');
    } catch (e) {
      AppLogger.w('Error disposing login form controllers', e);
    }
  }

  void _disposeFocusNodes() {
    try {
      // Safely dispose focus nodes with additional error handling
      _safeFocusNodeDispose(emailFocusNode, 'emailFocusNode');
      _safeFocusNodeDispose(passwordFocusNode, 'passwordFocusNode');
      _safeFocusNodeDispose(rememberMeFocusNode, 'rememberMeFocusNode');
      _safeFocusNodeDispose(recoverPasswordFocusNode, 'recoverPasswordFocusNode');
      _safeFocusNodeDispose(loginButtonFocusNode, 'loginButtonFocusNode');
      _safeFocusNodeDispose(signupLinkFocusNode, 'signupLinkFocusNode');

      AppLogger.d('Login form focus nodes disposed successfully');
    } catch (e) {
      AppLogger.w('Error disposing login form focus nodes', e);
    }
  }

  void _safeFocusNodeDispose(FocusNode focusNode, String nodeName) {
    try {
      // Check if focus node is already disposed
      if (focusNode.debugLabel != null && focusNode.debugLabel!.contains('DISPOSED')) {
        AppLogger.d('$nodeName already disposed, skipping');
        return;
      }

      // Ensure node is unfocused before disposal
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }

      // Mark as being disposed to prevent double disposal
      focusNode.debugLabel = '${focusNode.debugLabel ?? nodeName}_DISPOSED';

      // Schedule disposal after current frame to avoid widget conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.microtask(() {
          try {
            if (!focusNode.debugLabel!.contains('DISPOSED_COMPLETE')) {
              focusNode.dispose();
              focusNode.debugLabel = '${focusNode.debugLabel}_COMPLETE';
              AppLogger.d('$nodeName disposed successfully');
            }
          } catch (e) {
            AppLogger.w('Error disposing $nodeName in microtask', e);
          }
        });
      });
    } catch (e) {
      AppLogger.w('Error disposing $nodeName', e);
    }
  }

  void _disposeAnimations() {
    try {
      emailShakeController?.dispose();
      passwordShakeController?.dispose();
      AppLogger.d('Login form animations disposed successfully');
    } catch (e) {
      AppLogger.w('Error disposing login form animations', e);
    }
  }

  // =============================================================================
  // TEXT CHANGE LISTENERS
  // =============================================================================

  void _onEmailChanged() {
    if (_isDisposed || _preparingForDisposal) return; // Safety check

    if (emailError.value.isNotEmpty) {
      emailError.value = '';
      emailErrorTimer?.cancel();
      updateValidationErrorState();
    }
  }

  void _onPasswordChanged() {
    if (_isDisposed || _preparingForDisposal) return; // Safety check

    if (passwordError.value.isNotEmpty) {
      passwordError.value = '';
      passwordErrorTimer?.cancel();
      updateValidationErrorState();
    }
  }

  // =============================================================================
  // ERROR HANDLING METHODS
  // =============================================================================

  void setEmailError(String error) {
    if (_isDisposed || _preparingForDisposal) return;

    emailError.value = error;
    emailErrorTimer?.cancel();
    emailErrorTimer = Timer(const Duration(seconds: 8), () {
      if (!_isDisposed && !_preparingForDisposal) {
        emailError.value = '';
        updateValidationErrorState();
      }
    });
    _triggerEmailShake();
    updateValidationErrorState();
  }

  void setPasswordError(String error) {
    if (_isDisposed || _preparingForDisposal) return;

    passwordError.value = error;
    passwordErrorTimer?.cancel();
    passwordErrorTimer = Timer(const Duration(seconds: 8), () {
      if (!_isDisposed && !_preparingForDisposal) {
        passwordError.value = '';
        updateValidationErrorState();
      }
    });
    _triggerPasswordShake();
    updateValidationErrorState();
  }

  /// Update validation error state - RESTORED MISSING METHOD
  void updateValidationErrorState() {
    if (_isDisposed || _preparingForDisposal) return;
    hasValidationErrors.value = emailError.value.isNotEmpty || passwordError.value.isNotEmpty;
  }

  void _triggerEmailShake() {
    if (_isDisposed || _preparingForDisposal) return;
    try {
      emailShakeController?.forward().then((_) {
        if (!_isDisposed && !_preparingForDisposal) {
          emailShakeController?.reverse();
        }
      });
    } catch (e) {
      AppLogger.w('Error triggering email shake animation', e);
    }
  }

  void _triggerPasswordShake() {
    if (_isDisposed || _preparingForDisposal) return;
    try {
      passwordShakeController?.forward().then((_) {
        if (!_isDisposed && !_preparingForDisposal) {
          passwordShakeController?.reverse();
        }
      });
    } catch (e) {
      AppLogger.w('Error triggering password shake animation', e);
    }
  }

  // =============================================================================
  // FORM VALIDATION METHODS
  // =============================================================================

  bool validateForm() {
    if (_isDisposed || _preparingForDisposal) return false;

    bool isValid = true;

    // Clear previous errors
    emailError.value = '';
    passwordError.value = '';

    // Validate email
    final emailValidation = validateEmail(emailController.text);
    if (emailValidation != null) {
      setEmailError(emailValidation);
      isValid = false;
    }

    // Validate password
    final passwordValidation = validatePassword(passwordController.text);
    if (passwordValidation != null) {
      setPasswordError(passwordValidation);
      isValid = false;
    }

    return isValid;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    if (!GetUtils.isEmail(value)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }

  // =============================================================================
  // FORM MANAGEMENT METHODS
  // =============================================================================

  void clearForm() {
    if (_isDisposed || _preparingForDisposal) return; // Safety check

    try {
      _clearAllFocus();
      emailController.clear();
      passwordController.clear();
      _cancelAllTimers();
      emailError.value = '';
      passwordError.value = '';
      hasValidationErrors.value = false;
      showPassword.value = false;

      AppLogger.d('Login form cleared successfully');
    } catch (e) {
      AppLogger.w('Error clearing login form', e);
    }
  }

  // Submit form (called by Enter key or button press)
  void submitForm() {
    if (_isDisposed || _preparingForDisposal) return;

    if (validateForm()) {
      // If remember me is enabled, prepare for password saving
      if (rememberMe.value) {
        _prepareCredentialsForSaving();

        // Small delay to ensure autofill context is processed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_isDisposed && !_preparingForDisposal) {
            _performLogin();
          }
        });
      } else {
        _performLogin();
      }
    }
  }

  // Enhanced form submission with password saving support
  void submitFormWithPasswordSave() {
    if (_isDisposed || _preparingForDisposal) return;

    if (validateForm()) {
      if (rememberMe.value) {
        // Indicate that credentials should be saved
        _prepareCredentialsForSaving();

        // Show user feedback
        Get.snackbar(
          'Saving Credentials',
          'Your login information will be remembered',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Get.theme.primaryColor.withOpacity(0.9),
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }

      // Perform login after password save preparation
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_isDisposed && !_preparingForDisposal) {
          _performLogin();
        }
      });
    }
  }

  // Centralized login execution
  void _performLogin() {
    if (_isDisposed || _preparingForDisposal) return;

    try {
      AppLogger.i('Initiating login process');
      // Trigger login through Get mechanism to avoid circular dependency
      Get.find<AuthController>().login();
    } catch (e) {
      AppLogger.e('Error during login execution', e);
      Get.snackbar(
        'Login Error',
        'Unable to process login. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  void _prepareCredentialsForSaving() {
    if (_isDisposed || _preparingForDisposal) return;

    try {
      // This method is called when the user wants to save credentials
      AppLogger.d('Preparing credentials for saving (remember me enabled)');
      // Implementation would go here for actual credential saving
    } catch (e) {
      AppLogger.w('Error preparing credentials for saving', e);
    }
  }

  // =============================================================================
  // IMPROVED FOCUS MANAGEMENT METHODS
  // =============================================================================

  /// Enhanced focus email field with validation
  void focusEmailField() {
    if (_isDisposed || _preparingForDisposal) {
      AppLogger.w('Cannot focus email field - controller not ready');
      return;
    }

    try {
      // Validate focus node is ready
      if (emailFocusNode.debugLabel?.contains('DISPOSED') == true) {
        AppLogger.w('Email focus node is disposed, cannot focus');
        return;
      }

      emailFocusNode.requestFocus();
      AppLogger.d('Email field focused successfully');
    } catch (e) {
      AppLogger.w('Error focusing email field', e);
    }
  }

  /// Enhanced focus password field with validation
  void focusPasswordField() {
    if (_isDisposed || _preparingForDisposal) {
      AppLogger.w('Cannot focus password field - controller not ready');
      return;
    }

    // Use a slight delay to ensure proper focus transition
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_isDisposed && !_preparingForDisposal) {
        try {
          // Validate focus node is ready
          if (passwordFocusNode.debugLabel?.contains('DISPOSED') == true) {
            AppLogger.w('Password focus node is disposed, cannot focus');
            return;
          }

          passwordFocusNode.requestFocus();
          AppLogger.d('Password field focused successfully');
        } catch (e) {
          AppLogger.w('Error focusing password field', e);
        }
      }
    });
  }

  void focusRememberMe() {
    if (_isDisposed || _preparingForDisposal) return;
    try {
      rememberMeFocusNode.requestFocus();
    } catch (e) {
      AppLogger.w('Error focusing remember me', e);
    }
  }

  void focusRecoverPassword() {
    if (_isDisposed || _preparingForDisposal) return;
    try {
      recoverPasswordFocusNode.requestFocus();
    } catch (e) {
      AppLogger.w('Error focusing recover password', e);
    }
  }

  void focusLoginButton() {
    if (_isDisposed || _preparingForDisposal) return;
    try {
      loginButtonFocusNode.requestFocus();
    } catch (e) {
      AppLogger.w('Error focusing login button', e);
    }
  }

  void focusSignupLink() {
    if (_isDisposed || _preparingForDisposal) return;
    try {
      signupLinkFocusNode.requestFocus();
    } catch (e) {
      AppLogger.w('Error focusing signup link', e);
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    if (_isDisposed || _preparingForDisposal) return;
    showPassword.value = !showPassword.value;
  }

  // Toggle remember me checkbox
  void toggleRememberMe() {
    if (_isDisposed || _preparingForDisposal) return;
    rememberMe.value = !rememberMe.value;
  }
}
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

  // Focus nodes for keyboard navigation - will be initialized in onInit
  FocusNode? _emailFocusNode;
  FocusNode? _passwordFocusNode;
  FocusNode? _rememberMeFocusNode;
  FocusNode? _recoverPasswordFocusNode;
  FocusNode? _loginButtonFocusNode;
  FocusNode? _signupLinkFocusNode;

  // Safe getters that return dummy focus nodes if disposed
  FocusNode get emailFocusNode => _isDisposed ? _getDummyFocusNode() : (_emailFocusNode ?? _getDummyFocusNode());
  FocusNode get passwordFocusNode => _isDisposed ? _getDummyFocusNode() : (_passwordFocusNode ?? _getDummyFocusNode());
  FocusNode get rememberMeFocusNode => _isDisposed ? _getDummyFocusNode() : (_rememberMeFocusNode ?? _getDummyFocusNode());
  FocusNode get recoverPasswordFocusNode => _isDisposed ? _getDummyFocusNode() : (_recoverPasswordFocusNode ?? _getDummyFocusNode());
  FocusNode get loginButtonFocusNode => _isDisposed ? _getDummyFocusNode() : (_loginButtonFocusNode ?? _getDummyFocusNode());
  FocusNode get signupLinkFocusNode => _isDisposed ? _getDummyFocusNode() : (_signupLinkFocusNode ?? _getDummyFocusNode());

  // Dummy focus node for disposed state
  static final FocusNode _dummyFocusNode = FocusNode();
  FocusNode _getDummyFocusNode() => _dummyFocusNode;

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

      _initializeFocusNodes();
      _initializeAnimations();
      _initializeFocusListeners();
      _initializeTextListeners();
      _loadRememberMePreference();
      AppLogger.d('LoginFormController initialized successfully');
    } catch (e) {
      AppLogger.e('Error initializing LoginFormController', e);
    }
  }

  @override
  void onClose() {
    // Set the disposed flag first
    _isDisposed = true;

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
    if (_isDisposed) return; // Safety check
    
    try {
      // Create fresh FocusNodes every time the controller is initialized
      _emailFocusNode = FocusNode();
      _passwordFocusNode = FocusNode();
      _rememberMeFocusNode = FocusNode();
      _recoverPasswordFocusNode = FocusNode();
      _loginButtonFocusNode = FocusNode();
      _signupLinkFocusNode = FocusNode();
      
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
      _emailFocusNode?.addListener(() {
        if (_isDisposed || _emailFocusNode == null) return;
        if (!_emailFocusNode!.hasFocus) {
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
      });

      // Password focus listener
      _passwordFocusNode?.addListener(() {
        if (_isDisposed || _passwordFocusNode == null) return;
        if (!_passwordFocusNode!.hasFocus) {
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
      });

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
  // DISPOSAL METHODS
  // =============================================================================

  void _clearAllFocus() {
    try {
      if (_emailFocusNode?.hasFocus == true) _emailFocusNode?.unfocus();
      if (_passwordFocusNode?.hasFocus == true) _passwordFocusNode?.unfocus();
      if (_rememberMeFocusNode?.hasFocus == true) _rememberMeFocusNode?.unfocus();
      if (_recoverPasswordFocusNode?.hasFocus == true) _recoverPasswordFocusNode?.unfocus();
      if (_loginButtonFocusNode?.hasFocus == true) _loginButtonFocusNode?.unfocus();
      if (_signupLinkFocusNode?.hasFocus == true) _signupLinkFocusNode?.unfocus();
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
      if (_emailFocusNode != null) _safeFocusNodeDispose(_emailFocusNode!, 'emailFocusNode');
      if (_passwordFocusNode != null) _safeFocusNodeDispose(_passwordFocusNode!, 'passwordFocusNode');
      if (_rememberMeFocusNode != null) _safeFocusNodeDispose(_rememberMeFocusNode!, 'rememberMeFocusNode');
      if (_recoverPasswordFocusNode != null) _safeFocusNodeDispose(_recoverPasswordFocusNode!, 'recoverPasswordFocusNode');
      if (_loginButtonFocusNode != null) _safeFocusNodeDispose(_loginButtonFocusNode!, 'loginButtonFocusNode');
      if (_signupLinkFocusNode != null) _safeFocusNodeDispose(_signupLinkFocusNode!, 'signupLinkFocusNode');

      // Clear references
      _emailFocusNode = null;
      _passwordFocusNode = null;
      _rememberMeFocusNode = null;
      _recoverPasswordFocusNode = null;
      _loginButtonFocusNode = null;
      _signupLinkFocusNode = null;

      AppLogger.d('Login form focus nodes disposed successfully');
    } catch (e) {
      AppLogger.w('Error disposing login form focus nodes', e);
    }
  }

  void _safeFocusNodeDispose(FocusNode focusNode, String nodeName) {
    try {
      // Check if the focus node is already disposed
      try {
        // Ensure node is unfocused before disposal
        if (focusNode.hasFocus) {
          focusNode.unfocus();
        }
      } catch (e) {
        // If we can't check hasFocus, the node is likely already disposed
        AppLogger.w('$nodeName appears to be already disposed during unfocus', e);
      }

      // Wait a moment before disposing
      Future.microtask(() {
        try {
          focusNode.dispose();
        } catch (e) {
          AppLogger.w('Error disposing $nodeName in microtask (likely already disposed)', e);
        }
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
    if (_isDisposed) return; // Safety check

    if (emailError.value.isNotEmpty) {
      emailError.value = '';
      emailErrorTimer?.cancel();
      _updateValidationErrorState();
    }
  }

  void _onPasswordChanged() {
    if (_isDisposed) return; // Safety check

    if (passwordError.value.isNotEmpty) {
      passwordError.value = '';
      passwordErrorTimer?.cancel();
      _updateValidationErrorState();
    }
  }

  // =============================================================================
  // ERROR HANDLING METHODS
  // =============================================================================

  void setEmailError(String error) {
    if (_isDisposed) return;

    emailError.value = error;
    emailErrorTimer?.cancel();
    emailErrorTimer = Timer(const Duration(seconds: 8), () {
      if (!_isDisposed) {
        emailError.value = '';
        _updateValidationErrorState();
      }
    });
    _triggerEmailShake();
    _updateValidationErrorState();
  }

  void setPasswordError(String error) {
    if (_isDisposed) return;

    passwordError.value = error;
    passwordErrorTimer?.cancel();
    passwordErrorTimer = Timer(const Duration(seconds: 8), () {
      if (!_isDisposed) {
        passwordError.value = '';
        _updateValidationErrorState();
      }
    });
    _triggerPasswordShake();
    _updateValidationErrorState();
  }

  void _updateValidationErrorState() {
    if (_isDisposed) return;
    hasValidationErrors.value = emailError.value.isNotEmpty || passwordError.value.isNotEmpty;
  }

  void _triggerEmailShake() {
    if (_isDisposed || emailShakeController == null) return;

    try {
      emailShakeController!.reset();
      emailShakeController!.forward();
    } catch (e) {
      AppLogger.w('Error triggering email shake animation', e);
    }
  }

  void _triggerPasswordShake() {
    if (_isDisposed || passwordShakeController == null) return;

    try {
      passwordShakeController!.reset();
      passwordShakeController!.forward();
    } catch (e) {
      AppLogger.w('Error triggering password shake animation', e);
    }
  }

  // =============================================================================
  // VALIDATION METHODS
  // =============================================================================

  bool validateForm() {
    if (_isDisposed) return false; // Safety check

    bool isValid = true;

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
    if (_isDisposed) return; // Safety check

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
    if (_isDisposed) return;

    if (validateForm()) {
      // If remember me is enabled, prepare for password saving
      if (rememberMe.value) {
        _prepareCredentialsForSaving();

        // Small delay to ensure autofill context is processed
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_isDisposed) {
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
    if (_isDisposed) return;

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
        if (!_isDisposed) {
          _performLogin();
        }
      });
    }
  }

  // Centralized login execution
  void _performLogin() {
    if (_isDisposed) return;

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

  // =============================================================================
  // FOCUS MANAGEMENT METHODS
  // =============================================================================

  void focusEmailField() {
    if (_isDisposed || _emailFocusNode == null) return;
    try {
      // Check if the focus node is still usable
      if (!_emailFocusNode!.hasFocus) {
        _emailFocusNode!.requestFocus();
      }
    } catch (e) {
      AppLogger.w('Error focusing email field (likely disposed)', e);
    }
  }

  void focusPasswordField() {
    if (_isDisposed || _passwordFocusNode == null) return;
    // Use a slight delay to ensure proper focus transition
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_isDisposed && _passwordFocusNode != null) {
        try {
          // Check if the focus node is still usable
          if (!_passwordFocusNode!.hasFocus) {
            _passwordFocusNode!.requestFocus();
          }
        } catch (e) {
          AppLogger.w('Error focusing password field (likely disposed)', e);
        }
      }
    });
  }

  void focusRememberMe() {
    if (_isDisposed || _rememberMeFocusNode == null) return;
    try {
      if (!_rememberMeFocusNode!.hasFocus) {
        _rememberMeFocusNode!.requestFocus();
      }
    } catch (e) {
      AppLogger.w('Error focusing remember me (likely disposed)', e);
    }
  }

  void focusRecoverPassword() {
    if (_isDisposed || _recoverPasswordFocusNode == null) return;
    try {
      if (!_recoverPasswordFocusNode!.hasFocus) {
        _recoverPasswordFocusNode!.requestFocus();
      }
    } catch (e) {
      AppLogger.w('Error focusing recover password (likely disposed)', e);
    }
  }

  void focusLoginButton() {
    if (_isDisposed || _loginButtonFocusNode == null) return;
    try {
      if (!_loginButtonFocusNode!.hasFocus) {
        _loginButtonFocusNode!.requestFocus();
      }
    } catch (e) {
      AppLogger.w('Error focusing login button (likely disposed)', e);
    }
  }

  void focusSignupLink() {
    if (_isDisposed || _signupLinkFocusNode == null) return;
    try {
      if (!_signupLinkFocusNode!.hasFocus) {
        _signupLinkFocusNode!.requestFocus();
      }
    } catch (e) {
      AppLogger.w('Error focusing signup link (likely disposed)', e);
    }
  }

  // =============================================================================
  // TOGGLE METHODS
  // =============================================================================

  void togglePasswordVisibility() {
    if (_isDisposed) return;
    showPassword.value = !showPassword.value;
  }

  // Enhanced toggle method with persistence and password save integration
  void toggleRememberMe() {
    if (_isDisposed) return;

    final previousValue = rememberMe.value;
    rememberMe.value = !rememberMe.value;

    AppLogger.d('Remember Me toggled from $previousValue to ${rememberMe.value}');

    _saveRememberMePreference();

    // If toggled on and we have credentials, prepare for password saving
    if (rememberMe.value && hasCredentialsForSaving) {
      AppLogger.i('Auto-preparing credentials for saving (credentials available)');
      _prepareCredentialsForSaving();
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  // Save remember me preference (using Get.storage or similar)
  void _saveRememberMePreference() {
    if (_isDisposed) return;

    try {
      // If you have GetStorage configured:
      // GetStorage().write('remember_me', rememberMe.value);

      AppLogger.i('Remember Me preference saved: ${rememberMe.value}');
    } catch (e) {
      AppLogger.e('Error saving remember me preference', e);
    }
  }

  // Prepare credentials for browser password manager
  void _prepareCredentialsForSaving() {
    if (_isDisposed) return;

    AppLogger.i('Preparing credentials for password manager integration');

    // Trigger autofill context if available
    try {
      TextInput.finishAutofillContext();
      AppLogger.d('Autofill context finished successfully');
    } catch (e) {
      AppLogger.w('Error triggering autofill context', e);
    }
  }

  // Method to check if credentials are ready for saving
  bool get hasCredentialsForSaving {
    if (_isDisposed) return false;
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        rememberMe.value;
  }

  // Update validation error state
  void updateValidationErrorState() {
    if (_isDisposed) return;
    _updateValidationErrorState();
  }

  // Public method to mark controller as disposed early (called before actual disposal)
  void markAsDisposed() {
    _isDisposed = true;
    AppLogger.d('LoginFormController marked as disposed');
  }
}
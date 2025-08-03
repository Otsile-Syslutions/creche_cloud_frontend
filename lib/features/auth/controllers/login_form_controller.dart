// lib/features/auth/controllers/login_form_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../constants/app_strings.dart';
import '../../../utils/app_logger.dart';
import 'auth_controller.dart';

class LoginFormController extends GetxController with GetTickerProviderStateMixin {
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
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode rememberMeFocusNode = FocusNode();
  final FocusNode recoverPasswordFocusNode = FocusNode();
  final FocusNode loginButtonFocusNode = FocusNode();
  final FocusNode signupLinkFocusNode = FocusNode();

  // Animation controllers for shake effect
  AnimationController? emailShakeController;
  AnimationController? passwordShakeController;
  Animation<double>? emailShakeAnimation;
  Animation<double>? passwordShakeAnimation;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _setupTextListeners();
    _setupFocusListeners();
    _loadRememberMePreference();
  }

  void _initializeAnimations() {
    try {
      emailShakeController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      passwordShakeController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );

      emailShakeAnimation = Tween(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: emailShakeController!, curve: Curves.elasticIn),
      );
      passwordShakeAnimation = Tween(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: passwordShakeController!, curve: Curves.elasticIn),
      );

      AppLogger.d('Login form animations initialized successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize login form animations', e);
    }
  }

  void _setupTextListeners() {
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _setupFocusListeners() {
    // Auto-focus email field when form is displayed with a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (emailFocusNode.canRequestFocus) {
          emailFocusNode.requestFocus();
        }
      });
    });

    // Add focus listeners directly to the focus nodes for reliable Tab key detection
    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
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

    passwordFocusNode.addListener(() {
      if (!passwordFocusNode.hasFocus) {
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
  }

  @override
  void onClose() {
    _cancelAllTimers();
    _disposeControllers();
    _disposeFocusNodes();
    _disposeAnimations();
    super.onClose();
  }

  void _cancelAllTimers() {
    emailErrorTimer?.cancel();
    passwordErrorTimer?.cancel();
  }

  void _disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  void _disposeFocusNodes() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    rememberMeFocusNode.dispose();
    recoverPasswordFocusNode.dispose();
    loginButtonFocusNode.dispose();
    signupLinkFocusNode.dispose();
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

  // Text change listeners - only clear errors, don't validate
  void _onEmailChanged() {
    if (emailError.value.isNotEmpty) {
      emailError.value = '';
      emailErrorTimer?.cancel();
      _updateValidationErrorState();
    }
  }

  void _onPasswordChanged() {
    if (passwordError.value.isNotEmpty) {
      passwordError.value = '';
      passwordErrorTimer?.cancel();
      _updateValidationErrorState();
    }
  }

  void _updateValidationErrorState() {
    hasValidationErrors.value = emailError.value.isNotEmpty || passwordError.value.isNotEmpty;
  }

  // Public method to update validation state (for form access)
  void updateValidationErrorState() {
    _updateValidationErrorState();
  }

  // Set error with auto-clear timer
  void setEmailError(String error) {
    emailError.value = error;
    emailErrorTimer?.cancel();
    emailErrorTimer = Timer(const Duration(seconds: 7), () {
      emailError.value = '';
      _updateValidationErrorState();
    });
    _updateValidationErrorState();
  }

  void setPasswordError(String error) {
    passwordError.value = error;
    passwordErrorTimer?.cancel();
    passwordErrorTimer = Timer(const Duration(seconds: 7), () {
      passwordError.value = '';
      _updateValidationErrorState();
    });
    _updateValidationErrorState();
  }

  // Trigger shake animation for fields
  void shakeEmailField() {
    if (emailShakeController != null && emailShakeController!.isCompleted) {
      emailShakeController!.reset();
    }
    emailShakeController?.forward().then((_) {
      emailShakeController?.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        emailShakeController?.reset();
      });
    });
  }

  void shakePasswordField() {
    if (passwordShakeController != null && passwordShakeController!.isCompleted) {
      passwordShakeController!.reset();
    }
    passwordShakeController?.forward().then((_) {
      passwordShakeController?.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        passwordShakeController?.reset();
      });
    });
  }

  // Focus management methods
  void focusEmailField() {
    emailFocusNode.requestFocus();
  }

  void focusPasswordField() {
    // Use a slight delay to ensure proper focus transition
    Future.delayed(const Duration(milliseconds: 50), () {
      passwordFocusNode.requestFocus();
    });
  }

  void focusRememberMe() {
    rememberMeFocusNode.requestFocus();
  }

  void focusRecoverPassword() {
    recoverPasswordFocusNode.requestFocus();
  }

  void focusLoginButton() {
    loginButtonFocusNode.requestFocus();
  }

  void focusSignupLink() {
    signupLinkFocusNode.requestFocus();
  }

  // Toggle methods
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  // Enhanced toggle method with persistence and password save integration
  void toggleRememberMe() {
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

  // Save remember me preference (using Get.storage or similar)
  void _saveRememberMePreference() {
    try {
      // If you have GetStorage configured:
      // GetStorage().write('remember_me', rememberMe.value);

      AppLogger.i('Remember Me preference saved: ${rememberMe.value}');
    } catch (e) {
      AppLogger.e('Error saving remember me preference', e);
    }
  }

  // Load remember me preference on init
  void _loadRememberMePreference() {
    try {
      // If you have GetStorage configured:
      // rememberMe.value = GetStorage().read('remember_me') ?? false;

      // For now, default to false
      rememberMe.value = false;
      AppLogger.d('Remember Me preference loaded: ${rememberMe.value}');
    } catch (e) {
      AppLogger.e('Error loading remember me preference', e);
      rememberMe.value = false;
    }
  }

  // Prepare credentials for browser password manager
  void _prepareCredentialsForSaving() {
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
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        rememberMe.value;
  }

  // Validation methods
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

  // Enhanced clear form method
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    _cancelAllTimers();
    emailError.value = '';
    passwordError.value = '';
    hasValidationErrors.value = false;
    showPassword.value = false;

    // Don't clear remember me preference - let it persist
    // rememberMe.value = false; // Removed this line

    // Clear focus
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    rememberMeFocusNode.unfocus();
    recoverPasswordFocusNode.unfocus();
    loginButtonFocusNode.unfocus();
    signupLinkFocusNode.unfocus();
  }

  // Submit form (called by Enter key or button press)
  void submitForm() {
    if (validateForm()) {
      // If remember me is enabled, prepare for password saving
      if (rememberMe.value) {
        _prepareCredentialsForSaving();

        // Small delay to ensure autofill context is processed
        Future.delayed(const Duration(milliseconds: 100), () {
          _performLogin();
        });
      } else {
        _performLogin();
      }
    }
  }

  // Enhanced form submission with password saving support
  void submitFormWithPasswordSave() {
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
        _performLogin();
      });
    }
  }

  // Centralized login execution
  void _performLogin() {
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
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // Updated validate form for submission - both fields shake independently
  bool validateForm() {
    _cancelAllTimers();
    emailError.value = '';
    passwordError.value = '';
    hasValidationErrors.value = false;

    bool hasErrors = false;

    final emailValidation = validateEmail(emailController.text);
    if (emailValidation != null) {
      setEmailError(emailValidation);
      shakeEmailField();
      hasErrors = true;
    }

    final passwordValidation = validatePassword(passwordController.text);
    if (passwordValidation != null) {
      setPasswordError(passwordValidation);
      shakePasswordField(); // Remove the conditional check - always shake if invalid
      hasErrors = true;
    }

    return !hasErrors;
  }

  // Method to get current form data for submission
  Map<String, dynamic> get formData {
    return {
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'rememberMe': rememberMe.value,
    };
  }

  // Method to check if form has any input
  bool get hasAnyInput {
    return emailController.text.isNotEmpty || passwordController.text.isNotEmpty;
  }

  // Method to check if form is completely filled
  bool get isFormComplete {
    return emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  }

  // Method to reset only errors without clearing form
  void resetErrors() {
    _cancelAllTimers();
    emailError.value = '';
    passwordError.value = '';
    hasValidationErrors.value = false;
  }
}
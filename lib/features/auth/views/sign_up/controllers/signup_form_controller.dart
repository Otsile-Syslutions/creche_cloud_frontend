// lib/features/auth/controllers/signup_form_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../constants/app_strings.dart';
import '../../../../../utils/app_logger.dart';

class SignUpFormController extends GetxController with GetTickerProviderStateMixin {
  // Observable variables for signup form
  final RxBool showSignUpPassword = false.obs;
  final RxBool showConfirmSignUpPassword = false.obs;
  final RxBool acceptTerms = false.obs;

  // Error states for individual fields
  final RxString firstNameError = ''.obs;
  final RxString lastNameError = ''.obs;
  final RxString signUpEmailError = ''.obs;
  final RxString signUpPasswordError = ''.obs;
  final RxString confirmSignUpPasswordError = ''.obs;
  final RxBool hasSignUpValidationErrors = false.obs;

  // Timers for auto-clearing errors
  Timer? firstNameErrorTimer;
  Timer? lastNameErrorTimer;
  Timer? signUpEmailErrorTimer;
  Timer? signUpPasswordErrorTimer;
  Timer? confirmSignUpPasswordErrorTimer;

  // Form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController = TextEditingController();
  final TextEditingController confirmSignUpPasswordController = TextEditingController();

  // Form key - No longer needed, handled directly in widget
  // late GlobalKey<FormState> signUpFormKey;

  // Animation controllers for shake effect
  AnimationController? firstNameShakeController;
  AnimationController? lastNameShakeController;
  AnimationController? signUpEmailShakeController;
  AnimationController? signUpPasswordShakeController;
  AnimationController? confirmSignUpPasswordShakeController;
  Animation<double>? firstNameShakeAnimation;
  Animation<double>? lastNameShakeAnimation;
  Animation<double>? signUpEmailShakeAnimation;
  Animation<double>? signUpPasswordShakeAnimation;
  Animation<double>? confirmSignUpPasswordShakeAnimation;

  @override
  void onInit() {
    super.onInit();

    _initializeAnimations();
    _setupTextListeners();

    AppLogger.d('SignUpFormController initialized successfully');
  }

  void _initializeAnimations() {
    try {
      firstNameShakeController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      lastNameShakeController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      signUpEmailShakeController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      signUpPasswordShakeController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      confirmSignUpPasswordShakeController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );

      firstNameShakeAnimation = Tween(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: firstNameShakeController!, curve: Curves.elasticIn),
      );
      lastNameShakeAnimation = Tween(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: lastNameShakeController!, curve: Curves.elasticIn),
      );
      signUpEmailShakeAnimation = Tween(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: signUpEmailShakeController!, curve: Curves.elasticIn),
      );
      signUpPasswordShakeAnimation = Tween(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: signUpPasswordShakeController!, curve: Curves.elasticIn),
      );
      confirmSignUpPasswordShakeAnimation = Tween(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: confirmSignUpPasswordShakeController!, curve: Curves.elasticIn),
      );
    } catch (e) {
      print('Error initializing signup animations: $e');
    }
  }

  void _setupTextListeners() {
    firstNameController.addListener(_onFirstNameChanged);
    lastNameController.addListener(_onLastNameChanged);
    signUpEmailController.addListener(_onSignUpEmailChanged);
    signUpPasswordController.addListener(_onSignUpPasswordChanged);
    confirmSignUpPasswordController.addListener(_onConfirmSignUpPasswordChanged);
  }

  @override
  void onClose() {
    _cancelAllTimers();
    _disposeControllers();
    _disposeAnimations();
    super.onClose();
  }

  void _cancelAllTimers() {
    firstNameErrorTimer?.cancel();
    lastNameErrorTimer?.cancel();
    signUpEmailErrorTimer?.cancel();
    signUpPasswordErrorTimer?.cancel();
    confirmSignUpPasswordErrorTimer?.cancel();
  }

  void _disposeControllers() {
    firstNameController.dispose();
    lastNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    confirmSignUpPasswordController.dispose();
  }

  void _disposeAnimations() {
    try {
      firstNameShakeController?.dispose();
      lastNameShakeController?.dispose();
      signUpEmailShakeController?.dispose();
      signUpPasswordShakeController?.dispose();
      confirmSignUpPasswordShakeController?.dispose();
    } catch (e) {
      print('Error disposing signup animations: $e');
    }
  }

  // Text change listeners
  void _onFirstNameChanged() {
    if (firstNameError.value.isNotEmpty) {
      firstNameError.value = '';
      firstNameErrorTimer?.cancel();
      _updateSignUpValidationErrorState();
    }
  }

  void _onLastNameChanged() {
    if (lastNameError.value.isNotEmpty) {
      lastNameError.value = '';
      lastNameErrorTimer?.cancel();
      _updateSignUpValidationErrorState();
    }
  }

  void _onSignUpEmailChanged() {
    if (signUpEmailError.value.isNotEmpty) {
      signUpEmailError.value = '';
      signUpEmailErrorTimer?.cancel();
      _updateSignUpValidationErrorState();
    }
  }

  void _onSignUpPasswordChanged() {
    if (signUpPasswordError.value.isNotEmpty) {
      signUpPasswordError.value = '';
      signUpPasswordErrorTimer?.cancel();
      _updateSignUpValidationErrorState();
    }
    // Also check confirm password if it has content
    if (confirmSignUpPasswordController.text.isNotEmpty && confirmSignUpPasswordError.value.isNotEmpty) {
      _onConfirmSignUpPasswordChanged();
    }
  }

  void _onConfirmSignUpPasswordChanged() {
    if (confirmSignUpPasswordError.value.isNotEmpty) {
      confirmSignUpPasswordError.value = '';
      confirmSignUpPasswordErrorTimer?.cancel();
      _updateSignUpValidationErrorState();
    }
  }

  void _updateSignUpValidationErrorState() {
    hasSignUpValidationErrors.value = firstNameError.value.isNotEmpty ||
        lastNameError.value.isNotEmpty ||
        signUpEmailError.value.isNotEmpty ||
        signUpPasswordError.value.isNotEmpty ||
        confirmSignUpPasswordError.value.isNotEmpty;
  }

  // Set error with auto-clear timer
  void setFirstNameError(String error) {
    firstNameError.value = error;
    firstNameErrorTimer?.cancel();
    firstNameErrorTimer = Timer(const Duration(seconds: 5), () {
      firstNameError.value = '';
      _updateSignUpValidationErrorState();
    });
    _updateSignUpValidationErrorState();
  }

  void setLastNameError(String error) {
    lastNameError.value = error;
    lastNameErrorTimer?.cancel();
    lastNameErrorTimer = Timer(const Duration(seconds: 5), () {
      lastNameError.value = '';
      _updateSignUpValidationErrorState();
    });
    _updateSignUpValidationErrorState();
  }

  void setSignUpEmailError(String error) {
    signUpEmailError.value = error;
    signUpEmailErrorTimer?.cancel();
    signUpEmailErrorTimer = Timer(const Duration(seconds: 5), () {
      signUpEmailError.value = '';
      _updateSignUpValidationErrorState();
    });
    _updateSignUpValidationErrorState();
  }

  void setSignUpPasswordError(String error) {
    signUpPasswordError.value = error;
    signUpPasswordErrorTimer?.cancel();
    signUpPasswordErrorTimer = Timer(const Duration(seconds: 5), () {
      signUpPasswordError.value = '';
      _updateSignUpValidationErrorState();
    });
    _updateSignUpValidationErrorState();
  }

  void setConfirmSignUpPasswordError(String error) {
    confirmSignUpPasswordError.value = error;
    confirmSignUpPasswordErrorTimer?.cancel();
    confirmSignUpPasswordErrorTimer = Timer(const Duration(seconds: 5), () {
      confirmSignUpPasswordError.value = '';
      _updateSignUpValidationErrorState();
    });
    _updateSignUpValidationErrorState();
  }

  // Trigger shake animation for fields
  void shakeFirstNameField() {
    if (firstNameShakeController != null && firstNameShakeController!.isCompleted) {
      firstNameShakeController!.reset();
    }
    firstNameShakeController?.forward().then((_) {
      firstNameShakeController?.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        firstNameShakeController?.reset();
      });
    });
  }

  void shakeLastNameField() {
    if (lastNameShakeController != null && lastNameShakeController!.isCompleted) {
      lastNameShakeController!.reset();
    }
    lastNameShakeController?.forward().then((_) {
      lastNameShakeController?.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        lastNameShakeController?.reset();
      });
    });
  }

  void shakeSignUpEmailField() {
    if (signUpEmailShakeController != null && signUpEmailShakeController!.isCompleted) {
      signUpEmailShakeController!.reset();
    }
    signUpEmailShakeController?.forward().then((_) {
      signUpEmailShakeController?.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        signUpEmailShakeController?.reset();
      });
    });
  }

  void shakeSignUpPasswordField() {
    if (signUpPasswordShakeController != null && signUpPasswordShakeController!.isCompleted) {
      signUpPasswordShakeController!.reset();
    }
    signUpPasswordShakeController?.forward().then((_) {
      signUpPasswordShakeController?.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        signUpPasswordShakeController?.reset();
      });
    });
  }

  void shakeConfirmSignUpPasswordField() {
    if (confirmSignUpPasswordShakeController != null && confirmSignUpPasswordShakeController!.isCompleted) {
      confirmSignUpPasswordShakeController!.reset();
    }
    confirmSignUpPasswordShakeController?.forward().then((_) {
      confirmSignUpPasswordShakeController?.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        confirmSignUpPasswordShakeController?.reset();
      });
    });
  }

  // Toggle methods
  void toggleSignUpPasswordVisibility() {
    showSignUpPassword.value = !showSignUpPassword.value;
  }

  void toggleConfirmSignUpPasswordVisibility() {
    showConfirmSignUpPassword.value = !showConfirmSignUpPassword.value;
  }

  void toggleAcceptTerms() {
    acceptTerms.value = !acceptTerms.value;
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

  String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  String? validateConfirmSignUpPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != signUpPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Clear form
  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    signUpEmailController.clear();
    signUpPasswordController.clear();
    confirmSignUpPasswordController.clear();
    _cancelAllTimers();
    firstNameError.value = '';
    lastNameError.value = '';
    signUpEmailError.value = '';
    signUpPasswordError.value = '';
    confirmSignUpPasswordError.value = '';
    hasSignUpValidationErrors.value = false;
    acceptTerms.value = false;
    showSignUpPassword.value = false;
    showConfirmSignUpPassword.value = false;
  }

  // Validate form for submission
  bool validateForm() {
    _cancelAllTimers();
    firstNameError.value = '';
    lastNameError.value = '';
    signUpEmailError.value = '';
    signUpPasswordError.value = '';
    confirmSignUpPasswordError.value = '';
    hasSignUpValidationErrors.value = false;

    bool hasErrors = false;

    final firstNameValidation = validateName(firstNameController.text, 'First name');
    if (firstNameValidation != null) {
      setFirstNameError(firstNameValidation);
      shakeFirstNameField();
      hasErrors = true;
    }

    final lastNameValidation = validateName(lastNameController.text, 'Last name');
    if (lastNameValidation != null) {
      setLastNameError(lastNameValidation);
      shakeLastNameField();
      hasErrors = true;
    }

    final emailValidation = validateEmail(signUpEmailController.text);
    if (emailValidation != null) {
      setSignUpEmailError(emailValidation);
      shakeSignUpEmailField();
      hasErrors = true;
    }

    final passwordValidation = validatePassword(signUpPasswordController.text);
    if (passwordValidation != null) {
      setSignUpPasswordError(passwordValidation);
      shakeSignUpPasswordField();
      hasErrors = true;
    }

    final confirmPasswordValidation = validateConfirmSignUpPassword(confirmSignUpPasswordController.text);
    if (confirmPasswordValidation != null) {
      setConfirmSignUpPasswordError(confirmPasswordValidation);
      shakeConfirmSignUpPasswordField();
      hasErrors = true;
    }

    if (!acceptTerms.value) {
      hasErrors = true; // Terms not accepted
    }

    return !hasErrors;
  }
}
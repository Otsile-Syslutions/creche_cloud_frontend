// lib/features/auth/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../routes/app_routes.dart';
import 'login_form_controller.dart';
import 'signup_form_controller.dart';

class AuthController extends GetxController {
  // Observable variables for authentication state
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;

  // Form controllers - accessed via getters with null safety
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

  // Password reset form controllers (keeping these simple since they're used less frequently)
  final TextEditingController resetEmailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Form keys for password reset
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  @override
  void onClose() {
    resetEmailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Check if user is authenticated
  Future<void> checkAuthStatus() async {
    try {
      // TODO: Check local storage for stored authentication
      // For now, assume user is not authenticated
      isAuthenticated.value = false;
    } catch (e) {
      // Error checking auth status
    }
  }

  // Login method
  Future<void> login() async {
    final formController = loginFormController;
    if (formController == null || !formController.validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Mock successful login
      final mockUser = UserModel(
        id: '1',
        email: formController.emailController.text,
        firstName: 'Test',
        lastName: 'User',
        roles: ['teacher'],
        permissions: ['read:children', 'write:activities'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      currentUser.value = mockUser;
      isAuthenticated.value = true;

      // Navigate to dashboard
      Get.offAllNamed(AppRoutes.dashboard);

      Get.snackbar(
        'Success',
        'Welcome back, ${mockUser.fullName}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up method
  Future<void> signUp() async {
    final formController = signUpFormController;
    if (formController == null || !formController.validateForm()) {
      if (formController != null && !formController.acceptTerms.value) {
        Get.snackbar(
          'Terms Required',
          'Please accept the Terms and Conditions to continue',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      Get.snackbar(
        'Success',
        'Account created successfully! Please check your email to verify your account.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);

    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password method
  Future<void> forgotPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      Get.snackbar(
        'Success',
        'Password reset link sent to ${resetEmailController.text}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back to login
      Get.offAllNamed(AppRoutes.login);

    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password method
  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      Get.snackbar(
        'Success',
        'Password has been reset successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);

    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // TODO: Clear local storage, make API call if needed

      currentUser.value = null;
      isAuthenticated.value = false;

      // Clear form data safely
      try {
        loginFormController?.clearForm();
        signUpFormController?.clearForm();
      } catch (e) {
        // Error clearing form data
      }

      resetEmailController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.offAllNamed(AppRoutes.login);

    } catch (e) {
      // Error during logout
    } finally {
      isLoading.value = false;
    }
  }

  // RBAC methods
  bool hasRole(String role) {
    return currentUser.value?.hasRole(role) ?? false;
  }

  bool hasPermission(String permission) {
    return currentUser.value?.hasPermission(permission) ?? false;
  }

  bool hasAnyRole(List<String> roles) {
    return currentUser.value?.hasAnyRole(roles) ?? false;
  }

  bool hasAnyPermission(List<String> permissions) {
    return currentUser.value?.hasAnyPermission(permissions) ?? false;
  }

  // Validation methods for password reset
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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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
}
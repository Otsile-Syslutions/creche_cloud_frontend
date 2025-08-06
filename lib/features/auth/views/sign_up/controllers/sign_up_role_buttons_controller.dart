// lib/features/auth/views/sign_up/controllers/sign_up_role_buttons_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../routes/app_routes.dart';

class SignUpRoleController extends GetxController with GetTickerProviderStateMixin {
  // Observable for button press animations
  final RxBool isButtonPressed = false.obs;

  // Animation controllers for individual button effects
  late AnimationController ownerButtonController;
  late AnimationController staffButtonController;
  late AnimationController parentButtonController;

  // Animations for button hover/press effects
  late Animation<double> ownerButtonScale;
  late Animation<double> staffButtonScale;
  late Animation<double> parentButtonScale;

  // Track button states
  final RxString selectedRole = ''.obs;
  final RxBool isOwnerHovered = false.obs;
  final RxBool isStaffHovered = false.obs;
  final RxBool isParentHovered = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    ownerButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    staffButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    parentButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize scale animations
    ownerButtonScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: ownerButtonController,
      curve: Curves.easeInOut,
    ));

    staffButtonScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: staffButtonController,
      curve: Curves.easeInOut,
    ));

    parentButtonScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: parentButtonController,
      curve: Curves.easeInOut,
    ));
  }

  void handleRoleSelection(String role) {
    // Set button pressed state for animation
    isButtonPressed.value = true;

    // Reset after animation
    Future.delayed(const Duration(milliseconds: 150), () {
      isButtonPressed.value = false;
    });

    // Set selected role
    selectedRole.value = role;

    // Add haptic feedback
    _addHapticFeedback();

    // Navigate based on role with slight delay for animation
    Future.delayed(const Duration(milliseconds: 100), () {
      _navigateToRoleSignup(role);
    });
  }

  void _navigateToRoleSignup(String role) {
    switch (role) {
      case 'owner':
        Get.toNamed('${AppRoutes.signup}/owner');
        break;
      case 'staff':
        Get.toNamed('${AppRoutes.signup}/staff');
        break;
      case 'parent':
        Get.toNamed('${AppRoutes.signup}/parent');
        break;
    }
  }

  void _addHapticFeedback() {
    // Add subtle haptic feedback for better UX
    // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
  }

  // Button hover animations
  void onOwnerButtonHover(bool isHovered) {
    isOwnerHovered.value = isHovered;
    if (isHovered) {
      ownerButtonController.forward();
    } else {
      ownerButtonController.reverse();
    }
  }

  void onStaffButtonHover(bool isHovered) {
    isStaffHovered.value = isHovered;
    if (isHovered) {
      staffButtonController.forward();
    } else {
      staffButtonController.reverse();
    }
  }

  void onParentButtonHover(bool isHovered) {
    isParentHovered.value = isHovered;
    if (isHovered) {
      parentButtonController.forward();
    } else {
      parentButtonController.reverse();
    }
  }

  // Get button text color based on hover state
  Color getButtonTextColor(String role) {
    switch (role) {
      case 'owner':
        return isOwnerHovered.value ? Colors.white : Colors.black87;
      case 'staff':
        return isStaffHovered.value ? Colors.white : Colors.black87;
      case 'parent':
        return isParentHovered.value ? Colors.white : Colors.black87;
      default:
        return Colors.black87;
    }
  }

  @override
  void onClose() {
    ownerButtonController.dispose();
    staffButtonController.dispose();
    parentButtonController.dispose();
    super.onClose();
  }
}
// lib/shared/components/sidebar/profile_sidebar_footer.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../features/auth/controllers/auth_controller.dart';
import '../../../../features/auth/models/tenant_model.dart';
import '../../../../features/auth/models/user_model.dart';
import 'expanded_profile_footer.dart';
import 'collapsed_profile_footer.dart';

// Main Profile Footer Widget
class ProfileSidebarFooter extends StatefulWidget {
  final bool isExpanded;
  final double expandedWidth;
  final double collapsedWidth;

  const ProfileSidebarFooter({
    super.key,
    this.isExpanded = true,
    this.expandedWidth = 250,
    this.collapsedWidth = 70,
  });

  @override
  State<ProfileSidebarFooter> createState() => _ProfileSidebarFooterState();
}

class _ProfileSidebarFooterState extends State<ProfileSidebarFooter>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // 180 degrees
    ).animate(_expandAnimation);

    // Start with menu collapsed (default state)
    _isMenuOpen = false;
    _animationController.value = 0.0;
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _animationController.forward();
      // Add overlay after a slight delay to prevent immediate close
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isMenuOpen && mounted) {
          _addOverlay();
        }
      });
    } else {
      _animationController.reverse();
      _removeOverlay();
    }
  }

  void closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
      _animationController.reverse();
      _removeOverlay();
    }
  }

  void _addOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => GestureDetector(
          onTap: closeMenu,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      );

      final overlay = Overlay.of(context);
      overlay.insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildFooterContent({
    required String userName,
    required String userRole,
    required String userInitials,
    String? userPhotoUrl,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: widget.isExpanded
          ? ExpandedProfileFooter(
        userName: userName,
        userRole: userRole,
        userInitials: userInitials,
        userPhotoUrl: userPhotoUrl,
        isMenuOpen: _isMenuOpen,
        rotationAnimation: _rotationAnimation,
        onToggleMenu: toggleMenu,
        onCloseMenu: closeMenu,
      )
          : CollapsedProfileFooter(
        userName: userName,
        userRole: userRole,
        userInitials: userInitials,
        userPhotoUrl: userPhotoUrl,
        isMenuOpen: _isMenuOpen,
        onToggleMenu: toggleMenu,
        onCloseMenu: closeMenu,
      ),
    );
  }

  Widget _buildDefaultFooter() {
    return _buildFooterContent(
      userName: 'Guest User',
      userRole: 'Not logged in',
      userInitials: 'G',
      userPhotoUrl: null,
    );
  }

  String _getUserInitials(UserModel user) {
    // Safely get initials, handling empty names
    try {
      if (user.firstName.isNotEmpty && user.lastName.isNotEmpty) {
        return user.initials; // Use the model's computed property
      } else if (user.firstName.isNotEmpty) {
        return user.firstName[0].toUpperCase();
      } else if (user.lastName.isNotEmpty) {
        return user.lastName[0].toUpperCase();
      } else if (user.email.isNotEmpty) {
        return user.email[0].toUpperCase();
      }
    } catch (e) {
      // Fallback if any error occurs
    }
    return 'U';
  }

  String _getUserRoleDisplay(UserModel user, TenantModel? tenant) {
    // Use the model's computed properties
    if (user.isPlatformAdmin) {
      return 'Platform Admin';
    }

    // Check tenant name for tenant users
    if (user.platformType == 'tenant' && tenant != null) {
      return tenant.displayName;
    }

    // Use the primaryRole getter from the model
    return user.primaryRole;
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Don't cache the controller, get it fresh each time
    // This ensures we always have the current auth state
    return GetBuilder<AuthController>(
      init: Get.isRegistered<AuthController>() ? null : AuthController(),
      builder: (authController) {
        // Use Obx for reactive updates
        return Obx(() {
          // Check if controller is properly initialized and has user data
          if (!authController.isInitialized.value) {
            return _buildDefaultFooter();
          }

          final UserModel? user = authController.currentUser.value;
          final TenantModel? tenant = authController.currentTenant.value;

          if (user == null) {
            return _buildDefaultFooter();
          }

          // Get user name and initials safely
          final userName = user.fullName.trim().isNotEmpty ? user.fullName : 'User';
          final userRole = _getUserRoleDisplay(user, tenant);
          final userInitials = _getUserInitials(user);

          return _buildFooterContent(
            userName: userName,
            userRole: userRole,
            userInitials: userInitials,
            userPhotoUrl: user.profileImage,
          );
        });
      },
    );
  }
}
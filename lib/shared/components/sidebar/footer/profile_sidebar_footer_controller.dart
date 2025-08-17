// lib/shared/components/sidebar/footer/profile_sidebar_footer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../app_sidebar_controller.dart';
import 'collapsed_profile_footer.dart';
import 'expanded_profile_footer.dart';

// Main Profile Footer Widget
class ProfileSidebarFooter extends StatefulWidget {
  final bool isExpanded;
  final double expandedWidth;
  final double collapsedWidth;
  final String? controllerTag;

  const ProfileSidebarFooter({
    super.key,
    this.isExpanded = true,
    this.expandedWidth = 250,
    this.collapsedWidth = 85,  // Updated from 70 to match new collapsed sidebar width
    this.controllerTag,
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
  AppSidebarController? _sidebarController;

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
      end: 0.5,
    ).animate(_expandAnimation);

    _isMenuOpen = false;
    _animationController.value = 0.0;

    _findSidebarController();
  }

  void _findSidebarController() {
    try {
      if (widget.controllerTag != null) {
        if (Get.isRegistered<AppSidebarController>(tag: widget.controllerTag)) {
          _sidebarController = Get.find<AppSidebarController>(tag: widget.controllerTag);
          AppLogger.d('Found AppSidebarController with tag: ${widget.controllerTag}');
        }
      }

      if (_sidebarController == null && Get.isRegistered<AppSidebarController>()) {
        _sidebarController = Get.find<AppSidebarController>();
        AppLogger.d('Found AppSidebarController without tag');
      }

      if (_sidebarController == null) {
        AppLogger.w('AppSidebarController not found, ProfileSidebarFooter will show default data');
      }
    } catch (e) {
      AppLogger.e('Error finding AppSidebarController', e);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
      _animationController.reverse();
    }
  }

  Widget _buildFooterContent({
    required String userName,
    required String userRole,
    required String userInitials,
    String? userPhotoUrl,
  }) {
    // Different heights for expanded vs collapsed modes
    final baseHeight = 80.0;  // Increased slightly for better vertical centering
    final expandedModeHeight = _isMenuOpen ? 200.0 : baseHeight;
    final collapsedModeHeight = _isMenuOpen ? 170.0 : baseHeight; // Adjusted for new layout

    // Wrap the entire footer in a TapRegion to handle outside clicks
    return TapRegion(
      onTapOutside: (_) {
        // Close menu when clicking outside
        if (_isMenuOpen) {
          closeMenu();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.isExpanded ? expandedModeHeight : collapsedModeHeight,
        width: widget.isExpanded ? widget.expandedWidth : widget.collapsedWidth,
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

  @override
  Widget build(BuildContext context) {
    if (_sidebarController == null) {
      _findSidebarController();

      if (_sidebarController == null) {
        return _buildDefaultFooter();
      }
    }

    return Obx(() {
      if (!_sidebarController!.isUserDataLoaded.value) {
        return _buildDefaultFooter();
      }

      final userName = _sidebarController!.userName.value;
      final userRole = _sidebarController!.userRole.value;
      final userInitials = _sidebarController!.userInitials.value;
      final userPhotoUrl = _sidebarController!.userPhotoUrl.value.isNotEmpty
          ? _sidebarController!.userPhotoUrl.value
          : null;

      return _buildFooterContent(
        userName: userName,
        userRole: userRole,
        userInitials: userInitials,
        userPhotoUrl: userPhotoUrl,
      );
    });
  }
}
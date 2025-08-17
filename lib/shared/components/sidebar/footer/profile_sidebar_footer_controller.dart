// lib/shared/components/sidebar/profile_sidebar_footer.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../utils/app_logger.dart';
import '../app_sidebar_controller.dart';
import 'expanded_profile_footer.dart';
import 'collapsed_profile_footer.dart';

// Main Profile Footer Widget
class ProfileSidebarFooter extends StatefulWidget {
  final bool isExpanded;
  final double expandedWidth;
  final double collapsedWidth;
  final String? controllerTag;  // Optional tag to find specific controller

  const ProfileSidebarFooter({
    super.key,
    this.isExpanded = true,
    this.expandedWidth = 250,
    this.collapsedWidth = 70,
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
  OverlayEntry? _overlayEntry;
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
      end: 0.5, // 180 degrees
    ).animate(_expandAnimation);

    // Start with menu collapsed (default state)
    _isMenuOpen = false;
    _animationController.value = 0.0;

    // Find the AppSidebarController
    _findSidebarController();
  }

  void _findSidebarController() {
    try {
      // Try to find controller with tag if provided
      if (widget.controllerTag != null) {
        if (Get.isRegistered<AppSidebarController>(tag: widget.controllerTag)) {
          _sidebarController = Get.find<AppSidebarController>(tag: widget.controllerTag);
          AppLogger.d('Found AppSidebarController with tag: ${widget.controllerTag}');
        }
      }

      // Fallback to finding controller without tag
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

  @override
  Widget build(BuildContext context) {
    // If no controller found, show default footer
    if (_sidebarController == null) {
      // Try to find controller one more time in case it was registered after initState
      _findSidebarController();

      if (_sidebarController == null) {
        return _buildDefaultFooter();
      }
    }

    // Use Obx to observe changes from the sidebar controller
    return Obx(() {
      // Check if controller has user data loaded
      if (!_sidebarController!.isUserDataLoaded.value) {
        return _buildDefaultFooter();
      }

      // Get user data from sidebar controller
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
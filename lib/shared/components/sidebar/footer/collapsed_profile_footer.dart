// lib/shared/components/sidebar/footer/collapsed_profile_footer.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../widgets/logout_splash_screen.dart';
import 'profile_footer_widgets.dart';

class CollapsedProfileFooter extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userInitials;
  final String? userPhotoUrl;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;
  final VoidCallback onCloseMenu;

  const CollapsedProfileFooter({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.userPhotoUrl,
    required this.isMenuOpen,
    required this.onToggleMenu,
    required this.onCloseMenu,
  });

  void _handleProfile() {
    print('Profile button clicked!'); // Debug
    onCloseMenu();
    // Navigate to profile page
    // Get.toNamed('/profile');
  }

  void _handleLogout() {
    print('Logout button clicked!'); // Debug
    onCloseMenu();
    Get.offAll(() => const LogoutSplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    // Remove ClipRect to allow overflow for tooltips
    return Stack(
      clipBehavior: Clip.none, // Allow tooltips to overflow
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Divider line above user info
            Container(
              height: 1,
              color: const Color(0xFFE0E0E0),
              margin: const EdgeInsets.only(bottom: 2), // Minimal margin for better vertical centering
            ),

            // Profile avatar with chevron and tooltip
            _CollapsedProfileAvatar(
              userName: userName,
              userRole: userRole,
              userInitials: userInitials,
              userPhotoUrl: userPhotoUrl,
              isMenuOpen: isMenuOpen,
              onTap: onToggleMenu,
            ),

            // Menu icons
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isMenuOpen
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CollapsedFooterItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: _handleProfile,
                    isError: false,
                  ),
                  CollapsedFooterItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: _handleLogout,
                    isError: true,
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8), // Proper bottom spacing to center the layout
          ],
        ),
      ],
    );
  }
}

// Special widget for the profile avatar with chevron
class _CollapsedProfileAvatar extends StatefulWidget {
  final String userName;
  final String userRole;
  final String userInitials;
  final String? userPhotoUrl;
  final bool isMenuOpen;
  final VoidCallback onTap;

  const _CollapsedProfileAvatar({
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.userPhotoUrl,
    required this.isMenuOpen,
    required this.onTap,
  });

  @override
  State<_CollapsedProfileAvatar> createState() => _CollapsedProfileAvatarState();
}

class _CollapsedProfileAvatarState extends State<_CollapsedProfileAvatar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6), // Better vertical centering
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Extended hover background - shows user info to the right
              if (_isHovered)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 200,
                    height: 44, // Reduced to match container height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar and chevron in tooltip
                        SizedBox(
                          width: 71,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              UserAvatar(
                                initials: widget.userInitials,
                                backgroundColor: AppColors.loginButton,
                                photoUrl: widget.userPhotoUrl,
                                radius: 13,
                              ),
                              const SizedBox(width: 2),
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: widget.isMenuOpen ? 0.5 : 0,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                  size: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // User info text
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.userRole,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Avatar with chevron container - always visible
              Container(
                width: 71, // Adjusted to fit within padded container (85 - 14 padding)
                height: 44, // Slightly reduced height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _isHovered ? Colors.transparent : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserAvatar(
                      initials: widget.userInitials,
                      backgroundColor: AppColors.loginButton,
                      photoUrl: widget.userPhotoUrl,
                      radius: 13, // Reduced slightly more
                    ),
                    const SizedBox(width: 2),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: widget.isMenuOpen ? 0.5 : 0, // Rotate when menu opens
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 12, // Smaller icon
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Collapsed footer item with tooltip (for Profile and Logout buttons)
class CollapsedFooterItem extends StatefulWidget {
  final IconData? icon;
  final Widget? customWidget;
  final String label;
  final VoidCallback? onTap;
  final bool isError;

  const CollapsedFooterItem({
    super.key,
    this.icon,
    this.customWidget,
    required this.label,
    this.onTap,
    this.isError = false,
  });

  @override
  State<CollapsedFooterItem> createState() => _CollapsedFooterItemState();
}

class _CollapsedFooterItemState extends State<CollapsedFooterItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), // Consistent padding
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Icon container - always visible as base state
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _isHovered ? Colors.transparent : Colors.transparent,
                ),
                padding: const EdgeInsets.all(11),
                child: Center(
                  child: widget.customWidget ??
                      Icon(
                        widget.icon,
                        color: widget.isError
                            ? AppColors.error
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                ),
              ),

              // Extended hover background - shows label to the right (higher z-index)
              if (_isHovered)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 220, // Extended width for better visibility
                    height: 44, // Reduced to match
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon in the tooltip
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(11),
                          child: Center(
                            child: widget.customWidget ??
                                Icon(
                                  widget.icon,
                                  color: widget.isError
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  size: 22,
                                ),
                          ),
                        ),
                        // Label text
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 12.0),
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                color: widget.isError
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
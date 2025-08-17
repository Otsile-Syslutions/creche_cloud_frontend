// lib/shared/components/sidebar/collapsed_profile_footer.dart
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
    onCloseMenu();
    // Navigate to profile page
    // Get.toNamed('/profile');
  }

  void _handleLogout() {
    onCloseMenu();
    Get.offAll(() => const LogoutSplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile avatar with tooltip
        CollapsedFooterItem(
          customWidget: UserAvatar(
            initials: userInitials,
            backgroundColor: AppColors.loginButton,
            photoUrl: userPhotoUrl,
            radius: 18,
          ),
          label: '$userName\n$userRole',
          onTap: onToggleMenu,
          isAvatar: true,
        ),

        // Menu icons
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isMenuOpen
              ? Column(
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
        const SizedBox(height: 8),
      ],
    );
  }
}

// Collapsed footer item with tooltip (same style as menu items)
class CollapsedFooterItem extends StatefulWidget {
  final IconData? icon;
  final Widget? customWidget;
  final String label;
  final VoidCallback? onTap;
  final bool isError;
  final bool isAvatar;

  const CollapsedFooterItem({
    super.key,
    this.icon,
    this.customWidget,
    required this.label,
    this.onTap,
    this.isError = false,
    this.isAvatar = false,
  });

  @override
  State<CollapsedFooterItem> createState() => _CollapsedFooterItemState();
}

class _CollapsedFooterItemState extends State<CollapsedFooterItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
              // Extended hover background - shows label to the right
              if (_isHovered)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 200,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 46),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 12.0),
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                color: widget.isError
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                                fontSize: widget.isAvatar ? 12 : 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: widget.isAvatar ? 2 : 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Icon/Avatar container
              Container(
                width: 46,
                height: 46,
                padding: EdgeInsets.all(widget.isAvatar ? 4 : 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
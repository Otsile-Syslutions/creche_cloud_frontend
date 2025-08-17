// lib/shared/components/sidebar/expanded_profile_footer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../widgets/logout_splash_screen.dart';
import 'profile_footer_widgets.dart';

class ExpandedProfileFooter extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userInitials;
  final String? userPhotoUrl;
  final bool isMenuOpen;
  final Animation<double> rotationAnimation;
  final VoidCallback onToggleMenu;
  final VoidCallback onCloseMenu;

  const ExpandedProfileFooter({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.userPhotoUrl,
    required this.isMenuOpen,
    required this.rotationAnimation,
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile section with user info
          _buildProfileSection(),

          // Animated expansion for menu items
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isMenuOpen ? 1.0 : 0.0,
              child: isMenuOpen
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),

                  // Profile button with better hover
                  _MenuItemButton(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: _handleProfile,
                    iconColor: AppColors.textSecondary,
                    textColor: AppColors.textSecondary,
                    hoverBackgroundColor: AppColors.loginButton.withOpacity(0.05),
                  ),

                  // Logout button with better hover
                  _MenuItemButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: _handleLogout,
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    hoverBackgroundColor: Colors.red.withOpacity(0.05),
                  ),

                  const SizedBox(height: 8),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('Profile section clicked - Menu is ${isMenuOpen ? 'open' : 'closed'}'); // Debug
          onToggleMenu();
        },
        borderRadius: BorderRadius.circular(0),
        hoverColor: AppColors.loginButton.withOpacity(0.03),
        splashColor: AppColors.loginButton.withOpacity(0.05),
        highlightColor: AppColors.loginButton.withOpacity(0.03),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Avatar
              UserAvatar(
                initials: userInitials,
                backgroundColor: AppColors.loginButton,
                photoUrl: userPhotoUrl,
                radius: 20,
              ),
              const SizedBox(width: 12),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userRole,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              // Animated chevron
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isMenuOpen ? 0.5 : 0, // 180 degrees when open
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate widget for menu items with better hover state management
class _MenuItemButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;
  final Color hoverBackgroundColor;

  const _MenuItemButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconColor,
    required this.textColor,
    required this.hoverBackgroundColor,
  });

  @override
  State<_MenuItemButton> createState() => _MenuItemButtonState();
}

class _MenuItemButtonState extends State<_MenuItemButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            hoverColor: widget.hoverBackgroundColor,
            splashColor: widget.hoverBackgroundColor.withOpacity(0.2),
            highlightColor: widget.hoverBackgroundColor.withOpacity(0.15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _isHovered ? widget.hoverBackgroundColor : Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AnimatedScale(
                    scale: _isHovered ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
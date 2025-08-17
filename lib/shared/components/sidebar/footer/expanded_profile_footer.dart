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
        // Profile section with user info
        _buildProfileSection(),

        // Menu items with proper hover effect
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isMenuOpen
              ? Column(
            children: [
              _buildMenuItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: _handleProfile,
                isError: false,
              ),
              _buildMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: _handleLogout,
                isError: true,
              ),
            ],
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleMenu,
        hoverColor: Colors.grey.withOpacity(0.05),
        highlightColor: Colors.grey.withOpacity(0.1),
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
              AnimatedBuilder(
                animation: rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: rotationAnimation.value * 3.14159,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isError,
  }) {
    return HoverScaleWrapper(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.loginButton.withOpacity(0.05),
          focusColor: AppColors.loginButton.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isError ? AppColors.error : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isError ? AppColors.error : AppColors.textSecondary,
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
    );
  }
}
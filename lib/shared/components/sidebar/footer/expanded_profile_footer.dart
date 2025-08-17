// lib/shared/components/sidebar/expanded_profile_footer_simple.dart


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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile section with user info
        _buildProfileSection(),

        // Menu items
        if (isMenuOpen) ...[
          const SizedBox(height: 4),

          // Profile button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _handleProfile,
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.loginButton.withOpacity(0.05),
                splashColor: AppColors.loginButton.withOpacity(0.1),
                highlightColor: AppColors.loginButton.withOpacity(0.08),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: AppColors.textSecondary,
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

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _handleLogout,
                borderRadius: BorderRadius.circular(8),
                hoverColor: Colors.red.withOpacity(0.05),
                splashColor: Colors.red.withOpacity(0.1),
                highlightColor: Colors.red.withOpacity(0.08),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: AppColors.error,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.error,
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
        ],
      ],
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
              // Simple chevron rotation
              Icon(
                isMenuOpen
                    ? Icons.keyboard_arrow_down_rounded  // Points DOWN when open
                    : Icons.keyboard_arrow_up_rounded,   // Points UP when closed
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/shared/components/topbar/app_topbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../widgets/logout_splash_screen.dart';

class AppTopbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool showUserInfo;
  final bool showLogout;
  final Color? backgroundColor;
  final double elevation;
  final Widget? leading;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final VoidCallback? onMenuPressed;
  final String? subtitle;

  const AppTopbar({
    super.key,
    required this.title,
    this.additionalActions,
    this.showUserInfo = true,
    this.showLogout = true,
    this.backgroundColor,
    this.elevation = 0,
    this.leading,
    this.centerTitle = false,
    this.titleStyle,
    this.onMenuPressed,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(),
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: elevation,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leading: leading,
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: titleStyle ??
                const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: titleStyle ??
          const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  List<Widget> _buildActions() {
    final actions = <Widget>[];

    // Add additional actions first
    if (additionalActions != null) {
      actions.addAll(additionalActions!);
    }

    // Add user info
    if (showUserInfo) {
      actions.add(_buildUserInfo());
      actions.add(const SizedBox(width: 8));
      actions.add(_buildUserAvatar());
    }

    // Add logout button
    if (showLogout) {
      actions.add(_buildLogoutButton());
    }

    // Add some end padding
    if (actions.isNotEmpty) {
      actions.add(const SizedBox(width: 8));
    }

    return actions;
  }

  Widget _buildUserInfo() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        final user = controller.currentUser.value;
        final tenant = controller.currentTenant.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getUserRoleDisplay(controller),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user?.fullName ?? 'User',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        final user = controller.currentUser.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _UserAvatar(
            initials: user?.initials ?? 'U',
            backgroundColor: AppColors.loginButton,
            photoUrl: user?.profileImage,
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      onPressed: () => Get.offAll(() => const LogoutSplashScreen()),
      icon: const Icon(
        Icons.logout,
        color: AppColors.textSecondary,
      ),
      tooltip: 'Logout',
    );
  }

  String _getUserRoleDisplay(AuthController controller) {
    final user = controller.currentUser.value;
    final tenant = controller.currentTenant.value;
    final platformType = user?.platformType;

    switch (platformType) {
      case 'admin':
        return user?.isPlatformAdmin == true ? 'Platform Admin' : 'Support';
      case 'tenant':
        return tenant?.name ?? 'School';
      case 'parent':
        return 'Parent';
      default:
        return user?.primaryRole ?? 'User';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// User Avatar Widget with image support
class _UserAvatar extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final String? photoUrl;
  final double radius;

  const _UserAvatar({
    required this.initials,
    required this.backgroundColor,
    this.photoUrl,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(photoUrl!),
        onBackgroundImageError: (_, __) {
          // Fall back to initials if image fails
        },
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
          ),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: radius,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}

// Simplified topbar for specific use cases
class SimpleAppTopbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const SimpleAppTopbar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Platform-specific topbar variants
class AdminTopbar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? additionalActions;
  final String? customTitle;

  const AdminTopbar({
    super.key,
    this.additionalActions,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppTopbar(
      title: customTitle ?? 'Platform Administration',
      additionalActions: additionalActions,
      showUserInfo: true,
      showLogout: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TenantTopbar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? additionalActions;
  final String? customTitle;

  const TenantTopbar({
    super.key,
    this.additionalActions,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppTopbar(
      title: customTitle ?? 'School Management',
      additionalActions: additionalActions,
      showUserInfo: true,
      showLogout: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ParentTopbar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? additionalActions;
  final String? customTitle;

  const ParentTopbar({
    super.key,
    this.additionalActions,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppTopbar(
      title: customTitle ?? 'Parent Portal',
      additionalActions: additionalActions,
      showUserInfo: true,
      showLogout: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
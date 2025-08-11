// lib/shared/components/sidebar/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_assets.dart';

class AppSidebar extends StatelessWidget {
  final SidebarXController controller;
  final List<SidebarXItem> items;
  final Widget? header;
  final Widget? footer;
  final double width;

  const AppSidebar({
    super.key,
    required this.controller,
    required this.items,
    this.header,
    this.footer,
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: _buildTheme(),
      extendedTheme: _buildExtendedTheme(),
      headerBuilder: header != null ? (context, extended) => header! : null,
      footerBuilder: footer != null ? (context, extended) => footer! : null,
      items: items,
    );
  }

  SidebarXTheme _buildTheme() {
    return SidebarXTheme(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface, // White background
        border: Border(
          right: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      textStyle: const TextStyle(
        color: AppColors.textSecondary, // Grey text
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedTextStyle: const TextStyle(
        color: AppColors.loginButton, // Active color #875DEC
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.loginButton.withOpacity(0.1), // Light purple background
        border: Border.all(
          color: AppColors.loginButton.withOpacity(0.2),
          width: 1,
        ),
      ),
      hoverColor: AppColors.loginButton.withOpacity(0.05),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary, // Grey icons
        size: 20,
      ),
      selectedIconTheme: const IconThemeData(
        color: AppColors.loginButton, // Active purple icons
        size: 20,
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }

  SidebarXTheme _buildExtendedTheme() {
    return SidebarXTheme(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class AppSidebarHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? customLogo;

  const AppSidebarHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.customLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          customLogo ?? Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                AppAssets.ccLogoFullColour,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.loginButton,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon ?? Icons.cloud,
                      size: 28,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class AppSidebarFooter extends StatelessWidget {
  final String statusText;
  final bool isActive;
  final IconData? statusIcon;
  final VoidCallback? onTap;

  const AppSidebarFooter({
    super.key,
    required this.statusText,
    this.isActive = true,
    this.statusIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon ?? (isActive ? Icons.check_circle : Icons.warning),
                color: isActive ? AppColors.success : AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: isActive ? AppColors.success : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/shared/components/sidebar/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_assets.dart';

class AppSidebar extends StatelessWidget {
  final SidebarXController controller;
  final List<SidebarXItem> items;
  final Widget? header;
  final Widget? footer;
  final double width;
  final double collapsedWidth;

  const AppSidebar({
    super.key,
    required this.controller,
    required this.items,
    this.header,
    this.footer,
    this.width = 250,
    this.collapsedWidth = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Sidebar
        SidebarX(
          controller: controller,
          theme: _buildTheme(),
          extendedTheme: _buildExtendedTheme(),
          headerBuilder: header != null ? (context, extended) => header! : null,
          footerBuilder: footer != null ? (context, extended) => footer! : null,
          items: items,
          showToggleButton: false, // Disable default toggle
        ),

        // Custom Toggle Button - Positioned at top-left
        Positioned(
          top: 12,
          left: 12,
          child: _buildToggleButton(),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              controller.setExtended(!controller.extended);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: controller.extended
                      ? HugeIcons.strokeRoundedMenu01
                      : HugeIcons.strokeRoundedMenu03,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  SidebarXTheme _buildTheme() {
    return SidebarXTheme(
      width: collapsedWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      textStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      selectedTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      hoverTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      itemTextPadding: const EdgeInsets.only(left: 10),
      selectedItemTextPadding: const EdgeInsets.only(left: 10),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF875DEC),
      ),
      hoverColor: AppColors.loginButton.withOpacity(0.05),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 22,
      ),
      selectedIconTheme: const IconThemeData(
        color: Colors.white,
        size: 22,
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      selectedItemMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
      itemTextPadding: const EdgeInsets.only(left: 10),
      selectedItemTextPadding: const EdgeInsets.only(left: 10),
      textStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      selectedTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      hoverTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      selectedItemMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}

class AppSidebarHeader extends StatelessWidget {
  final Widget? customLogo;
  final SidebarXController? controller;

  const AppSidebarHeader({
    super.key,
    this.customLogo,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return _buildHeaderContent(true);
    }

    return AnimatedBuilder(
      animation: controller!,
      builder: (context, child) {
        final isExtended = controller!.extended;
        return _buildHeaderContent(isExtended);
      },
    );
  }

  Widget _buildHeaderContent(bool isExtended) {
    return Container(
      padding: EdgeInsets.only(
        left: isExtended ? 12 : 10,
        right: isExtended ? 12 : 10,
        top: 20, // Reduced top padding - logo starts higher
        bottom: 16, // Reduced bottom padding
      ),
      color: AppColors.surface,
      child: customLogo ?? SizedBox(
        width: double.infinity,
        height: 150, // Fixed 150px height for logo
        child: Image.asset(
          isExtended
              ? AppAssets.ccLogoFullColour
              : AppAssets.ccLogoFullColourCollapsed,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to colored container if image fails
            return Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.loginButton,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.cloud,
                  size: isExtended ? 60 : 30,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
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
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
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
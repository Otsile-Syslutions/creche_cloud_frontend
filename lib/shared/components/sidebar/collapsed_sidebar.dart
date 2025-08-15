// lib/shared/components/sidebar/collapsed_sidebar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_assets.dart';
import 'app_sidebar_controller.dart';

class CollapsedSidebar extends StatelessWidget {
  final AppSidebarController controller;
  final List<SidebarMenuItem> items;
  final Widget? header;
  final Widget? footer;
  final double width;

  const CollapsedSidebar({
    super.key,
    required this.controller,
    required this.items,
    this.header,
    this.footer,
    this.width = 70,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final shouldScroll = controller.shouldEnableScroll(availableHeight, items.length);

        return Container(
          width: width,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              right: BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header - Fixed at top
              if (header != null) header!,

              // Menu Items - Scrollable if needed
              Expanded(
                child: shouldScroll
                    ? _buildScrollableMenu()
                    : _buildStaticMenu(),
              ),

              // Footer - Fixed at bottom
              if (footer != null) footer!,
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableMenu() {
    return Scrollbar(
      controller: controller.menuScrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: controller.menuScrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildMenuItem(index);
        },
      ),
    );
  }

  Widget _buildStaticMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: List.generate(
          items.length,
              (index) => _buildMenuItem(index),
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    final item = items[index];

    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Tooltip(
          message: item.label,
          preferBelow: false,
          verticalOffset: 0,
          waitDuration: const Duration(milliseconds: 500),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.selectMenuItem(index);
                item.onTap?.call();
              },
              borderRadius: BorderRadius.circular(8),
              hoverColor: AppColors.loginButton.withOpacity(0.05),
              focusColor: AppColors.loginButton.withOpacity(0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? const Color(0xFF875DEC)
                      : Colors.transparent,
                ),
                child: Center(
                  child: item.iconBuilder?.call(isSelected, false) ??
                      Icon(
                        item.icon ?? Icons.dashboard,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Collapsed Header Widget
class CollapsedSidebarHeader extends StatelessWidget {
  final Widget? customLogo;

  const CollapsedSidebarHeader({
    super.key,
    this.customLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 20,
        bottom: 16,
      ),
      color: AppColors.surface,
      child: customLogo ??
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Image.asset(
              AppAssets.ccLogoFullColourCollapsed,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.loginButton,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.cloud,
                      size: 30,
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

// Collapsed Footer Widget
class CollapsedSidebarFooter extends StatelessWidget {
  final bool isActive;
  final IconData? statusIcon;
  final VoidCallback? onTap;

  const CollapsedSidebarFooter({
    super.key,
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
          padding: const EdgeInsets.all(8),
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
          child: Icon(
            statusIcon ?? (isActive ? Icons.check_circle : Icons.warning),
            color: isActive ? AppColors.success : AppColors.warning,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// Sidebar Menu Item Model
class SidebarMenuItem {
  final String label;
  final IconData? icon;
  final Widget Function(bool selected, bool hovered)? iconBuilder;
  final VoidCallback? onTap;

  const SidebarMenuItem({
    required this.label,
    this.icon,
    this.iconBuilder,
    this.onTap,
  });
}
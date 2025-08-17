// lib/shared/components/sidebar/expanded_sidebar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_assets.dart';
import 'app_sidebar_controller.dart';
import 'collapsed_sidebar.dart';
import 'footer/profile_sidebar_footer_controller.dart';


// Hover wrapper widget for menu items
class _MenuItemHoverWrapper extends StatefulWidget {
  final Widget child;
  final bool isSelected;

  const _MenuItemHoverWrapper({
    required this.child,
    required this.isSelected,
  });

  @override
  State<_MenuItemHoverWrapper> createState() => _MenuItemHoverWrapperState();
}

class _MenuItemHoverWrapperState extends State<_MenuItemHoverWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.isSelected) {
          setState(() => _isHovering = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? 1.0 : _scaleAnimation.value,
            alignment: Alignment.centerLeft,
            child: widget.child,
          );
        },
      ),
    );
  }
}

// New hover effect widget that applies background at the container level
class _MenuItemHoverEffect extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItemHoverEffect({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MenuItemHoverEffect> createState() => _MenuItemHoverEffectState();
}

class _MenuItemHoverEffectState extends State<_MenuItemHoverEffect> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.isSelected) {
          setState(() => _isHovering = true);
        }
      },
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isSelected
                ? const Color(0xFF875DEC)
                : _isHovering
                ? AppColors.loginButton.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class ExpandedSidebar extends StatelessWidget {
  final AppSidebarController controller;
  final List<SidebarMenuItem> items;
  final Widget? header;
  final double width;

  const ExpandedSidebar({
    super.key,
    required this.controller,
    required this.items,
    this.header,
    this.width = 250,
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
          clipBehavior: Clip.hardEdge, // ADD THIS LINE - Clips all child content including hover effects
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
              const SizedBox(height: 20),

              // Header - Fixed at top
              if (header != null) header!,

              // Menu Items - Scrollable if needed
              Expanded(
                child: shouldScroll
                    ? _buildScrollableMenu()
                    : _buildStaticMenu(),
              ),

              // Footer - Pass the controller tag if available
              ProfileSidebarFooter(
                isExpanded: true,
                expandedWidth: width,
                collapsedWidth: 70,
                controllerTag: controller.controllerTag,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableMenu() {
    return RawScrollbar(
      controller: controller.menuScrollController,
      thumbVisibility: true,
      thickness: 6,
      radius: const Radius.circular(3),
      thumbColor: AppColors.textHint.withOpacity(0.3),
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
        child: _MenuItemHoverEffect(
          isSelected: isSelected,
          onTap: () {
            controller.selectMenuItem(index);
            item.onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _MenuItemHoverWrapper(
              isSelected: isSelected,
              child: Row(
                children: [
                  // Icon
                  item.iconBuilder?.call(isSelected, false) ??
                      Icon(
                        item.icon ?? Icons.dashboard,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                  const SizedBox(width: 10),
                  // Label with fade animation - wrapped in Flexible to prevent overflow
                  Flexible(
                    child: AnimatedBuilder(
                      animation: controller.fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: controller.fadeAnimation.value,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Expanded Header Widget
class ExpandedSidebarHeader extends StatelessWidget {
  final Widget? customLogo;

  const ExpandedSidebarHeader({
    super.key,
    this.customLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 0,  // Reduced from 20 to 0 since we have 60px space above
        bottom: 16,
      ),
      color: AppColors.surface,
      child: customLogo ??
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Image.asset(
              AppAssets.ccLogoFullColour,
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
                      size: 60,
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

// Expanded Footer Widget (keeping for backward compatibility)
class ExpandedSidebarFooter extends StatelessWidget {
  final String statusText;
  final bool isActive;
  final IconData? statusIcon;
  final VoidCallback? onTap;

  const ExpandedSidebarFooter({
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
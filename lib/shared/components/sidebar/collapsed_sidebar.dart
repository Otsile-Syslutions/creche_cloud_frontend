// lib/shared/components/sidebar/collapsed_sidebar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_assets.dart';
import 'app_sidebar_controller.dart';
import 'footer/profile_sidebar_footer_controller.dart';

class CollapsedSidebar extends StatelessWidget {
  final AppSidebarController controller;
  final List<SidebarMenuItem> items;
  final Widget? header;
  final double width;

  const CollapsedSidebar({
    super.key,
    required this.controller,
    required this.items,
    this.header,
    this.width = 85,  // Increased from 70 to accommodate chevron
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
          // Allow overflow for footer expansion
          clipBehavior: Clip.none,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              right: BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none, // Allow footer to expand outside bounds
            children: [
              // Main content column
              Column(
                children: [
                  // Add spacing from top
                  const SizedBox(height: 60),

                  // Header - Fixed at top (collapsed logo)
                  if (header != null)
                    header!
                  else
                    const CollapsedSidebarHeader(),

                  // Menu Items - Scrollable if needed
                  Expanded(
                    child: shouldScroll
                        ? _buildScrollableMenu()
                        : _buildStaticMenu(),
                  ),

                  // Reserve space for footer (collapsed height)
                  const SizedBox(height: 80), // Space for footer (matches new footer height)
                ],
              ),

              // Footer positioned at bottom with overflow allowed
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ProfileSidebarFooter(
                  isExpanded: false,
                  expandedWidth: 250,
                  collapsedWidth: width,  // Use the width property
                  controllerTag: controller.controllerTag,
                ),
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
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 16, // Extra padding to ensure menu items don't go under footer
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildMenuItem(index);
        },
      ),
    );
  }

  Widget _buildStaticMenu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 16, // Extra padding to ensure menu items don't go under footer
      ),
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

      return _CollapsedMenuItem(
        item: item,
        isSelected: isSelected,
        onTap: () {
          controller.selectMenuItem(index);
          item.onTap?.call();
        },
      );
    });
  }
}

// Individual collapsed menu item with Orqestra-style tooltip
class _CollapsedMenuItem extends StatefulWidget {
  final SidebarMenuItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CollapsedMenuItem({
    required this.item,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<_CollapsedMenuItem> createState() => _CollapsedMenuItemState();
}

class _CollapsedMenuItemState extends State<_CollapsedMenuItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          if (!widget.isSelected) {
            _animationController.forward();
          }
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _animationController.reverse();
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Extended hover background - shows for both selected and non-selected items
              if (_isHovered)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 200, // Extended width for label
                    height: 46,
                    decoration: BoxDecoration(
                      // Match expanded sidebar hover colors exactly
                      color: widget.isSelected
                          ? const Color(0xFF875DEC) // Purple for selected
                          : Colors.white, // Solid white background for better visibility
                      borderRadius: BorderRadius.circular(8),
                      border: widget.isSelected
                          ? null
                          : Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      // No shadow to match expanded sidebar which has no shadow on hover
                    ),
                    child: Row(
                      children: [
                        // Space for icon
                        const SizedBox(width: 46),

                        // Label text
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 12.0),
                            child: Text(
                              widget.item.label,
                              style: TextStyle(
                                // Match expanded sidebar text colors exactly
                                color: widget.isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary, // Same as expanded sidebar
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Base state background (when not hovering)
              if (!_isHovered && widget.isSelected)
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF875DEC), // Purple for selected
                  ),
                ),

              // Icon container - no extra elevation or shadow
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isSelected ? 1.0 : _scaleAnimation.value,
                    child: Container(
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: widget.item.iconBuilder?.call(widget.isSelected, _isHovered) ??
                            Icon(
                              widget.item.icon ?? Icons.dashboard,
                              color: (widget.isSelected || (_isHovered && widget.isSelected))
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                      ),
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
        left: 12,  // Adjusted for wider sidebar
        right: 12,  // Adjusted for wider sidebar
        top: 0,
        bottom: 16,
      ),
      color: AppColors.surface,
      child: customLogo ??
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Image.asset(
              AppAssets.ccLogoFullColourCollapsed,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 50,
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

// Collapsed Footer Widget (keeping for backward compatibility)
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
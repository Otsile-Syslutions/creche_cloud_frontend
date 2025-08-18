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
  final bool isSubmenuItem;

  const _MenuItemHoverEffect({
    required this.child,
    required this.isSelected,
    required this.onTap,
    this.isSubmenuItem = false,
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
            borderRadius: BorderRadius.circular(widget.isSubmenuItem ? 6 : 8),
            color: widget.isSelected
                ? (widget.isSubmenuItem
                ? AppColors.loginButton.withOpacity(0.15)
                : const Color(0xFF875DEC))
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
        // Count total items including subitems
        int totalItemCount = _getTotalItemCount();
        final shouldScroll = controller.shouldEnableScroll(availableHeight, totalItemCount);

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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  if (header != null) header!,
                  Expanded(
                    child: shouldScroll
                        ? _buildScrollableMenu()
                        : _buildStaticMenu(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ProfileSidebarFooter(
                  isExpanded: true,
                  expandedWidth: width,
                  collapsedWidth: 85,
                  controllerTag: controller.controllerTag,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getTotalItemCount() {
    int count = items.length;
    for (var item in items) {
      if (item.subItems != null) {
        count += item.subItems!.length;
      }
    }
    return count;
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
          bottom: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildMenuItemWithSubitems(index);
        },
      ),
    );
  }

  Widget _buildStaticMenu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 16,
      ),
      child: Column(
        children: List.generate(
          items.length,
              (index) => _buildMenuItemWithSubitems(index),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithSubitems(int index) {
    final item = items[index];
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;

    return Obx(() {
      final isExpanded = controller.isMenuItemExpanded(index);

      return Column(
        children: [
          _buildMenuItem(index),
          if (hasSubItems)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Column(
                children: item.subItems!.asMap().entries.map((entry) {
                  final subIndex = entry.key;
                  final subItem = entry.value;
                  return _buildSubmenuItem(index, subIndex, subItem);
                }).toList(),
              )
                  : const SizedBox.shrink(),
            ),
        ],
      );
    });
  }

  Widget _buildMenuItem(int index) {
    final item = items[index];
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;

    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final isExpanded = controller.isMenuItemExpanded(index);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: _MenuItemHoverEffect(
          isSelected: isSelected,
          onTap: () {
            if (hasSubItems) {
              controller.toggleSubmenu(index);
            } else {
              controller.selectMenuItem(index);
              item.onTap?.call();
            }
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
                  // Label
                  Expanded(
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
                  // Chevron for items with subitems - positioned to the far right
                  if (hasSubItems)
                    Container(
                      width: 24,  // Fixed width to align all chevrons
                      alignment: Alignment.centerRight,
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isExpanded ? 0.25 : 0,
                        child: Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.textSecondary.withOpacity(0.6), // Static color for all states
                        ),
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

  Widget _buildSubmenuItem(int parentIndex, int subIndex, SidebarMenuItem subItem) {
    return Obx(() {
      final combinedIndex = parentIndex * 100 + subIndex;
      final isSelected = controller.selectedIndex.value == combinedIndex;

      return Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 2,
          bottom: 2,
        ),
        child: _MenuItemHoverEffect(
          isSelected: isSelected,
          isSubmenuItem: true,
          onTap: () {
            controller.selectSubmenuItem(parentIndex, subIndex);
            subItem.onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.only(
              left: 48, // Indent for submenu items
              right: 16,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                // No icon for submenu items as requested
                Flexible(
                  child: Text(
                    subItem.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.loginButton
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Roboto',
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
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
        top: 0,
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
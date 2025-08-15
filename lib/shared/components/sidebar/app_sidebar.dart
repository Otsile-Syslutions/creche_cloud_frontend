// lib/shared/components/sidebar/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_assets.dart';
import '../../../utils/app_logger.dart';
import 'app_sidebar_controller.dart';
import 'collapsed_sidebar.dart';
import 'expanded_sidebar.dart';
import 'sidebar_toggle_button.dart';

class AppSidebar extends StatefulWidget {
  final List<SidebarXItem> items;
  final Widget? header;
  final Widget? footer;
  final double expandedWidth;
  final double collapsedWidth;
  final int? selectedIndex;
  final bool startExpanded;
  final bool showToggleButton;

  const AppSidebar({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.expandedWidth = 250,
    this.collapsedWidth = 70,
    this.selectedIndex,
    this.startExpanded = true,
    this.showToggleButton = true,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late AppSidebarController _controller;
  late String _controllerTag;

  @override
  void initState() {
    super.initState();

    // Create a unique tag for this controller instance
    _controllerTag = 'sidebar_${UniqueKey().toString()}';

    // Initialize controller with try-catch for safety
    try {
      _controller = Get.put(
        AppSidebarController(),
        tag: _controllerTag,
      );

      // Set initial values
      _controller.isExpanded.value = widget.startExpanded;
      _controller.selectedIndex.value = widget.selectedIndex ?? 0;
      _controller.sidebarWidth.value = widget.expandedWidth;
      _controller.collapsedWidth.value = widget.collapsedWidth;

      // Initialize focus nodes for keyboard navigation
      _controller.initializeFocusNodes(widget.items.length);
    } catch (e) {
      AppLogger.e('Error initializing AppSidebar controller', e);
      // Initialize with a fallback controller if needed
      _controller = AppSidebarController();
    }
  }

  @override
  void dispose() {
    // Clean up controller safely
    try {
      if (Get.isRegistered<AppSidebarController>(tag: _controllerTag)) {
        Get.delete<AppSidebarController>(
          tag: _controllerTag,
          force: true,
        );
      }
    } catch (e) {
      AppLogger.e('Error disposing AppSidebar controller', e);
    }
    super.dispose();
  }

  List<SidebarMenuItem> _convertItems(List<SidebarXItem> items) {
    return items.map((item) {
      return SidebarMenuItem(
        label: item.label ?? '',
        icon: item.icon,
        iconBuilder: item.iconBuilder,
        onTap: item.onTap,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update responsive width based on screen size
        _controller.updateResponsiveWidth(constraints.maxWidth);

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowUp): () {
              _controller.handleKeyboardNavigation(LogicalKeyboardKey.arrowUp);
            },
            const SingleActivator(LogicalKeyboardKey.arrowDown): () {
              _controller.handleKeyboardNavigation(LogicalKeyboardKey.arrowDown);
            },
            const SingleActivator(LogicalKeyboardKey.enter): () {
              _controller.handleKeyboardNavigation(LogicalKeyboardKey.enter);
            },
          },
          child: Focus(
            autofocus: false,
            child: Stack(
              children: [
                // Main Sidebar with animation
                Obx(() {
                  final isExpanded = _controller.isExpanded.value;
                  final menuItems = _convertItems(widget.items);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isExpanded
                        ? _controller.sidebarWidth.value
                        : _controller.collapsedWidth.value,
                    child: isExpanded
                        ? ExpandedSidebar(
                      controller: _controller,
                      items: menuItems,
                      header: _buildHeader(isExpanded),
                      footer: _buildFooter(isExpanded),
                      width: _controller.sidebarWidth.value,
                    )
                        : CollapsedSidebar(
                      controller: _controller,
                      items: menuItems,
                      header: _buildHeader(isExpanded),
                      footer: _buildFooter(isExpanded),
                      width: _controller.collapsedWidth.value,
                    ),
                  );
                }),

                // Toggle Button
                if (widget.showToggleButton)
                  SidebarToggleButton(controller: _controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildHeader(bool isExpanded) {
    if (widget.header == null) return null;

    // If header is already a custom widget, use it directly
    if (widget.header is! AppSidebarHeader) {
      return widget.header;
    }

    // Handle AppSidebarHeader conversion
    final appHeader = widget.header as AppSidebarHeader;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isExpanded
          ? ExpandedSidebarHeader(
        key: const ValueKey('expanded_header'),
        customLogo: appHeader.customLogo,
      )
          : CollapsedSidebarHeader(
        key: const ValueKey('collapsed_header'),
        customLogo: appHeader.customLogo,
      ),
    );
  }

  Widget? _buildFooter(bool isExpanded) {
    if (widget.footer == null) return null;

    // If footer is already a custom widget, use it directly
    if (widget.footer is! AppSidebarFooter) {
      return widget.footer;
    }

    // Handle AppSidebarFooter conversion
    final appFooter = widget.footer as AppSidebarFooter;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isExpanded
          ? ExpandedSidebarFooter(
        key: const ValueKey('expanded_footer'),
        statusText: appFooter.statusText,
        isActive: appFooter.isActive,
        statusIcon: appFooter.statusIcon,
        onTap: appFooter.onTap,
      )
          : CollapsedSidebarFooter(
        key: const ValueKey('collapsed_footer'),
        isActive: appFooter.isActive,
        statusIcon: appFooter.statusIcon,
        onTap: appFooter.onTap,
      ),
    );
  }
}

// Keep the original AppSidebarHeader for backward compatibility
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
    // Default build for backward compatibility
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 20,
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

// Keep the original AppSidebarFooter for backward compatibility
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

// Responsive sidebar wrapper for automatic collapsing on small screens
class ResponsiveAppSidebar extends StatelessWidget {
  final List<SidebarXItem> items;
  final Widget? header;
  final Widget? footer;
  final double breakpoint;
  final int? selectedIndex;

  const ResponsiveAppSidebar({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.breakpoint = 1200,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final shouldCollapse = screenWidth < breakpoint;

        return AppSidebar(
          items: items,
          header: header,
          footer: footer,
          selectedIndex: selectedIndex,
          startExpanded: !shouldCollapse,
          expandedWidth: screenWidth < 1400 ? 220 : 250,
          collapsedWidth: screenWidth < 1200 ? 60 : 70,
        );
      },
    );
  }
}
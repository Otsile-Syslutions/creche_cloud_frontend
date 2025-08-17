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
  final VoidCallback? onToggle;

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
    this.onToggle,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> with SingleTickerProviderStateMixin {
  late AppSidebarController _controller;
  late String _controllerTag;
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();

    // Local state for expansion
    _isExpanded = widget.startExpanded;

    // Create a unique tag for this controller instance
    _controllerTag = 'sidebar_${UniqueKey().toString()}';

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: widget.collapsedWidth,
      end: widget.expandedWidth,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial animation state
    if (_isExpanded) {
      _animationController.value = 1.0;
    }

    // Initialize controller with try-catch for safety
    try {
      _controller = Get.put(
        AppSidebarController(),
        tag: _controllerTag,
      );

      // Set initial values
      _controller.isExpanded.value = _isExpanded;
      _controller.selectedIndex.value = widget.selectedIndex ?? 0;
      _controller.sidebarWidth.value = widget.expandedWidth;
      _controller.collapsedWidth.value = widget.collapsedWidth;

      // Initialize focus nodes for keyboard navigation
      _controller.initializeFocusNodes(widget.items.length);

      // Listen to controller changes
      _controller.isExpanded.listen((value) {
        if (mounted && value != _isExpanded) {
          setState(() {
            _isExpanded = value;
          });
          if (_isExpanded) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        }
      });
    } catch (e) {
      AppLogger.e('Error initializing AppSidebar controller', e);
      // Initialize with a fallback controller if needed
      _controller = AppSidebarController();
    }
  }

  @override
  void didUpdateWidget(AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update expansion state if it changed from parent
    if (oldWidget.startExpanded != widget.startExpanded) {
      setState(() {
        _isExpanded = widget.startExpanded;
      });
      _controller.isExpanded.value = widget.startExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // Update widths if they changed
    if (oldWidget.expandedWidth != widget.expandedWidth ||
        oldWidget.collapsedWidth != widget.collapsedWidth) {
      _controller.sidebarWidth.value = widget.expandedWidth;
      _controller.collapsedWidth.value = widget.collapsedWidth;
      _widthAnimation = Tween<double>(
        begin: widget.collapsedWidth,
        end: widget.expandedWidth,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void _handleToggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    _controller.isExpanded.value = _isExpanded;

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update responsive width based on screen size
        _controller.updateResponsiveWidth(constraints.maxWidth);

        final menuItems = _convertItems(widget.items);

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
              clipBehavior: Clip.none, // CRITICAL: Allow overflow for tooltips
              children: [
                // Main Sidebar with animation
                AnimatedBuilder(
                  animation: _widthAnimation,
                  builder: (context, child) {
                    return Container(
                      width: _widthAnimation.value,
                      child: Stack(
                        clipBehavior: Clip.none, // Allow internal overflow
                        children: [
                          // Sidebar content
                          _isExpanded
                              ? ExpandedSidebar(
                            controller: _controller,
                            items: menuItems,
                            header: _buildHeader(_isExpanded),
                            width: widget.expandedWidth,
                          )
                              : CollapsedSidebar(
                            controller: _controller,
                            items: menuItems,
                            header: _buildHeader(_isExpanded),
                            width: widget.collapsedWidth,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Toggle Button - positioned to be visible
                if (widget.showToggleButton)
                  Positioned(
                    top: _isExpanded ? 12 : 12, // Keep same top position for both states
                    right: _isExpanded ? 12 : ((widget.collapsedWidth - 40) / 2), // Center in collapsed state
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _handleToggle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
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
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 250),
                              turns: _isExpanded ? 0.0 : 0.5,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 24,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
class ResponsiveAppSidebar extends StatefulWidget {
  final List<SidebarXItem> items;
  final Widget? header;
  final Widget? footer;
  final double breakpoint;
  final int? selectedIndex;
  final VoidCallback? onToggle;
  final bool isExpanded;

  const ResponsiveAppSidebar({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.breakpoint = 1200,
    this.selectedIndex,
    this.onToggle,
    this.isExpanded = true,
  });

  @override
  State<ResponsiveAppSidebar> createState() => _ResponsiveAppSidebarState();
}

class _ResponsiveAppSidebarState extends State<ResponsiveAppSidebar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final shouldCollapse = screenWidth < widget.breakpoint;

        return AppSidebar(
          items: widget.items,
          header: widget.header,
          footer: widget.footer,
          selectedIndex: widget.selectedIndex,
          startExpanded: widget.isExpanded && !shouldCollapse,
          expandedWidth: screenWidth < 1400 ? 220 : 250,
          collapsedWidth: screenWidth < 1200 ? 60 : 70,
          onToggle: widget.onToggle,
        );
      },
    );
  }
}
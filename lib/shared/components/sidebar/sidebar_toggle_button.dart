// lib/shared/components/sidebar/sidebar_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../constants/app_colors.dart';
import 'app_sidebar_controller.dart';

class SidebarToggleButton extends StatefulWidget {
  final AppSidebarController controller;
  final double? top;
  final double? right;
  final double? left;
  final double? bottom;

  const SidebarToggleButton({
    super.key,
    required this.controller,
    this.top,
    this.right,
    this.left,
    this.bottom,
  });

  @override
  State<SidebarToggleButton> createState() => _SidebarToggleButtonState();
}

class _SidebarToggleButtonState extends State<SidebarToggleButton>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top ?? 12,
      right: widget.right ?? 12,
      left: widget.left,
      bottom: widget.bottom,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovering = true);
          _hoverController.forward();
        },
        onExit: (_) {
          setState(() => _isHovering = false);
          _hoverController.reverse();
        },
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: widget.controller.toggleSidebar,
                  child: Obx(() {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isHovering
                            ? Colors.white
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isHovering
                              ? AppColors.loginButton.withOpacity(0.3)
                              : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(_isHovering ? 0.08 : 0.05),
                            blurRadius: _isHovering ? 6 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedRotation(
                          turns: widget.controller.isExpanded.value ? 0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: HugeIcon(
                            icon: widget.controller.isExpanded.value
                                ? HugeIcons.strokeRoundedMenu01
                                : HugeIcons.strokeRoundedMenu03,
                            size: 22,
                            color: _isHovering
                                ? AppColors.loginButton
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Alternative toggle button styles
class SidebarToggleButtonMinimal extends StatelessWidget {
  final AppSidebarController controller;

  const SidebarToggleButtonMinimal({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return IconButton(
        onPressed: controller.toggleSidebar,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(
              turns: animation,
              child: child,
            );
          },
          child: Icon(
            controller.isExpanded.value
                ? Icons.chevron_left
                : Icons.chevron_right,
            key: ValueKey(controller.isExpanded.value),
            color: AppColors.textSecondary,
          ),
        ),
        tooltip: controller.isExpanded.value ? 'Collapse sidebar' : 'Expand sidebar',
      );
    });
  }
}

// Hamburger style toggle button
class SidebarToggleButtonHamburger extends StatefulWidget {
  final AppSidebarController controller;

  const SidebarToggleButtonHamburger({
    super.key,
    required this.controller,
  });

  @override
  State<SidebarToggleButtonHamburger> createState() =>
      _SidebarToggleButtonHamburgerState();
}

class _SidebarToggleButtonHamburgerState
    extends State<SidebarToggleButtonHamburger>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Sync with controller state
    if (!widget.controller.isExpanded.value) {
      _animationController.value = 1.0;
    }

    // Listen to changes
    widget.controller.isExpanded.listen((expanded) {
      if (expanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.controller.toggleSidebar,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLine(0),
                    _buildLine(1),
                    _buildLine(2),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLine(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 2,
      width: index == 1
          ? (widget.controller.isExpanded.value ? 24 : 16)
          : 24,
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
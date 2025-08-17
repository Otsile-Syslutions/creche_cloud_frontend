// lib/shared/components/sidebar/profile_footer_widgets.dart
import 'package:flutter/material.dart';

// User Avatar Widget (shared between expanded and collapsed)
class UserAvatar extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final String? photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
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

// Hover Scale Wrapper for expanded menu items (matches menu item hover effect)
class HoverScaleWrapper extends StatefulWidget {
  final Widget child;

  const HoverScaleWrapper({
    super.key,
    required this.child,
  });

  @override
  State<HoverScaleWrapper> createState() => _HoverScaleWrapperState();
}

class _HoverScaleWrapperState extends State<HoverScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.centerLeft,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
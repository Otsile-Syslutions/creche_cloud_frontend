// lib/features/auth/views/login/components/promotional_slider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

class PromotionalSlider extends StatefulWidget {
  final double width;
  final double height;

  const PromotionalSlider({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<PromotionalSlider> createState() => _PromotionalSliderState();
}

class _PromotionalSliderState extends State<PromotionalSlider>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  bool _timerActive = false;

  final List<PromotionalSlide> _slides = [
    PromotionalSlide(
      emoji: '🎉',
      headerColor: const Color(0xFF875DEC),
      headerText: 'In One App. On the Cloud. Every Step Of Your Child\'s Creche Journey!',
      bodyText: 'The Creche Cloud platform gives parents a window into their child\'s day and gives peace of mind.',
    ),
    PromotionalSlide(
      emoji: '✨',
      headerColor: const Color(0xFF2196F3), // Bright blue
      headerText: 'In One App. On the Cloud. Every Aspect Of Managing Your ECD Center',
      bodyText: 'The Creche Cloud platform gives ECD owners and staff an easy tool to manage their own day and increase efficiency.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timerActive = false;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    if (mounted) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        _nextSlide();
      } else {
        timer.cancel();
      }
    });
  }

  void _nextSlide() {
    if (!mounted) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _slides.length;
    });

    if (mounted) {
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void deactivate() {
    _timer.cancel();
    _fadeController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeController.stop();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final containerHeight = constraints.maxHeight;

        // Get screen dimensions to calculate scale factor consistent with login_view_desktop.dart
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;
        final minScreenSize = screenWidth < screenHeight ? screenWidth : screenHeight;

        // Use the same scale factor calculation as login_view_desktop.dart
        final scaleFactor = (minScreenSize / 1000).clamp(0.3, 2.0); // Base scale factor matching desktop view

        // Calculate proportional sizing based on the container dimensions
        // The container is 38% of screen width and 20% of screen height
        final baseContainerWidth = screenWidth * 0.38;
        final baseContainerHeight = screenHeight * 0.20;

        // Additional scale factor based on how much the container deviates from expected size
        final containerWidthScale = containerWidth / baseContainerWidth;
        final containerHeightScale = containerHeight / baseContainerHeight;
        final containerScale = (containerWidthScale + containerHeightScale) / 2;

        // Combined scale factor
        final finalScaleFactor = (scaleFactor * containerScale).clamp(0.2, 3.0);

        // Responsive sizing with consistent scaling
        final borderRadius = (16 * finalScaleFactor).clamp(8.0, 24.0);
        final outerPadding = (16 * finalScaleFactor).clamp(10.0, 24.0);
        final headerPadding = (12 * finalScaleFactor).clamp(8.0, 18.0);
        final headerBorderRadius = (12 * finalScaleFactor).clamp(8.0, 16.0);

        // Fixed proportional spacing as percentages of container height
        final spacingBetweenElements = (containerHeight * 0.08).clamp(6.0, 20.0);
        final bottomSpacing = (containerHeight * 0.06).clamp(4.0, 16.0);

        // Enhanced responsive font sizes that scale consistently
        final emojiSize = (20 * finalScaleFactor).clamp(12.0, 30.0);
        final headerFontSize = _calculateHeaderFontSize(finalScaleFactor, containerWidth, containerHeight);
        final bodyFontSize = _calculateBodyFontSize(finalScaleFactor, containerWidth, containerHeight);

        // Responsive indicator size
        final indicatorSize = (6 * finalScaleFactor).clamp(4.0, 10.0);
        final indicatorSpacing = (3 * finalScaleFactor).clamp(2.0, 6.0);

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0).withOpacity(0.6),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: EdgeInsets.all(outerPadding),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header rectangle with emoji and text (approximately 30% of height)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(headerPadding),
                        decoration: BoxDecoration(
                          color: _slides[_currentIndex].headerColor,
                          borderRadius: BorderRadius.circular(headerBorderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: _slides[_currentIndex].headerColor.withOpacity(0.3),
                              blurRadius: 6 * finalScaleFactor,
                              offset: Offset(0, 2 * finalScaleFactor),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Emoji
                            Text(
                              _slides[_currentIndex].emoji,
                              style: TextStyle(
                                fontSize: emojiSize,
                              ),
                            ),
                            SizedBox(width: 8 * finalScaleFactor),
                            // Header text with responsive sizing
                            Expanded(
                              child: Text(
                                _slides[_currentIndex].headerText,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: headerFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacingBetweenElements),

                      // Body text (approximately 55% of height)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4 * finalScaleFactor),
                          child: Center(
                            child: Text(
                              _slides[_currentIndex].bodyText,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: bodyFontSize,
                                color: Colors.white,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1 * finalScaleFactor),
                                    blurRadius: 2 * finalScaleFactor,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: bottomSpacing),

                      // Slide indicators (approximately 15% of height)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: indicatorSpacing),
                            width: indicatorSize,
                            height: indicatorSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Calculate header font size with consistent scaling
  double _calculateHeaderFontSize(double scale, double containerWidth, double containerHeight) {
    // Base font size that scales with the overall scale factor
    double baseSize = 16 * scale;

    // Adjust based on container dimensions for better fit
    if (containerWidth < 200) {
      baseSize *= 0.75; // Smaller for very narrow containers
    } else if (containerWidth < 300) {
      baseSize *= 0.9; // Slightly smaller for narrow containers
    }

    if (containerHeight < 100) {
      baseSize *= 0.8; // Smaller for very short containers
    }

    return baseSize.clamp(10.0, 22.0);
  }

  /// Calculate body font size with consistent scaling
  double _calculateBodyFontSize(double scale, double containerWidth, double containerHeight) {
    // Base font size that scales with the overall scale factor
    double baseSize = 24 * scale;

    // Adjust based on container dimensions
    if (containerWidth < 200) {
      baseSize *= 0.7; // Much smaller for very narrow containers
    } else if (containerWidth < 300) {
      baseSize *= 0.85; // Smaller for narrow containers
    }

    if (containerHeight < 100) {
      baseSize *= 0.75; // Smaller for very short containers
    } else if (containerHeight < 140) {
      baseSize *= 0.9; // Moderately smaller for short containers
    }

    return baseSize.clamp(14.0, 32.0);
  }
}

class PromotionalSlide {
  final String emoji;
  final Color headerColor;
  final String headerText;
  final String bodyText;

  PromotionalSlide({
    required this.emoji,
    required this.headerColor,
    required this.headerText,
    required this.bodyText,
  });
}
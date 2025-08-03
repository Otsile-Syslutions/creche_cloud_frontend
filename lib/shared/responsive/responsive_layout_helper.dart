// lib/shared/responsive/responsive_layout_helper.dart
import 'package:flutter/material.dart';

class ResponsiveLayoutHelper {
  static const double _baseWidth = 1200.0; // Base design width (desktop)
  static const double _baseHeight = 800.0;  // Base design height (desktop)

  /// Get screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get scale factor based on screen width
  static double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / _baseWidth).clamp(0.6, 2.0);
  }

  /// Get scale factor based on both width and height
  static double getUniformScaleFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthScale = size.width / _baseWidth;
    final heightScale = size.height / _baseHeight;
    return (widthScale < heightScale ? widthScale : heightScale).clamp(0.6, 2.0);
  }

  /// Scale a value based on screen size
  static double scale(BuildContext context, double value, {double? minValue, double? maxValue}) {
    final scaleFactor = getUniformScaleFactor(context);
    final scaledValue = value * scaleFactor;

    if (minValue != null && maxValue != null) {
      return scaledValue.clamp(minValue, maxValue);
    } else if (minValue != null) {
      return scaledValue < minValue ? minValue : scaledValue;
    } else if (maxValue != null) {
      return scaledValue > maxValue ? maxValue : scaledValue;
    }

    return scaledValue;
  }

  /// Scale font size with specific constraints
  static double scaleFontSize(BuildContext context, double fontSize) {
    return scale(context, fontSize, minValue: fontSize * 0.7, maxValue: fontSize * 1.5);
  }

  /// Scale padding/margin values
  static double scalePadding(BuildContext context, double padding) {
    return scale(context, padding, minValue: padding * 0.5, maxValue: padding * 2.0);
  }

  /// Scale icon sizes
  static double scaleIconSize(BuildContext context, double iconSize) {
    return scale(context, iconSize, minValue: iconSize * 0.8, maxValue: iconSize * 1.3);
  }

  /// Get responsive EdgeInsets
  static EdgeInsets scaleEdgeInsets(BuildContext context, EdgeInsets insets) {
    return EdgeInsets.only(
      left: scalePadding(context, insets.left),
      top: scalePadding(context, insets.top),
      right: scalePadding(context, insets.right),
      bottom: scalePadding(context, insets.bottom),
    );
  }

  /// Get responsive BorderRadius
  static BorderRadius scaleBorderRadius(BuildContext context, BorderRadius radius) {
    final scaleFactor = getUniformScaleFactor(context);
    return BorderRadius.only(
      topLeft: radius.topLeft * scaleFactor,
      topRight: radius.topRight * scaleFactor,
      bottomLeft: radius.bottomLeft * scaleFactor,
      bottomRight: radius.bottomRight * scaleFactor,
    );
  }

  /// Get responsive Size
  static Size scaleSize(BuildContext context, Size size) {
    final scaleFactor = getUniformScaleFactor(context);
    return Size(size.width * scaleFactor, size.height * scaleFactor);
  }

  /// Check if screen is small (mobile-like even on desktop)
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 600 || size.height < 400;
  }

  /// Check if screen is medium (tablet-like)
  static bool isMediumScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 && size.width < 1200;
  }

  /// Check if screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 1200;
  }

  /// Get responsive value based on screen size category
  static T getResponsiveValue<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    if (isLargeScreen(context) && desktop != null) {
      return desktop;
    } else if (isMediumScreen(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Scale position offset (for positioned widgets)
  static Offset scaleOffset(BuildContext context, Offset offset) {
    final scaleFactor = getUniformScaleFactor(context);
    return Offset(offset.dx * scaleFactor, offset.dy * scaleFactor);
  }

  /// Scale position as percentage of screen
  static Offset scalePositionAsPercentage(BuildContext context, Offset percentageOffset) {
    final size = MediaQuery.of(context).size;
    return Offset(
      size.width * percentageOffset.dx,
      size.height * percentageOffset.dy,
    );
  }

  /// Get responsive constraints
  static BoxConstraints scaleConstraints(BuildContext context, BoxConstraints constraints) {
    final scaleFactor = getUniformScaleFactor(context);
    return BoxConstraints(
      minWidth: constraints.minWidth * scaleFactor,
      maxWidth: constraints.maxWidth * scaleFactor,
      minHeight: constraints.minHeight * scaleFactor,
      maxHeight: constraints.maxHeight * scaleFactor,
    );
  }

  /// Create responsive Text widget
  static Widget responsiveText(
      BuildContext context,
      String text, {
        required double fontSize,
        FontWeight? fontWeight,
        Color? color,
        String? fontFamily,
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
      }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: scaleFontSize(context, fontSize),
        fontWeight: fontWeight,
        color: color,
        fontFamily: fontFamily,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Create responsive Container
  static Widget responsiveContainer(
      BuildContext context, {
        required Widget child,
        double? width,
        double? height,
        EdgeInsets? padding,
        EdgeInsets? margin,
        Color? color,
        BorderRadius? borderRadius,
        List<BoxShadow>? boxShadow,
      }) {
    return Container(
      width: width != null ? scale(context, width) : null,
      height: height != null ? scale(context, height) : null,
      padding: padding != null ? scaleEdgeInsets(context, padding) : null,
      margin: margin != null ? scaleEdgeInsets(context, margin) : null,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius != null ? scaleBorderRadius(context, borderRadius) : null,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }

  /// Create responsive SizedBox
  static Widget responsiveSizedBox(
      BuildContext context, {
        double? width,
        double? height,
        Widget? child,
      }) {
    return SizedBox(
      width: width != null ? scale(context, width) : null,
      height: height != null ? scale(context, height) : null,
      child: child,
    );
  }
}

/// Extension methods for easier usage
extension ResponsiveDoubleExtension on double {
  double responsive(BuildContext context) => ResponsiveLayoutHelper.scale(context, this);
  double responsiveFont(BuildContext context) => ResponsiveLayoutHelper.scaleFontSize(context, this);
  double responsivePadding(BuildContext context) => ResponsiveLayoutHelper.scalePadding(context, this);
  double responsiveIcon(BuildContext context) => ResponsiveLayoutHelper.scaleIconSize(context, this);
}

extension ResponsiveEdgeInsetsExtension on EdgeInsets {
  EdgeInsets responsive(BuildContext context) => ResponsiveLayoutHelper.scaleEdgeInsets(context, this);
}

extension ResponsiveBorderRadiusExtension on BorderRadius {
  BorderRadius responsive(BuildContext context) => ResponsiveLayoutHelper.scaleBorderRadius(context, this);
}

extension ResponsiveSizeExtension on Size {
  Size responsive(BuildContext context) => ResponsiveLayoutHelper.scaleSize(context, this);
}

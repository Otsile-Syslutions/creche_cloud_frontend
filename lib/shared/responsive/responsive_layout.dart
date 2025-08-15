// lib/shared/responsive/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Breakpoints - keeping existing values
  static const double mobileBreakpoint = 768;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
          MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet ?? mobile; // Fallback to mobile if tablet not provided
        } else {
          return mobile;
        }
      },
    );
  }
}

// Helper class for responsive values
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  T get(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context)) {
      return desktop;
    } else if (ResponsiveLayout.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// Responsive helper widget for showing/hiding widgets based on screen size
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final Widget? replacement;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    bool isVisible = false;

    if (ResponsiveLayout.isMobile(context) && visibleOnMobile) {
      isVisible = true;
    } else if (ResponsiveLayout.isTablet(context) && visibleOnTablet) {
      isVisible = true;
    } else if (ResponsiveLayout.isDesktop(context) && visibleOnDesktop) {
      isVisible = true;
    }

    if (!isVisible && replacement != null) {
      return replacement!;
    }

    return Visibility(
      visible: isVisible,
      child: child,
    );
  }
}

// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding;

    if (ResponsiveLayout.isMobile(context)) {
      padding = mobilePadding ?? const EdgeInsets.all(16);
    } else if (ResponsiveLayout.isTablet(context)) {
      padding = tabletPadding ?? const EdgeInsets.all(24);
    } else {
      padding = desktopPadding ?? const EdgeInsets.all(32);
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    int columns;

    if (ResponsiveLayout.isMobile(context)) {
      columns = mobileColumns;
    } else if (ResponsiveLayout.isTablet(context)) {
      columns = tabletColumns;
    } else {
      columns = desktopColumns;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio ?? 1,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

// Responsive container with different constraints per breakpoint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final BoxConstraints? mobileConstraints;
  final BoxConstraints? tabletConstraints;
  final BoxConstraints? desktopConstraints;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileConstraints,
    this.tabletConstraints,
    this.desktopConstraints,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    BoxConstraints? constraints;

    if (ResponsiveLayout.isMobile(context)) {
      constraints = mobileConstraints;
    } else if (ResponsiveLayout.isTablet(context)) {
      constraints = tabletConstraints;
    } else {
      constraints = desktopConstraints;
    }

    return Container(
      constraints: constraints,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

// Responsive text widget with different styles per breakpoint
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
      this.text, {
        super.key,
        this.mobileStyle,
        this.tabletStyle,
        this.desktopStyle,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    TextStyle? style;

    if (ResponsiveLayout.isMobile(context)) {
      style = mobileStyle;
    } else if (ResponsiveLayout.isTablet(context)) {
      style = tabletStyle ?? mobileStyle;
    } else {
      style = desktopStyle ?? tabletStyle ?? mobileStyle;
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
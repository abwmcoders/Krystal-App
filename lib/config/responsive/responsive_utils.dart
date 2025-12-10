import 'package:flutter/material.dart';

/// Responsive utilities for handling different screen sizes
class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is mobile (width < 600)
  static bool isMobile(BuildContext context) {
    return width(context) < mobileBreakpoint;
  }

  /// Check if device is tablet (width >= 600 && width < 1200)
  static bool isTablet(BuildContext context) {
    return width(context) >= mobileBreakpoint && width(context) < tabletBreakpoint;
  }

  /// Check if device is desktop (width >= 1200)
  static bool isDesktop(BuildContext context) {
    return width(context) >= tabletBreakpoint;
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, {required double mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get responsive padding/margin
  static double responsiveSize(BuildContext context, {required double mobile, double? tablet, double? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get responsive width with max constraint
  static double responsiveWidth(BuildContext context, {double? maxWidth, double? minWidth}) {
    double screenWidth = width(context);
    if (maxWidth != null && screenWidth > maxWidth) {
      screenWidth = maxWidth;
    }
    if (minWidth != null && screenWidth < minWidth) {
      screenWidth = minWidth;
    }
    return screenWidth;
  }

  /// Get responsive container height (e.g., for welcome card)
  static double getWelcomeCardHeight(BuildContext context) {
    return responsiveSize(context, mobile: 350, tablet: 300, desktop: 280);
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveSize(context, mobile: 20, tablet: 30, desktop: 40),
      vertical: responsiveSize(context, mobile: 12, tablet: 16, desktop: 20),
    );
  }

  /// Get responsive card padding
  static EdgeInsets responsiveCardPadding(BuildContext context) {
    return EdgeInsets.all(responsiveSize(context, mobile: 10, tablet: 14, desktop: 18));
  }

  /// Get responsive border radius
  static BorderRadius responsiveBorderRadius(BuildContext context) {
    return BorderRadius.circular(responsiveSize(context, mobile: 20, tablet: 24, desktop: 28));
  }

  /// Get grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 3;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }
}

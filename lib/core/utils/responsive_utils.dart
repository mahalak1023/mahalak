import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// Responsive utilities for handling different screen sizes
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Check if the current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile;
  }

  /// Check if the current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.tablet;
  }

  /// Check if the current device is desktop/web
  static bool isDesktop(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.desktop;
  }

  /// Get the device type
  static DeviceScreenType getScreenType(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size);
  }

  /// Get value based on screen type
  static T valueWhen<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case DeviceScreenType.mobile:
        return mobile;
      case DeviceScreenType.tablet:
        return tablet ?? mobile;
      case DeviceScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      default:
        return mobile;
    }
  }

  /// Responsive spacing
  static double spacing({
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) {
    // ScreenUtil will handle the scaling
    return mobile.h;
  }

  /// Responsive padding - horizontal
  static EdgeInsets horizontalPadding({
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    return EdgeInsets.symmetric(horizontal: mobile.w);
  }

  /// Responsive padding - vertical
  static EdgeInsets verticalPadding({
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    return EdgeInsets.symmetric(vertical: mobile.h);
  }

  /// Responsive padding - all sides
  static EdgeInsets allPadding({
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    return EdgeInsets.all(mobile.r);
  }

  /// Get responsive width
  static double width(double width) => width.w;

  /// Get responsive height
  static double height(double height) => height.h;

  /// Get responsive radius
  static double radius(double radius) => radius.r;

  /// Get responsive font size
  static double fontSize(double size) => size.sp;

  /// Max width for content on large screens
  static double get maxContentWidth => 1200.w;

  /// Get grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    return valueWhen(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Extension on BuildContext for easier access
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  DeviceScreenType get screenType => ResponsiveUtils.getScreenType(this);
}

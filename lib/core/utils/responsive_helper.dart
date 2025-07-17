import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Helper method to clamp values between min and max
  static double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }

  // Padding methods using percentage with reasonable limits
  static double getPadding(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double padding;
    if (isMobile(context)) {
      padding = screenWidth * 0.04; // 4% of screen width
      return _clamp(padding, 12.0, 24.0);
    } else if (isTablet(context)) {
      padding = screenWidth * 0.025; // 2.5% of screen width
      return _clamp(padding, 16.0, 32.0);
    } else {
      padding = screenWidth * 0.02; // 2% of screen width
      return _clamp(padding, 20.0, 40.0);
    }
  }

  static double getHorizontalPadding(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double padding;
    if (isMobile(context)) {
      padding = screenWidth * 0.04; // 4% of screen width
      return _clamp(padding, 16.0, 32.0);
    } else if (isTablet(context)) {
      padding = screenWidth * 0.03; // 3% of screen width
      return _clamp(padding, 24.0, 48.0);
    } else {
      padding = screenWidth * 0.025; // 2.5% of screen width
      return _clamp(padding, 32.0, 64.0);
    }
  }

  static double getVerticalPadding(BuildContext context) {
    double screenHeight = getScreenHeight(context);
    double padding;
    if (isMobile(context)) {
      padding = screenHeight * 0.015; // 1.5% of screen height
      return _clamp(padding, 12.0, 24.0);
    } else if (isTablet(context)) {
      padding = screenHeight * 0.02; // 2% of screen height
      return _clamp(padding, 16.0, 32.0);
    } else {
      padding = screenHeight * 0.025; // 2.5% of screen height
      return _clamp(padding, 20.0, 40.0);
    }
  }

  // Spacing methods using percentage with reasonable limits
  static double getSpacing(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double spacing;
    if (isMobile(context)) {
      spacing = screenWidth * 0.02; // 2% of screen width
      return _clamp(spacing, 8.0, 16.0);
    } else if (isTablet(context)) {
      spacing = screenWidth * 0.015; // 1.5% of screen width
      return _clamp(spacing, 10.0, 20.0);
    } else {
      spacing = screenWidth * 0.01; // 1% of screen width
      return _clamp(spacing, 12.0, 24.0);
    }
  }

  static double getLargeSpacing(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double spacing;
    if (isMobile(context)) {
      spacing = screenWidth * 0.04; // 4% of screen width
      return _clamp(spacing, 16.0, 32.0);
    } else if (isTablet(context)) {
      spacing = screenWidth * 0.03; // 3% of screen width
      return _clamp(spacing, 20.0, 40.0);
    } else {
      spacing = screenWidth * 0.025; // 2.5% of screen width
      return _clamp(spacing, 24.0, 48.0);
    }
  }

  static double getExtraLargeSpacing(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double spacing;
    if (isMobile(context)) {
      spacing = screenWidth * 0.06; // 6% of screen width
      return _clamp(spacing, 24.0, 48.0);
    } else if (isTablet(context)) {
      spacing = screenWidth * 0.04; // 4% of screen width
      return _clamp(spacing, 28.0, 56.0);
    } else {
      spacing = screenWidth * 0.035; // 3.5% of screen width
      return _clamp(spacing, 32.0, 64.0);
    }
  }

  // Font size methods with better scaling
  static double getFontSize(BuildContext context, double baseSize) {
    double screenWidth = getScreenWidth(context);
    double fontSize;
    
    if (isMobile(context)) {
      fontSize = baseSize * (screenWidth / 375); // 375 is typical mobile width
      return _clamp(fontSize, baseSize * 0.8, baseSize * 1.2);
    } else if (isTablet(context)) {
      fontSize = baseSize * (screenWidth / 768); // 768 is typical tablet width
      return _clamp(fontSize, baseSize * 0.9, baseSize * 1.3);
    } else {
      fontSize = baseSize * (screenWidth / 1024); // 1024 is typical desktop width
      return _clamp(fontSize, baseSize * 1.0, baseSize * 1.4);
    }
  }

  // Icon size methods with better scaling
  static double getIconSize(BuildContext context, double baseSize) {
    double screenWidth = getScreenWidth(context);
    double iconSize;
    
    if (isMobile(context)) {
      iconSize = baseSize * (screenWidth / 375);
      return _clamp(iconSize, baseSize * 0.8, baseSize * 1.2);
    } else if (isTablet(context)) {
      iconSize = baseSize * (screenWidth / 768);
      return _clamp(iconSize, baseSize * 0.9, baseSize * 1.3);
    } else {
      iconSize = baseSize * (screenWidth / 1024);
      return _clamp(iconSize, baseSize * 1.0, baseSize * 1.4);
    }
  }

  // Button and input height using percentage of screen height with limits
  static double getButtonHeight(BuildContext context) {
    double screenHeight = getScreenHeight(context);
    double height;
    if (isMobile(context)) {
      height = screenHeight * 0.06; // 6% of screen height
      return _clamp(height, 44.0, 56.0);
    } else if (isTablet(context)) {
      height = screenHeight * 0.055; // 5.5% of screen height
      return _clamp(height, 48.0, 60.0);
    } else {
      height = screenHeight * 0.05; // 5% of screen height
      return _clamp(height, 52.0, 64.0);
    }
  }

  static double getInputHeight(BuildContext context) {
    double screenHeight = getScreenHeight(context);
    double height;
    if (isMobile(context)) {
      height = screenHeight * 0.06; // 6% of screen height
      return _clamp(height, 44.0, 56.0);
    } else if (isTablet(context)) {
      height = screenHeight * 0.055; // 5.5% of screen height
      return _clamp(height, 48.0, 60.0);
    } else {
      height = screenHeight * 0.05; // 5% of screen height
      return _clamp(height, 52.0, 64.0);
    }
  }

  // Border radius using percentage with limits
  static double getBorderRadius(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double radius;
    if (isMobile(context)) {
      radius = screenWidth * 0.02; // 2% of screen width
      return _clamp(radius, 6.0, 12.0);
    } else if (isTablet(context)) {
      radius = screenWidth * 0.015; // 1.5% of screen width
      return _clamp(radius, 8.0, 16.0);
    } else {
      radius = screenWidth * 0.012; // 1.2% of screen width
      return _clamp(radius, 10.0, 20.0);
    }
  }

  // Card elevation remains fixed as it's more about visual depth
  static double getCardElevation(BuildContext context) {
    if (isMobile(context)) return 2.0;
    if (isTablet(context)) return 3.0;
    return 4.0;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  static EdgeInsets getContentPadding(BuildContext context) {
    return EdgeInsets.all(getPadding(context));
  }

  // Max content width using percentage with reasonable limits
  static double getMaxContentWidth(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    if (isMobile(context)) return screenWidth * 0.95; // 95% of screen width
    if (isTablet(context)) return screenWidth * 0.85; // 85% of screen width
    return screenWidth * 0.75; // 75% of screen width
  }

  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxContentWidth(context),
        ),
        padding: padding ?? getContentPadding(context),
        child: child,
      ),
    );
  }

  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? elevation,
  }) {
    return Card(
      elevation: elevation ?? getCardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getBorderRadius(context)),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(getPadding(context)),
        child: child,
      ),
    );
  }

  static Widget responsiveButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
  }) {
    return SizedBox(
      height: height ?? getButtonHeight(context),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(getBorderRadius(context)),
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }

  static InputDecoration responsiveInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getBorderRadius(context)),
      ),
      filled: true,
      fillColor: fillColor ?? Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: getPadding(context),
        vertical: getSpacing(context),
      ),
    );
  }

  static TextStyle responsiveTextStyle({
    required BuildContext context,
    required double baseSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: getFontSize(context, baseSize),
      fontWeight: fontWeight,
      color: color,
    );
  }
} 
import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double smallScreenWidth = 360;
  static const double mediumScreenWidth = 600;
  static const double largeScreenWidth = 840;

  // Get cross axis count for grids based on width
  static int getResponsiveCrossAxisCount(double width) {
    if (width < smallScreenWidth) {
      return 2; // Small phones
    } else if (width < mediumScreenWidth) {
      return 2; // Normal phones
    } else if (width < largeScreenWidth) {
      return 3; // Large phones/small tablets
    } else {
      return 4; // Tablets
    }
  }

  // Get max width for cards and forms
  static double getResponsiveCardMaxWidth(double screenWidth) {
    if (screenWidth < mediumScreenWidth) {
      return screenWidth; // Full width on phones
    } else if (screenWidth < largeScreenWidth) {
      return 500; // Constrained on tablets
    } else {
      return 600; // More space on large tablets
    }
  }

  // Get responsive padding
  static double getResponsivePadding(double width) {
    if (width < smallScreenWidth) {
      return 12;
    } else if (width < mediumScreenWidth) {
      return 16;
    } else if (width < largeScreenWidth) {
      return 20;
    } else {
      return 24;
    }
  }

  // Get responsive chart height
  static double getResponsiveChartHeight(double width) {
    if (width < smallScreenWidth) {
      return 180;
    } else if (width < mediumScreenWidth) {
      return 200;
    } else if (width < largeScreenWidth) {
      return 250;
    } else {
      return 300;
    }
  }

  // Screen type checks
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < smallScreenWidth;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallScreenWidth && width < mediumScreenWidth;
  }

  static bool isLargeScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mediumScreenWidth && width < largeScreenWidth;
  }

  static bool isXLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeScreenWidth;
  }

  // Get responsive font size
  static double getResponsiveFontSize(double width, double baseSize) {
    if (width < smallScreenWidth) {
      return baseSize * 0.9;
    } else if (width < mediumScreenWidth) {
      return baseSize;
    } else {
      return baseSize * 1.1;
    }
  }

  // Get child aspect ratio for grids
  static double getChildAspectRatio(double width) {
    if (width < smallScreenWidth) {
      return 1.2;
    } else if (width < mediumScreenWidth) {
      return 1.3;
    } else {
      return 1.4;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResponsiveHelper {
  static bool isDesktop(BuildContext context) {
    // 首先检查平台类型，只有在真正的桌面平台上才考虑屏幕尺寸
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      final size = MediaQuery.of(context).size;
      return size.width >= 1024;
    }
    // 移动平台（Android/iOS）始终返回false
    return false;
  }

  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 768;
  }
  
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= 600;
  }
  
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 600;
  }
  
  static bool isMediumScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 && size.width < 1200;
  }
  
  static bool isLargeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 1200;
  }
  
  // 获取适合的边距
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }
  
  // 获取适合的卡片边距
  static EdgeInsets getCardMargin(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(10.0);
    } else {
      return const EdgeInsets.all(8.0);
    }
  }
  
  // 获取适合的字体大小
  static double getScaledFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.1;
    } else if (isTablet(context)) {
      return baseSize * 1.05;
    } else {
      return baseSize;
    }
  }
  
  // 获取日历网格的列数
  static int getCalendarColumns(BuildContext context) {
    return 7; // 始终为7列（一周7天）
  }
  
  // 获取日历单元格的高宽比
  static double getCalendarCellAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 1.2;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 0.85; // 移动端需要更高的单元格来容纳公历和农历日期
    }
  }
  
  // 获取适合的圆角半径
  static double getBorderRadius(BuildContext context) {
    if (isDesktop(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 14.0;
    } else {
      return 12.0;
    }
  }
  
  // 获取适合的阴影
  static List<BoxShadow> getCardShadow(BuildContext context) {
    if (isDesktop(context)) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }
  }
  
  // 获取适合的动画持续时间
  static Duration getAnimationDuration(BuildContext context) {
    if (isDesktop(context)) {
      return const Duration(milliseconds: 300);
    } else {
      return const Duration(milliseconds: 250);
    }
  }
  
  // 判断是否应该显示侧边栏
  static bool shouldShowSidebar(BuildContext context) {
    return isLargeScreen(context);
  }
  
  // 获取适合的AppBar高度
  static double getAppBarHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 80.0;
    } else if (isTablet(context)) {
      return 70.0;
    } else {
      return 60.0;
    }
  }
  
  // 获取适合的浮动按钮大小
  static double getFabSize(BuildContext context) {
    if (isDesktop(context)) {
      return 64.0;
    } else if (isTablet(context)) {
      return 60.0;
    } else {
      return 56.0;
    }
  }
}

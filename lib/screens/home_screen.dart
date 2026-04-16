import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calendar_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/date_info_panel.dart';
import '../widgets/enhanced_date_info_panel.dart';
// 移除主题选择器导入，因为不再使用
import '../screens/converter_screen.dart';
import '../screens/weather_screen.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pageController = PageController(initialPage: 0);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 根据主题生成渐变色
  List<Color> _getThemeGradientColors(String themeName) {
    switch (themeName) {
      case 'sunset':
        return [
          const Color(0xFFFF6B35), // 橙红色
          const Color(0xFFFF8E53), // 橙色
          const Color(0xFF4ECDC4), // 青绿色
          const Color(0xFF44A08D), // 深绿色
        ];
      case 'ocean':
        return [
          const Color(0xFF4ECDC4), // 青绿色
          const Color(0xFF45B7D1), // 蓝色
          const Color(0xFF74B9FF), // 浅蓝色
          const Color(0xFF0984E3), // 深蓝色
        ];
      case 'forest':
        return [
          const Color(0xFF6C5CE7), // 紫色
          const Color(0xFFA29BFE), // 浅紫色
          const Color(0xFF00B894), // 绿色
          const Color(0xFF00CEC9), // 青色
        ];
      case 'cherry':
        return [
          const Color(0xFFE84393), // 粉红色
          const Color(0xFFFF7675), // 珊瑚色
          const Color(0xFFFFB8B8), // 浅粉色
          const Color(0xFFFF6B9D), // 深粉色
        ];
      default:
        return [
          const Color(0xFFFF6B35),
          const Color(0xFFFF8E53),
          const Color(0xFF4ECDC4),
          const Color(0xFF44A08D),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50), // 深蓝灰色
              Color(0xFF34495E), // 稍浅的蓝灰色
              Color(0xFF3F51B5), // 深蓝色
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ResponsiveHelper.isLargeScreen(context)
                      ? _buildDesktopLayout()
                      : _buildMobileLayoutWithPages(),
                ),
              ),
            ),
          ),
        ),
      ),

      // 移除浮动按钮，改为页面滑动导航
    );
  }

  Widget _buildDesktopLayout() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final gradientColors = _getThemeGradientColors(themeProvider.currentColorSchemeName);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Row(
        children: [
          // 左侧面板
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  flex: 1,
                  child: const CalendarHeader(),
                ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: ResponsiveHelper.getScreenPadding(context),
                    child: const CalendarGrid(),
                  ),
                ),
              ],
            ),
          ),

          // 右侧信息面板
          Expanded(
            flex: 2,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutCubic,
              )),
              child: Container(
                height: double.infinity,
                padding: ResponsiveHelper.getScreenPadding(context),
                child: const DateInfoPanel(),
              ),
            ),
          ),
        ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayoutWithPages() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final gradientColors = _getThemeGradientColors(themeProvider.currentColorSchemeName);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Column(
            children: [
              // 顶部工具栏
              _buildTopBar(),

              // 页面指示器
              _buildPageIndicator(),

              // 页面内容
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    // 第一页：日历主页
                    _buildCalendarPage(),
                    // 第二页：天气预报
                    _buildWeatherPage(gradientColors),
                    // 第三页：日历转换
                    _buildConverterPage(gradientColors),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final gradientColors = _getThemeGradientColors(themeProvider.currentColorSchemeName);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Column(
            children: [
              // 顶部工具栏
              _buildTopBar(),

              // 日历头部
              const CalendarHeader(),

              // 日历网格 - 适中空间占用
              Expanded(
                flex: 6,
                child: Padding(
                  padding: ResponsiveHelper.getScreenPadding(context),
                  child: const CalendarGrid(),
                ),
              ),

              // 日期信息面板 - 紧凑显示
              Expanded(
                flex: 3,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: const DateInfoPanel(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageDot(0, '日历', Icons.calendar_month),
          const SizedBox(width: 20),
          _buildPageDot(1, '天气', Icons.wb_sunny),
          const SizedBox(width: 20),
          _buildPageDot(2, '转换', Icons.swap_horiz),
        ],
      ),
    );
  }

  Widget _buildPageDot(int index, String label, IconData icon) {
    final isActive = _currentPageIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 应用标题
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '万年历',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          // 主题切换按钮
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () {
                  _showThemeSelector(context);
                },
                icon: Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: '更换主题',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPage() {
    return Column(
      children: [
        // 日历头部 - 铺满整个宽度
        const CalendarHeader(),

        // 日历网格
        Expanded(
          flex: 7,
          child: Padding(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: const CalendarGrid(),
          ),
        ),

        // 增强的日期信息面板
        Expanded(
          flex: 4,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            )),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const EnhancedDateInfoPanel(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherPage(List<Color> gradientColors) {
    return WeatherScreen(gradient: gradientColors);
  }

  Widget _buildConverterPage(List<Color> gradientColors) {
    return ConverterScreen(gradient: gradientColors);
  }

  // 显示主题选择器
  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择主题',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppTheme.colorSchemes.entries.map((entry) {
                    final isSelected = entry.key == themeProvider.currentColorSchemeName;
                    return GestureDetector(
                      onTap: () {
                        themeProvider.setColorScheme(entry.key);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              entry.value.primary,
                              entry.value.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 移除浮动按钮相关代码，改为页面滑动导航
}

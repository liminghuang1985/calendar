import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../services/holiday_service.dart';
import '../utils/responsive_helper.dart';

class CalendarDayCell extends StatefulWidget {
  final CalendarDate calendarDate;
  final bool isCurrentMonth;
  final bool isSelected;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.calendarDate,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<CalendarDayCell>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 1 : 2),
                decoration: BoxDecoration(
                  gradient: _getBackgroundGradient(colorScheme),
                  borderRadius: BorderRadius.circular(12),
                  border: widget.isSelected
                      ? Border.all(
                          color: Colors.white,
                          width: 2,
                        )
                      : null,
                  boxShadow: _hasColorBackground()
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : _isHovered
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 公历日期
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: _getGregorianFontSize(context),
                        fontWeight: widget.calendarDate.isToday || widget.isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: _getTextColor(colorScheme),
                      ),
                      child: Text(widget.calendarDate.gregorianDate.day.toString()),
                    ),

                    // 农历日期
                    if (widget.isCurrentMonth) ...[
                      SizedBox(height: ResponsiveHelper.isMobile(context) ? 1 : 2),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isHovered ? 1.0 : 0.7,
                        child: Text(
                          _getLunarText(),
                          style: TextStyle(
                            fontSize: _getLunarFontSize(context),
                            color: _getLunarTextColor(colorScheme),
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getLunarText() {
    try {
      return widget.calendarDate.lunarDisplayText;
    } catch (e) {
      return '';
    }
  }

  double _getGregorianFontSize(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return _isHovered ? 18 : 16; // 移动端使用较小字体
    } else if (ResponsiveHelper.isTablet(context)) {
      return _isHovered ? 20 : 18;
    } else {
      return _isHovered ? 22 : 20; // 桌面端保持原有大小
    }
  }

  double _getLunarFontSize(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return 10; // 移动端农历字体更小
    } else if (ResponsiveHelper.isTablet(context)) {
      return 11;
    } else {
      return 12; // 桌面端保持原有大小
    }
  }

  Gradient _getBackgroundGradient(ColorScheme colorScheme) {
    // 今天的日期 - 红色高亮
    if (widget.calendarDate.isToday) {
      return const LinearGradient(
        colors: [Color(0xFFFF4757), Color(0xFFFF3742)],
      );
    }

    // 选中的日期 - 橙色高亮
    if (widget.isSelected) {
      return const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
      );
    }

    // 法定假日 - 橙色（这里需要实际的假日判断逻辑）
    if (widget.isCurrentMonth && _isHoliday()) {
      return const LinearGradient(
        colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
      );
    }

    // 周末 - 绿色（但排除调休工作日）
    if (widget.calendarDate.isWeekend && widget.isCurrentMonth && !_isWorkingWeekend()) {
      return const LinearGradient(
        colors: [
          Color(0xFF4CAF50), // 绿色
          Color(0xFF66BB6A), // 浅绿色
        ],
      );
    }

    // 当前月份的工作日 - 半透明白色
    if (widget.isCurrentMonth) {
      return LinearGradient(
        colors: [
          Colors.white.withValues(alpha: _isHovered ? 0.4 : 0.25),
          Colors.white.withValues(alpha: _isHovered ? 0.3 : 0.15),
        ],
      );
    }

    // 非当前月份 - 更淡的显示
    return LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.05),
      ],
    );
  }

  bool _isHoliday() {
    final holidayService = HolidayService();
    return holidayService.isHoliday(widget.calendarDate.gregorianDate);
  }

  bool _isWorkingWeekend() {
    final holidayService = HolidayService();
    return holidayService.isWorkingWeekend(widget.calendarDate.gregorianDate);
  }

  bool _hasColorBackground() {
    return widget.calendarDate.isToday ||
           widget.isSelected ||
           (widget.calendarDate.isWeekend && widget.isCurrentMonth && !_isWorkingWeekend()) ||
           (widget.isCurrentMonth && _isHoliday());
  }

  Color _getTextColor(ColorScheme colorScheme) {
    // 非当前月份 - 淡色显示
    if (!widget.isCurrentMonth) {
      return Colors.white.withValues(alpha: 0.5);
    }

    // 今天、选中、法定假日用白色文字
    if (widget.calendarDate.isToday ||
        widget.isSelected ||
        _isHoliday()) {
      return Colors.white;
    }

    // 周末用白色文字（但排除调休工作日）
    if (widget.calendarDate.isWeekend && !_isWorkingWeekend()) {
      return Colors.white;
    }

    // 普通工作日用深色文字
    return const Color(0xFF2C3E50);
  }

  Color _getLunarTextColor(ColorScheme colorScheme) {
    // 非当前月份 - 淡色显示
    if (!widget.isCurrentMonth) {
      return Colors.white.withValues(alpha: 0.4);
    }

    // 今天、选中、法定假日用白色农历文字
    if (widget.calendarDate.isToday ||
        widget.isSelected ||
        _isHoliday()) {
      return Colors.white.withValues(alpha: 0.8);
    }

    // 周末用白色农历文字（但排除调休工作日）
    if (widget.calendarDate.isWeekend && !_isWorkingWeekend()) {
      return Colors.white.withValues(alpha: 0.8);
    }

    // 普通工作日用深色农历文字
    return const Color(0xFF2C3E50).withValues(alpha: 0.7);
  }
}

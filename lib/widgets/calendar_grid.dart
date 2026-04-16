import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calendar_provider.dart';
import '../utils/responsive_helper.dart';
import 'calendar_day_cell.dart';

class CalendarGrid extends StatefulWidget {
  const CalendarGrid({super.key});

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        if (calendarProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4ECDC4), // 青绿色
                  Color(0xFF44A08D), // 深绿色
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: ResponsiveHelper.getCalendarCellAspectRatio(context),
                crossAxisSpacing: ResponsiveHelper.isMobile(context) ? 1 : 2,
                mainAxisSpacing: ResponsiveHelper.isMobile(context) ? 1 : 2,
              ),
              itemCount: calendarProvider.monthDates.length,
              itemBuilder: (context, index) {
                final calendarDate = calendarProvider.monthDates[index];

              return CalendarDayCell(
                calendarDate: calendarDate,
                isCurrentMonth: _isCurrentMonth(
                  calendarDate.gregorianDate,
                  calendarProvider.currentDate,
                ),
                isSelected: _isSelected(
                  calendarDate.gregorianDate,
                  calendarProvider.selectedDate,
                ),
                onTap: () {
                  calendarProvider.selectDate(calendarDate.gregorianDate);
                },
              );
            },
          ),
        ),
        );
      },
    );
  }
  
  bool _isCurrentMonth(DateTime date, DateTime currentMonth) {
    return date.year == currentMonth.year && date.month == currentMonth.month;
  }
  
  bool _isSelected(DateTime date, DateTime selectedDate) {
    return date.year == selectedDate.year &&
           date.month == selectedDate.month &&
           date.day == selectedDate.day;
  }
}

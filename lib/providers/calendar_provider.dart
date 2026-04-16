import 'package:flutter/material.dart';
import '../models/calendar_date.dart';
import '../services/calendar_service.dart';

class CalendarProvider extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<CalendarDate> _monthDates = [];
  bool _isLoading = false;
  
  DateTime get currentDate => _currentDate;
  DateTime get selectedDate => _selectedDate;
  List<CalendarDate> get monthDates => _monthDates;
  bool get isLoading => _isLoading;
  
  CalendarProvider() {
    _loadMonthDates();
  }
  
  // 设置当前显示的月份
  void setCurrentDate(DateTime date) {
    if (_currentDate.year != date.year || _currentDate.month != date.month) {
      _currentDate = date;
      _loadMonthDates();
    }
  }
  
  // 选择日期
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  // 跳转到今天
  void goToToday() {
    final today = DateTime.now();
    _currentDate = today;
    _selectedDate = today;
    _loadMonthDates();
  }
  
  // 上一个月
  void previousMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    _loadMonthDates();
  }
  
  // 下一个月
  void nextMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    _loadMonthDates();
  }
  
  // 上一年
  void previousYear() {
    _currentDate = DateTime(_currentDate.year - 1, _currentDate.month);
    _loadMonthDates();
  }
  
  // 下一年
  void nextYear() {
    _currentDate = DateTime(_currentDate.year + 1, _currentDate.month);
    _loadMonthDates();
  }
  
  // 加载月份数据
  void _loadMonthDates() {
    _isLoading = true;
    notifyListeners();
    
    _monthDates = _calendarService.getMonthDates(_currentDate.year, _currentDate.month);
    
    _isLoading = false;
    notifyListeners();
  }
  
  // 获取选中日期的详细信息
  CalendarDate? get selectedDateInfo {
    try {
      return _monthDates.firstWhere(
        (date) => 
          date.gregorianDate.year == _selectedDate.year &&
          date.gregorianDate.month == _selectedDate.month &&
          date.gregorianDate.day == _selectedDate.day,
      );
    } catch (e) {
      return null;
    }
  }
  
  // 公历转农历
  Map<String, dynamic> convertGregorianToLunar(DateTime date) {
    return _calendarService.gregorianToLunar(date);
  }
  
  // 农历转公历
  Map<String, dynamic> convertLunarToGregorian(int year, int month, int day, {bool isLeap = false}) {
    return _calendarService.lunarToGregorian(year, month, day, isLeap: isLeap);
  }
  
  // 获取当前月份标题
  String get currentMonthTitle {
    const months = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return '${_currentDate.year}年${months[_currentDate.month - 1]}';
  }
  
  // 获取周标题（周一开头，符合中国日历习惯）
  List<String> get weekTitles => ['一', '二', '三', '四', '五', '六', '日'];
}

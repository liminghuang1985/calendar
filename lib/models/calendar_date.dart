import 'package:lunar/lunar.dart';

class CalendarDate {
  final DateTime gregorianDate;
  final Lunar lunarDate;
  final List<String> festivals;
  final List<String> solarTerms;
  final String? specialNote;
  
  CalendarDate({
    required this.gregorianDate,
    required this.lunarDate,
    this.festivals = const [],
    this.solarTerms = const [],
    this.specialNote,
  });
  
  // 获取农历显示文本（只显示农历，不显示节气和假日）
  String get lunarDisplayText {
    final day = lunarDate.getDay();
    if (day == 1) {
      return lunarDate.getMonthInChinese() + '月';
    }
    return lunarDate.getDayInChinese();
  }
  
  // 获取完整农历日期文本
  String get fullLunarText {
    return '${lunarDate.getYearInGanZhi()}年 ${lunarDate.getMonthInChinese()}月${lunarDate.getDayInChinese()}';
  }
  
  // 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return gregorianDate.year == now.year &&
           gregorianDate.month == now.month &&
           gregorianDate.day == now.day;
  }
  
  // 是否是周末
  bool get isWeekend {
    return gregorianDate.weekday == DateTime.saturday ||
           gregorianDate.weekday == DateTime.sunday;
  }
  
  // 获取所有节日和节气
  List<String> get allEvents {
    final events = <String>[];
    events.addAll(festivals);
    events.addAll(solarTerms);
    return events;
  }
  
  // 获取主要显示的事件（优先级最高的）
  String? get primaryEvent {
    if (festivals.isNotEmpty) return festivals.first;
    if (solarTerms.isNotEmpty) return solarTerms.first;
    return null;
  }
  
  // 是否有特殊事件
  bool get hasEvents {
    return festivals.isNotEmpty || solarTerms.isNotEmpty;
  }
}

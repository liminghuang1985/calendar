import 'package:lunar/lunar.dart';
import '../models/calendar_date.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();
  
  // 传统节日数据
  static const Map<String, String> traditionalFestivals = {
    // 正月节日
    '正月初一': '春节',
    '正月初二': '拜年',
    '正月初三': '赤狗日',
    '正月初五': '破五',
    '正月初七': '人日',
    '正月十五': '元宵节',

    // 二月节日
    '二月初一': '中和节',
    '二月初二': '龙抬头',
    '二月十九': '观音诞',

    // 三月节日
    '三月初三': '上巳节',

    // 四月节日
    '四月初八': '浴佛节',

    // 五月节日
    '五月初五': '端午节',
    '五月十三': '关公诞',

    // 六月节日
    '六月初六': '晒衣节',
    '六月十九': '观音成道日',
    '六月二十四': '关公诞',

    // 七月节日
    '七月初七': '七夕节',
    '七月十五': '中元节',
    '七月三十': '地藏诞',

    // 八月节日
    '八月十五': '中秋节',

    // 九月节日
    '九月初九': '重阳节',
    '九月十九': '观音出家日',

    // 十月节日
    '十月初一': '寒衣节',
    '十月十五': '下元节',

    // 十一月节日
    '十一月十七': '阿弥陀佛诞',

    // 腊月节日
    '腊月初八': '腊八节',
    '腊月二十三': '小年',
    '腊月二十四': '扫尘日',
    '腊月三十': '除夕',
  };
  
  // 现代节日数据
  static const Map<String, String> modernFestivals = {
    '01-01': '元旦',
    '02-14': '情人节',
    '03-08': '妇女节',
    '03-12': '植树节',
    '03-15': '消费者权益日',
    '04-01': '愚人节',
    '04-05': '清明节',
    '04-22': '世界地球日',
    '05-01': '劳动节',
    '05-04': '青年节',
    '05-12': '护士节',
    '06-01': '儿童节',
    '06-05': '世界环境日',
    '07-01': '建党节',
    '08-01': '建军节',
    '08-15': '日本投降日',
    '09-10': '教师节',
    '09-18': '九一八事变',
    '10-01': '国庆节',
    '10-31': '万圣节',
    '11-11': '光棍节',
    '12-13': '南京大屠杀纪念日',
    '12-24': '平安夜',
    '12-25': '圣诞节',
  };
  
  // 根据公历日期创建日历数据
  CalendarDate createCalendarDate(DateTime gregorianDate) {
    try {
      final lunar = Lunar.fromDate(gregorianDate);
      final festivals = _getFestivals(gregorianDate, lunar);
      final solarTerms = _getSolarTerms(lunar);

      return CalendarDate(
        gregorianDate: gregorianDate,
        lunarDate: lunar,
        festivals: festivals,
        solarTerms: solarTerms,
      );
    } catch (e) {
      print('Error creating calendar date for $gregorianDate: $e');
      // 创建一个简单的农历对象作为fallback
      final lunar = Lunar.fromYmd(2025, 1, 1);
      return CalendarDate(
        gregorianDate: gregorianDate,
        lunarDate: lunar,
        festivals: [],
        solarTerms: [],
      );
    }
  }
  
  // 根据农历创建日历数据
  CalendarDate createCalendarDateFromLunar(int year, int month, int day, {bool isLeap = false}) {
    final lunar = Lunar.fromYmd(year, month, day);
    final solar = lunar.getSolar();
    final gregorianDate = DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
    final festivals = _getFestivals(gregorianDate, lunar);
    final solarTerms = _getSolarTerms(lunar);

    return CalendarDate(
      gregorianDate: gregorianDate,
      lunarDate: lunar,
      festivals: festivals,
      solarTerms: solarTerms,
    );
  }
  
  // 获取某月的所有日期数据
  List<CalendarDate> getMonthDates(int year, int month) {
    final dates = <CalendarDate>[];
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    // 添加上个月的日期（填充周视图）
    // 周一=1，周日=7；当月首日是周几，就从周首（周一）往前补几天
    final firstWeekday = firstDay.weekday;
    final prevMonthDays = firstWeekday == DateTime.monday ? 0 : firstWeekday - 1;
    for (int i = prevMonthDays; i > 0; i--) {
      final date = firstDay.subtract(Duration(days: i));
      dates.add(createCalendarDate(date));
    }

    // 添加当月的日期
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(year, month, day);
      dates.add(createCalendarDate(date));
    }
    
    // 添加下个月的日期（填充周视图）
    final remainingDays = 42 - dates.length; // 6周 * 7天
    for (int i = 1; i <= remainingDays; i++) {
      final date = lastDay.add(Duration(days: i));
      dates.add(createCalendarDate(date));
    }
    
    return dates;
  }
  
  // 获取节日信息
  List<String> _getFestivals(DateTime gregorianDate, Lunar lunar) {
    final festivals = <String>[];

    try {
      // 检查现代节日
      final modernKey = '${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
      if (modernFestivals.containsKey(modernKey)) {
        festivals.add(modernFestivals[modernKey]!);
      }

      // 检查传统节日
      final lunarKey = '${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
      if (traditionalFestivals.containsKey(lunarKey)) {
        festivals.add(traditionalFestivals[lunarKey]!);
      }

      // 特殊处理除夕（农历年最后一天）
      if (lunar.getMonth() == 12) {
        final nextDay = lunar.next(1);
        if (nextDay.getMonth() == 1 && nextDay.getDay() == 1) {
          festivals.add('除夕');
        }
      }
    } catch (e) {
      print('Error getting festivals: $e');
    }

    return festivals;
  }
  
  // 获取节气信息
  List<String> _getSolarTerms(Lunar lunar) {
    final solarTerms = <String>[];
    try {
      final jieQi = lunar.getJieQi();
      if (jieQi != null && jieQi.isNotEmpty) {
        solarTerms.add(jieQi);
      }
    } catch (e) {
      print('Error getting solar terms: $e');
    }
    return solarTerms;
  }
  
  // 公历转农历
  Map<String, dynamic> gregorianToLunar(DateTime gregorianDate) {
    final lunar = Lunar.fromDate(gregorianDate);
    return {
      'year': lunar.getYear(),
      'month': lunar.getMonth(),
      'day': lunar.getDay(),
      'yearGanZhi': lunar.getYearInGanZhi(),
      'monthChinese': lunar.getMonthInChinese(),
      'dayChinese': lunar.getDayInChinese(),
      'isLeap': lunar.getMonth() < 0,
      'fullText': '${lunar.getYearInGanZhi()}年 ${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}',
    };
  }
  
  // 农历转公历
  Map<String, dynamic> lunarToGregorian(int year, int month, int day, {bool isLeap = false}) {
    try {
      final lunar = Lunar.fromYmd(year, month, day);
      final solar = lunar.getSolar();
      final gregorianDate = DateTime(solar.getYear(), solar.getMonth(), solar.getDay());

      return {
        'success': true,
        'date': gregorianDate,
        'year': gregorianDate.year,
        'month': gregorianDate.month,
        'day': gregorianDate.day,
        'fullText': '${gregorianDate.year}年${gregorianDate.month}月${gregorianDate.day}日',
      };
    } catch (e) {
      return {
        'success': false,
        'error': '无效的农历日期',
      };
    }
  }
}

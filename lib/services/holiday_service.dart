class HolidayService {
  static final HolidayService _instance = HolidayService._internal();
  factory HolidayService() => _instance;
  HolidayService._internal();

  // 2025年中国法定假日数据
  static const Map<int, Map<String, List<String>>> _holidays = {
    2025: {
      // 元旦假期
      '01-01': ['元旦'],
      
      // 春节假期 (1月28日-2月3日，农历除夕到正月初六)
      '01-28': ['春节调休'],
      '01-29': ['除夕'],
      '01-30': ['春节'],
      '01-31': ['春节'],
      '02-01': ['春节'],
      '02-02': ['春节'],
      '02-03': ['春节'],
      
      // 清明节假期 (4月5日-4月7日)
      '04-05': ['清明节'],
      '04-06': ['清明节'],
      '04-07': ['清明节'],
      
      // 劳动节假期 (5月1日-5月5日)
      '05-01': ['劳动节'],
      '05-02': ['劳动节'],
      '05-03': ['劳动节'],
      '05-04': ['劳动节'],
      '05-05': ['劳动节'],
      
      // 端午节假期 (5月31日-6月2日)
      '05-31': ['端午节'],
      '06-01': ['端午节'],
      '06-02': ['端午节'],
      
      // 中秋节假期 (10月6日-10月8日)
      '10-06': ['中秋节'],
      '10-07': ['中秋节'],
      '10-08': ['中秋节'],
      
      // 国庆节假期 (10月1日-10月5日)
      '10-01': ['国庆节'],
      '10-02': ['国庆节'],
      '10-03': ['国庆节'],
      '10-04': ['国庆节'],
      '10-05': ['国庆节'],
    },
    
    2024: {
      // 元旦假期
      '01-01': ['元旦'],
      
      // 春节假期 (2月10日-2月17日)
      '02-10': ['春节'],
      '02-11': ['除夕'],
      '02-12': ['春节'],
      '02-13': ['春节'],
      '02-14': ['春节'],
      '02-15': ['春节'],
      '02-16': ['春节'],
      '02-17': ['春节'],
      
      // 清明节假期 (4月4日-4月6日)
      '04-04': ['清明节'],
      '04-05': ['清明节'],
      '04-06': ['清明节'],
      
      // 劳动节假期 (5月1日-5月5日)
      '05-01': ['劳动节'],
      '05-02': ['劳动节'],
      '05-03': ['劳动节'],
      '05-04': ['劳动节'],
      '05-05': ['劳动节'],
      
      // 端午节假期 (6月10日-6月12日)
      '06-10': ['端午节'],
      '06-11': ['端午节'],
      '06-12': ['端午节'],
      
      // 中秋节假期 (9月15日-9月17日)
      '09-15': ['中秋节'],
      '09-16': ['中秋节'],
      '09-17': ['中秋节'],
      
      // 国庆节假期 (10月1日-10月7日)
      '10-01': ['国庆节'],
      '10-02': ['国庆节'],
      '10-03': ['国庆节'],
      '10-04': ['国庆节'],
      '10-05': ['国庆节'],
      '10-06': ['国庆节'],
      '10-07': ['国庆节'],
    },
  };

  // 调休工作日数据（原本是周末但需要上班的日子）
  static const Map<int, List<String>> _workingWeekends = {
    2025: [
      '01-26', // 春节调休
      '02-08', // 春节调休
      '04-27', // 劳动节调休
      '09-28', // 国庆节调休
      '10-11', // 国庆节调休
    ],
    2024: [
      '02-04', // 春节调休
      '02-18', // 春节调休
      '04-07', // 清明节调休
      '04-28', // 劳动节调休
      '05-11', // 劳动节调休
      '09-14', // 中秋节调休
      '09-29', // 国庆节调休
      '10-12', // 国庆节调休
    ],
  };

  /// 判断指定日期是否为法定假日
  bool isHoliday(DateTime date) {
    final year = date.year;
    final monthDay = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return _holidays[year]?.containsKey(monthDay) ?? false;
  }

  /// 判断指定日期是否为调休工作日（原本是周末但需要上班）
  bool isWorkingWeekend(DateTime date) {
    final year = date.year;
    final monthDay = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return _workingWeekends[year]?.contains(monthDay) ?? false;
  }

  /// 获取指定日期的假日名称
  List<String> getHolidayNames(DateTime date) {
    final year = date.year;
    final monthDay = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return _holidays[year]?[monthDay] ?? [];
  }

  /// 判断是否为实际的休息日（包括周末和法定假日，排除调休工作日）
  bool isRestDay(DateTime date) {
    // 如果是调休工作日，则不是休息日
    if (isWorkingWeekend(date)) {
      return false;
    }
    
    // 如果是法定假日，则是休息日
    if (isHoliday(date)) {
      return true;
    }
    
    // 如果是周末且不是调休工作日，则是休息日
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// 获取日期类型描述
  String getDateTypeDescription(DateTime date) {
    if (isWorkingWeekend(date)) {
      return '调休工作日';
    }
    
    final holidayNames = getHolidayNames(date);
    if (holidayNames.isNotEmpty) {
      return holidayNames.first;
    }
    
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return '周末';
    }
    
    return '工作日';
  }
}

import 'package:lunar/lunar.dart';

void main() {
  print('=== 2025年关键节日验证 ===\n');

  // 测试公历→农历转换
  final gregToLunar = [
    DateTime(2025, 1, 1),   // 元旦
    DateTime(2025, 1, 29),  // 春节(正月初一)
    DateTime(2025, 4, 4),   // 清明
    DateTime(2025, 5, 31),  // 端午附近(农历五月初五)
    DateTime(2025, 6, 1),   // 儿童节
    DateTime(2025, 10, 1),  // 国庆
    DateTime(2025, 1, 28),  // 除夕前天
    DateTime(2025, 1, 29),  // 除夕? (正月初一前一天?)
  ];

  for (final d in gregToLunar) {
    final lunar = Lunar.fromDate(d);
    print('公历 $d → 农历: ${lunar.getYearInGanZhi()}年 ${lunar.getMonthInChinese()}月${lunar.getDayInChinese()} (月=${lunar.getMonth()}, 日=${lunar.getDay()})');
    print('  getJieQi() = "${lunar.getJieQi()}"');
    print('');
  }

  print('=== 农历→公历验证 ===\n');
  // 测试农历→公历转换
  for (final lunar in [
    Lunar.fromYmd(2025, 1, 1),    // 春节
    Lunar.fromYmd(2025, 5, 5),    // 端午
    Lunar.fromYmd(2024, 1, 1),    // 2024春节
  ]) {
    final solar = lunar.getSolar();
    print('农历 ${lunar.getMonthInChinese()}月${lunar.getDayInChinese()} → 公历 ${solar.getYear()}-${solar.getMonth()}-${solar.getDay()}');
  }
}

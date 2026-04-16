import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import '../services/holiday_service.dart';
import '../utils/responsive_helper.dart';
import 'current_weather_card.dart';
import 'weather_forecast_list.dart';

class EnhancedDateInfoPanel extends StatelessWidget {
  const EnhancedDateInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        final selectedDateInfo = calendarProvider.selectedDateInfo;
        final holidayService = HolidayService();

        // 如果没有选中日期信息，显示空状态
        if (selectedDateInfo == null) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text('请选择日期'),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日期标题区域
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 公历日期
                      Text(
                        '${selectedDateInfo.gregorianDate.year}年${selectedDateInfo.gregorianDate.month}月${selectedDateInfo.gregorianDate.day}日',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 农历日期
                      Text(
                        selectedDateInfo.fullLunarText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFD84315),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 节气和法定假日信息（主要显示区域）
                _buildMainInfoSection(context, selectedDateInfo, holidayService),

                // 天气信息（仅在桌面端显示）
                if (ResponsiveHelper.isLargeScreen(context)) ...[
                  const SizedBox(height: 16),
                  // 城市选择器
                  _buildCitySelector(),
                  const SizedBox(height: 12),
                  const CurrentWeatherCard(isCompact: true),
                  const SizedBox(height: 12),
                  const WeatherForecastList(isCompact: true, maxItems: 7),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainInfoSection(BuildContext context, dynamic selectedDateInfo, HolidayService holidayService) {
    final date = selectedDateInfo.gregorianDate;
    final holidays = holidayService.getHolidayNames(date);
    final solarTerms = selectedDateInfo.solarTerms;
    final festivals = selectedDateInfo.festivals;

    // 分离法定假日和传统节日
    final traditionalFestivals = <String>[];
    final modernFestivals = <String>[];

    for (final festival in festivals) {
      // 根据节日名称判断是传统节日还是现代节日
      if (_isTraditionalFestival(festival)) {
        traditionalFestivals.add(festival);
      } else {
        modernFestivals.add(festival);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 法定假日信息
        if (holidays.isNotEmpty)
          _buildHighlightCard(
            Icons.celebration,
            '法定假日',
            holidays.join('、'),
            const Color(0xFFE91E63),
          ),

        // 传统节日信息
        if (traditionalFestivals.isNotEmpty) ...[
          if (holidays.isNotEmpty) const SizedBox(height: 12),
          _buildHighlightCard(
            Icons.temple_buddhist,
            '传统节日',
            traditionalFestivals.join('、'),
            const Color(0xFFD32F2F),
          ),
        ],

        // 二十四节气信息
        if (solarTerms.isNotEmpty) ...[
          if (holidays.isNotEmpty || traditionalFestivals.isNotEmpty) const SizedBox(height: 12),
          _buildHighlightCard(
            Icons.wb_sunny,
            '二十四节气',
            solarTerms.join('、'),
            const Color(0xFFFF9800),
          ),
        ],

        // 现代节日信息（非法定假日的现代节日）
        if (modernFestivals.isNotEmpty) ...[
          if (holidays.isNotEmpty || traditionalFestivals.isNotEmpty || solarTerms.isNotEmpty) const SizedBox(height: 12),
          _buildHighlightCard(
            Icons.event,
            '节日',
            modernFestivals.join('、'),
            const Color(0xFF7B1FA2),
          ),
        ],

        // 如果什么都没有，显示提示信息
        if (holidays.isEmpty && traditionalFestivals.isEmpty && solarTerms.isEmpty && modernFestivals.isEmpty)
          _buildHighlightCard(
            Icons.info_outline,
            '日期信息',
            '今日无特殊节气或节日',
            Colors.grey,
          ),
      ],
    );
  }

  // 判断是否为传统节日
  bool _isTraditionalFestival(String festival) {
    const traditionalFestivalNames = {
      // 正月节日
      '春节', '拜年', '赤狗日', '破五', '人日', '元宵节',
      // 二月节日
      '中和节', '龙抬头', '观音诞',
      // 三月节日
      '上巳节',
      // 四月节日
      '浴佛节',
      // 五月节日
      '端午节', '关公诞',
      // 六月节日
      '晒衣节', '观音成道日',
      // 七月节日
      '七夕节', '中元节', '地藏诞',
      // 八月节日
      '中秋节',
      // 九月节日
      '重阳节', '观音出家日',
      // 十月节日
      '寒衣节', '下元节',
      // 十一月节日
      '阿弥陀佛诞',
      // 腊月节日
      '腊八节', '小年', '扫尘日', '除夕'
    };
    return traditionalFestivalNames.contains(festival);
  }



  Widget _buildHighlightCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    // 这里可以添加城市选择器的实现
    return const SizedBox.shrink();
  }

  // 移除不再需要的周数和星期相关方法
}

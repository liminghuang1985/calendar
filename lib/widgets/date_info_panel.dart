import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/calendar_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/responsive_helper.dart';
import 'current_weather_card.dart';
import 'weather_forecast_list.dart';

class DateInfoPanel extends StatefulWidget {
  const DateInfoPanel({super.key});

  @override
  State<DateInfoPanel> createState() => _DateInfoPanelState();
}

class _DateInfoPanelState extends State<DateInfoPanel> {
  // 预定义的城市列表
  final List<Map<String, String>> _cities = [
    {'name': '北京市', 'code': 'Beijing'},
    {'name': '珠海市', 'code': 'Zhuhai'},
    {'name': '随州市', 'code': 'Suizhou'},
  ];

  String _selectedCity = 'Beijing'; // 默认选择北京

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  /// 加载保存的城市选择
  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('selected_city') ?? 'Beijing';
    setState(() {
      _selectedCity = savedCity;
    });
  }

  /// 保存城市选择
  Future<void> _saveSelectedCity(String cityCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', cityCode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        final selectedDateInfo = calendarProvider.selectedDateInfo;

        if (selectedDateInfo == null) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '点击日期查看详情',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
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

                // 详细信息网格
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.calendar_today,
                        '星期',
                        _getWeekdayFull(selectedDateInfo.gregorianDate.weekday),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.date_range,
                        '第几周',
                        '第${_getWeekOfYear(selectedDateInfo.gregorianDate)}周',
                      ),
                    ),
                  ],
                ),

                // 节日和节气信息
                if (selectedDateInfo.festivals.isNotEmpty || selectedDateInfo.solarTerms.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  if (selectedDateInfo.festivals.isNotEmpty)
                    _buildHighlightCard(
                      Icons.celebration,
                      '节日',
                      selectedDateInfo.festivals.join('、'),
                      const Color(0xFFE91E63),
                    ),

                  if (selectedDateInfo.solarTerms.isNotEmpty) ...[
                    if (selectedDateInfo.festivals.isNotEmpty) const SizedBox(height: 8),
                    _buildHighlightCard(
                      Icons.wb_sunny,
                      '节气',
                      selectedDateInfo.solarTerms.join('、'),
                      const Color(0xFFFF9800),
                    ),
                  ],
                ],

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

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  String _getWeekdayFull(int weekday) {
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return weekdays[weekday - 1];
  }

  /// 构建城市选择器
  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_city,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '当前城市：${_cities.firstWhere((city) => city['code'] == _selectedCity)['name']}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _showCityDialog,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text('切换'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示城市选择对话框
  void _showCityDialog() {
    String tempSelectedCity = _selectedCity;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择城市'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请选择要查看天气的城市：'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: tempSelectedCity,
                    isExpanded: true,
                    items: _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city['code'],
                        child: Text(city['name']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          tempSelectedCity = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _selectedCity = tempSelectedCity;
              });
              await _saveSelectedCity(tempSelectedCity);
              context.read<WeatherProvider>().changeCity(tempSelectedCity);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

}

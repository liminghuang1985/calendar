import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/weather_forecast_list.dart';
import '../utils/weather_cache_manager.dart';

class WeatherScreen extends StatefulWidget {
  final List<Color>? gradient;

  const WeatherScreen({super.key, this.gradient});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  final List<Map<String, String>> _cities = [
    {'name': '北京市', 'code': 'Beijing'},
    {'name': '珠海市', 'code': 'Zhuhai'},
    {'name': '随州市', 'code': 'Suizhou'},
  ];

  String _selectedCity = 'Beijing';

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('selected_city') ?? 'Beijing';
    setState(() {
      _selectedCity = savedCity;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeatherDataSmart(cityName: _selectedCity);
    });
  }

  Future<void> _saveSelectedCity(String cityCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', cityCode);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _showCacheStats() async {
    final stats = await WeatherCacheManager.getCacheStats();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('缓存状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总缓存数: ${stats['totalCaches']}'),
            Text('有效缓存: ${stats['validCaches']}'),
            Text('过期缓存: ${stats['expiredCaches']}'),
            const SizedBox(height: 16),
            const Text('缓存策略:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• 缓存有效期: 5分钟'),
            const Text('• 最小请求间隔: 30秒'),
            const Text('• 每小时最大请求: 60次'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await WeatherCacheManager.cleanExpiredCache();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已清理过期缓存')),
              );
            },
            child: const Text('清理缓存'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colorScheme = themeProvider.currentColorScheme;
        // 优先用外部传入的 gradient，否则用 colorScheme 生成
        final List<Color> topColors = widget.gradient ?? [colorScheme.primary, colorScheme.secondary];

        return Scaffold(
          appBar: AppBar(
            title: const Text('天气预报'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: topColors,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showCityDialog,
                icon: const Icon(Icons.location_city),
                tooltip: '切换城市',
              ),
              IconButton(
                onPressed: () {
                  context.read<WeatherProvider>().refreshWeatherData();
                },
                icon: const Icon(Icons.refresh),
                tooltip: '刷新',
              ),
              if (kDebugMode)
                IconButton(
                  onPressed: _showCacheStats,
                  icon: const Icon(Icons.info_outline),
                  tooltip: '缓存状态',
                ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  topColors.first.withValues(alpha: 0.3),
                  topColors.last.withValues(alpha: 0.2),
                  colorScheme.surface,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<WeatherProvider>().refreshWeatherData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
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
                            const Icon(Icons.location_on, color: Colors.blue, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '当前城市：${_cities.firstWhere((city) => city['code'] == _selectedCity)['name']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showCityDialog,
                              icon: const Icon(Icons.swap_horiz, size: 18),
                              label: const Text('切换'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const CurrentWeatherCard(),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const WeatherForecastList(),
                      ),
                      const SizedBox(height: 20),
                      _buildWeatherTipsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherTipsCard() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.currentWeather == null) {
          return const SizedBox.shrink();
        }
        final weather = weatherProvider.currentWeather!;
        final tips = _getWeatherTips(weather.description, weather.temperature);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '生活建议',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: Text(tip, style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  List<String> _getWeatherTips(String description, double temperature) {
    final tips = <String>[];
    if (temperature < 0) {
      tips.add('气温较低，注意保暖，外出时穿厚外套');
      tips.add('路面可能结冰，出行注意安全');
    } else if (temperature < 10) {
      tips.add('天气较冷，建议穿长袖衣物');
      tips.add('早晚温差大，注意增减衣物');
    } else if (temperature > 30) {
      tips.add('气温较高，注意防暑降温');
      tips.add('多喝水，避免长时间户外活动');
    } else if (temperature > 25) {
      tips.add('天气温暖，适合户外活动');
      tips.add('注意防晒，可穿轻薄衣物');
    }
    if (description.contains('雨')) {
      tips.add('有降雨，出门记得带伞');
      tips.add('路面湿滑，驾车注意安全');
    } else if (description.contains('雪')) {
      tips.add('有降雪，注意保暖和防滑');
      tips.add('能见度可能较低，出行谨慎');
    } else if (description.contains('雾')) {
      tips.add('有雾天气，能见度较低');
      tips.add('驾车开启雾灯，减速慢行');
    } else if (description.contains('晴')) {
      tips.add('天气晴朗，适合外出活动');
      tips.add('紫外线较强，注意防晒');
    }
    if (tips.isEmpty) {
      tips.add('关注天气变化，合理安排出行');
      tips.add('保持良好的生活习惯');
    }
    return tips;
  }

  void _showCityDialog() {
    String tempSelectedCity = _selectedCity;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _selectedCity = tempSelectedCity;
              });
              await _saveSelectedCity(tempSelectedCity);
              this.context.read<WeatherProvider>().changeCity(tempSelectedCity);
              Navigator.pop(dialogContext);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

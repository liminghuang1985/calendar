import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  // OpenWeatherMap API密钥 - 免费计划：每分钟60次调用，每月100万次调用
  static const String _apiKey = '6275c0823484f7925357ff9cb7dbf00b';
  
  // 默认城市（北京）
  static const double _defaultLat = 39.9042;
  static const double _defaultLon = 116.4074;

  /// 获取当前天气
  Future<Weather?> getCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
  }) async {
    // 如果没有有效的API密钥，直接返回模拟数据
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.isEmpty) {
      print('🔧 使用模拟天气数据（未配置API密钥）- 城市: ${cityName ?? "默认"}');
      return _getMockCurrentWeather(cityName: cityName);
    }

    try {
      String url;
      if (cityName != null) {
        url = '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=zh';
      } else {
        final latitude = lat ?? _defaultLat;
        final longitude = lon ?? _defaultLon;
        url = '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=zh';
      }

      print('🌐 请求天气API: $url'); // 调试信息
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ 天气数据获取成功: ${data['name']}, 温度: ${data['main']['temp']}°C, 描述: ${data['weather'][0]['description']}'); // 调试信息
        print('🌐 API响应数据: ${response.body.substring(0, 200)}...'); // 显示部分响应数据
        return Weather.fromJson(data);
      } else {
        print('❌ 获取天气失败: ${response.statusCode}, 响应: ${response.body}');
        print('🔧 切换到模拟数据 - 城市: ${cityName ?? "默认"}');
        return _getMockCurrentWeather(cityName: cityName);
      }
    } catch (e) {
      print('天气服务错误: $e');
      return _getMockCurrentWeather(cityName: cityName);
    }
  }

  /// 获取5天天气预报
  Future<List<WeatherForecast>> getWeatherForecast({
    double? lat,
    double? lon,
    String? cityName,
  }) async {
    // 如果没有有效的API密钥，直接返回模拟数据
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.isEmpty) {
      print('使用模拟天气预报数据（未配置API密钥）');
      return _getMockForecast(cityName: cityName).take(5).toList(); // 只返回5天模拟数据
    }

    try {
      // 使用免费的5天预报API
      double latitude = lat ?? _defaultLat;
      double longitude = lon ?? _defaultLon;

      if (cityName != null) {
        final coords = await _getCityCoordinates(cityName);
        if (coords != null) {
          latitude = coords['lat']!;
          longitude = coords['lon']!;
        }
      }

      // 使用免费的5天预报API
      final url = '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=zh';

      print('请求预报API: $url'); // 调试信息
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final forecastList = data['list'] as List;
        print('预报数据获取成功: ${forecastList.length}条'); // 调试信息

        // 处理5天预报数据，按天聚合计算真实的最高/最低温度
        final dailyForecasts = <WeatherForecast>[];
        final dailyData = <String, List<Map<String, dynamic>>>{};

        // 按日期分组数据
        for (final item in forecastList) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

          if (!dailyData.containsKey(dateKey)) {
            dailyData[dateKey] = [];
          }
          dailyData[dateKey]!.add(item);
        }

        // 为每一天计算真实的最高/最低温度
        for (final entry in dailyData.entries.take(5)) {
          final dayData = entry.value;
          if (dayData.isEmpty) continue;

          // 计算当天的最高和最低温度
          double maxTemp = double.negativeInfinity;
          double minTemp = double.infinity;
          double totalHumidity = 0;
          double totalWindSpeed = 0;
          String description = '';
          String icon = '';
          DateTime representativeTime = DateTime.fromMillisecondsSinceEpoch(dayData.first['dt'] * 1000);

          for (final item in dayData) {
            final temp = (item['main']['temp'] as num).toDouble();
            maxTemp = maxTemp > temp ? maxTemp : temp;
            minTemp = minTemp < temp ? minTemp : temp;
            totalHumidity += item['main']['humidity'] ?? 0;
            totalWindSpeed += (item['wind']['speed'] as num?)?.toDouble() ?? 0.0;

            // 使用中午时段的天气描述和图标
            final itemTime = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
            if (itemTime.hour >= 12 && itemTime.hour <= 15) {
              description = item['weather'][0]['description'] ?? '';
              icon = item['weather'][0]['icon'] ?? '';
            }
          }

          // 如果没有中午时段的数据，使用第一个数据的描述
          if (description.isEmpty) {
            description = dayData.first['weather'][0]['description'] ?? '';
            icon = dayData.first['weather'][0]['icon'] ?? '';
          }

          dailyForecasts.add(WeatherForecast(
            date: representativeTime,
            maxTemp: maxTemp,
            minTemp: minTemp,
            description: description,
            icon: icon,
            humidity: (totalHumidity / dayData.length).round(),
            windSpeed: totalWindSpeed / dayData.length,
          ));
        }

        // 返回处理后的5天预报数据
        return dailyForecasts;
      } else {
        print('获取天气预报失败: ${response.statusCode}, 响应: ${response.body}');
        return _getMockForecast(cityName: cityName).take(5).toList(); // 只返回5天模拟数据
      }
    } catch (e) {
      print('天气预报服务错误: $e');
      return _getMockForecast(cityName: cityName).take(5).toList(); // 只返回5天模拟数据
    }
  }

  /// 根据城市名获取坐标
  Future<Map<String, double>?> _getCityCoordinates(String cityName) async {
    try {
      final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          return {
            'lat': data[0]['lat'].toDouble(),
            'lon': data[0]['lon'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      print('获取城市坐标错误: $e');
      return null;
    }
  }

  /// 测试API密钥是否有效
  Future<bool> testApiKey() async {
    try {
      // 测试当前天气API
      final weatherUrl = '$_baseUrl/weather?q=Beijing&appid=$_apiKey&units=metric';
      print('🧪 测试当前天气API: $weatherUrl');
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      print('📊 当前天气API响应: ${weatherResponse.statusCode}');

      // 测试5天预报API
      final forecastUrl = '$_baseUrl/forecast?q=Beijing&appid=$_apiKey&units=metric';
      print('🧪 测试5天预报API: $forecastUrl');
      final forecastResponse = await http.get(Uri.parse(forecastUrl));
      print('📊 5天预报API响应: ${forecastResponse.statusCode}');

      if (weatherResponse.statusCode != 200) {
        print('❌ 当前天气API失败: ${weatherResponse.body}');
      }
      if (forecastResponse.statusCode != 200) {
        print('❌ 5天预报API失败: ${forecastResponse.body}');
      }

      // 只要有一个API可用就返回true
      final isValid = weatherResponse.statusCode == 200 || forecastResponse.statusCode == 200;
      print(isValid ? '✅ API密钥验证成功' : '❌ API密钥验证失败');

      return isValid;
    } catch (e) {
      print('🚨 API测试错误: $e');
      return false;
    }
  }

  /// 模拟当前天气数据（用于演示和API失败时的备用）
  Weather _getMockCurrentWeather({String? cityName}) {
    final city = cityName ?? '北京';
    print('🔧 正在使用模拟天气数据 - 城市: $city'); // 调试信息

    // 根据城市名称生成不同的模拟数据
    final cityHash = city.hashCode.abs();
    final baseTemp = 18.0 + (cityHash % 18); // 18-36度范围
    final humidity = 30 + (cityHash % 40); // 30-70%范围
    final windSpeed = 1.0 + ((cityHash % 50) / 10); // 1-6 m/s范围

    final descriptions = ['晴', '多云', '阴', '小雨', '晴转多云'];
    final icons = ['01d', '02d', '03d', '10d', '02d'];
    final winds = ['东北', '西南', '东', '北', '西北'];

    final descIndex = cityHash % descriptions.length;

    return Weather(
      cityName: city,
      temperature: baseTemp,
      description: descriptions[descIndex],
      icon: icons[descIndex],
      humidity: humidity,
      windSpeed: windSpeed,
      windDirection: winds[descIndex],
      pressure: 1010 + (cityHash % 20), // 1010-1030 hPa
      visibility: 8000 + (cityHash % 5000), // 8-13km
      updateTime: DateTime.now(),
    );
  }

  /// 生成单个模拟预报数据
  WeatherForecast _generateMockForecast(DateTime date, int index, {String? cityName}) {
    final descriptions = ['晴', '多云', '阴', '小雨', '中雨', '雷阵雨', '雪'];
    final icons = ['01d', '02d', '03d', '10d', '10d', '11d', '13d'];

    // 根据城市和日期生成不同的数据
    final cityHash = (cityName ?? 'default').hashCode.abs();
    final dateHash = date.day + date.month * 31;
    final combinedHash = (cityHash + dateHash + index) % 1000;

    final descIndex = combinedHash % descriptions.length;
    final baseMaxTemp = 20.0 + (cityHash % 15); // 基础最高温度
    final baseminTemp = 10.0 + (cityHash % 12); // 基础最低温度

    return WeatherForecast(
      date: date,
      maxTemp: baseMaxTemp + (combinedHash % 8) - 4, // 在基础温度上下浮动
      minTemp: baseminTemp + (combinedHash % 6) - 3,
      description: descriptions[descIndex],
      icon: icons[descIndex],
      humidity: 35 + (combinedHash % 35), // 35-70%
      windSpeed: 1.5 + ((combinedHash % 40) / 10), // 1.5-5.5 m/s
    );
  }

  /// 模拟15天天气预报数据
  List<WeatherForecast> _getMockForecast({String? cityName}) {
    final now = DateTime.now();
    final forecasts = <WeatherForecast>[];

    for (int i = 0; i < 15; i++) {
      final date = now.add(Duration(days: i));
      forecasts.add(_generateMockForecast(date, i, cityName: cityName));
    }

    return forecasts;
  }

  /// 获取天气图标URL
  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  /// 根据天气描述获取本地图标
  String getLocalWeatherIcon(String description) {
    if (description.contains('晴')) return '☀️';
    if (description.contains('云')) return '☁️';
    if (description.contains('阴')) return '🌫️';
    if (description.contains('雨')) return '🌧️';
    if (description.contains('雷')) return '⛈️';
    if (description.contains('雪')) return '❄️';
    if (description.contains('雾')) return '🌫️';
    return '🌤️';
  }
}

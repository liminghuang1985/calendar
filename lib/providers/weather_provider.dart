import 'package:flutter/foundation.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../utils/weather_cache_manager.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  String _currentCity = 'Beijing';

  // Getters
  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCity => _currentCity;
  
  Weather? get currentWeather => _weatherData?.current;
  List<WeatherForecast> get forecast => _weatherData?.forecast ?? [];
  
  bool get hasData => _weatherData != null;
  bool get needsRefresh => _weatherData?.isStale ?? true;

  /// 初始化天气数据
  Future<void> initialize() async {
    // 先测试API密钥
    final isApiValid = await _weatherService.testApiKey();
    if (isApiValid) {
      debugPrint('✅ OpenWeatherMap API密钥验证成功');
    } else {
      debugPrint('❌ OpenWeatherMap API密钥验证失败，将使用模拟数据');
    }

    await loadWeatherData();
  }

  /// 加载天气数据
  Future<void> loadWeatherData({String? cityName}) async {
    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      final city = cityName ?? _currentCity;

      // 记录API请求
      await WeatherCacheManager.recordRequest(city);

      // 并行获取当前天气和预报
      final results = await Future.wait([
        _weatherService.getCurrentWeather(cityName: city),
        _weatherService.getWeatherForecast(cityName: city),
      ]);

      final currentWeather = results[0] as Weather?;
      final forecastList = results[1] as List<WeatherForecast>;

      if (currentWeather != null) {
        _weatherData = WeatherData(
          current: currentWeather,
          forecast: forecastList,
          lastUpdated: DateTime.now(),
        );

        if (cityName != null) {
          _currentCity = cityName;
        }

        _error = null;
        notifyListeners(); // 立即通知UI更新

        // 清理过期缓存（异步执行，不阻塞UI）
        WeatherCacheManager.cleanExpiredCache();
      } else {
        _error = '无法获取天气数据';
        notifyListeners(); // 通知UI显示错误
      }
    } catch (e) {
      _error = '天气数据加载失败: $e';
      debugPrint('Weather loading error: $e');
      notifyListeners(); // 通知UI显示错误
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新天气数据
  Future<void> refreshWeatherData() async {
    await loadWeatherData();
  }

  /// 切换城市
  Future<void> changeCity(String cityName) async {
    if (cityName.trim().isEmpty) return;

    final newCity = cityName.trim();

    // 如果城市没有变化且数据仍然有效，则不需要重新加载
    if (_currentCity == newCity && hasData && !needsRefresh) {
      debugPrint('🔄 天气数据仍然有效，跳过刷新 - 城市: $newCity');
      return;
    }

    // 先更新当前城市，再加载数据
    _currentCity = newCity;
    await loadWeatherData(cityName: newCity);
  }

  /// 智能加载天气数据（带缓存检查）
  Future<void> loadWeatherDataSmart({String? cityName}) async {
    final city = cityName ?? _currentCity;

    // 1. 检查内存缓存是否有效
    if (_currentCity == city && hasData && !needsRefresh) {
      debugPrint('🔄 内存缓存有效，跳过刷新 - 城市: $city');
      return;
    }

    // 2. 检查本地缓存是否有效
    final isCacheValid = await WeatherCacheManager.isCacheValid(city);
    if (isCacheValid) {
      debugPrint('🔄 本地缓存有效，跳过API请求 - 城市: $city');
      // 可以选择从本地缓存加载数据，这里暂时跳过以保持简单
      return;
    }

    // 3. 检查是否可以发起API请求
    final canRequest = await WeatherCacheManager.canMakeRequest(city);
    if (!canRequest) {
      debugPrint('🚫 请求被限制，使用现有数据 - 城市: $city');
      return;
    }

    // 4. 发起API请求
    await loadWeatherData(cityName: cityName);
  }

  /// 根据坐标获取天气
  Future<void> loadWeatherByLocation(double lat, double lon) async {
    if (_isLoading) return;
    
    _setLoading(true);
    _error = null;
    
    try {
      final results = await Future.wait([
        _weatherService.getCurrentWeather(lat: lat, lon: lon),
        _weatherService.getWeatherForecast(lat: lat, lon: lon),
      ]);
      
      final currentWeather = results[0] as Weather?;
      final forecastList = results[1] as List<WeatherForecast>;
      
      if (currentWeather != null) {
        _weatherData = WeatherData(
          current: currentWeather,
          forecast: forecastList,
          lastUpdated: DateTime.now(),
        );

        _currentCity = currentWeather.cityName;
        _error = null;
        notifyListeners(); // 立即通知UI更新
      } else {
        _error = '无法获取天气数据';
        notifyListeners(); // 通知UI显示错误
      }
    } catch (e) {
      _error = '天气数据加载失败: $e';
      debugPrint('Weather loading error: $e');
      notifyListeners(); // 通知UI显示错误
    } finally {
      _setLoading(false);
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 获取天气图标
  String getWeatherIcon(String description) {
    return _weatherService.getLocalWeatherIcon(description);
  }

  /// 获取天气图标URL
  String getWeatherIconUrl(String iconCode) {
    return _weatherService.getWeatherIconUrl(iconCode);
  }

  /// 格式化更新时间
  String get lastUpdateTime {
    if (_weatherData == null) return '';
    
    final now = DateTime.now();
    final lastUpdate = _weatherData!.lastUpdated;
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return '刚刚更新';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前更新';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前更新';
    } else {
      return '${lastUpdate.month}/${lastUpdate.day} ${lastUpdate.hour}:${lastUpdate.minute.toString().padLeft(2, '0')} 更新';
    }
  }

  /// 获取今天的预报
  WeatherForecast? get todayForecast {
    if (forecast.isEmpty) return null;
    
    final today = DateTime.now();
    return forecast.firstWhere(
      (f) => f.date.day == today.day && f.date.month == today.month,
      orElse: () => forecast.first,
    );
  }

  /// 获取未来几天的预报（排除今天）
  List<WeatherForecast> get upcomingForecast {
    if (forecast.isEmpty) return [];

    final today = DateTime.now();
    return forecast.where((f) =>
      f.date.isAfter(DateTime(today.year, today.month, today.day))
    ).toList();
  }

  /// 获取缓存状态信息
  String get cacheStatusInfo {
    if (!hasData) return '无数据';

    final remaining = _weatherData!.cacheRemainingMinutes;
    if (remaining > 0) {
      return '缓存有效 (${remaining}分钟)';
    } else {
      return '缓存已过期';
    }
  }

  /// 是否应该显示缓存状态
  bool get shouldShowCacheStatus => hasData;
}

class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final int pressure;
  final int visibility;
  final DateTime updateTime;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.updateTime,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? '未知城市',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: _getWindDirection(json['wind']['deg'] ?? 0),
      pressure: json['main']['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      updateTime: DateTime.now(),
    );
  }

  static String _getWindDirection(int degree) {
    const directions = ['北', '东北', '东', '东南', '南', '西南', '西', '西北'];
    int index = ((degree + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  String get temperatureString => '${temperature.round()}°C';
  String get humidityString => '$humidity%';
  String get windString => '$windDirection风 ${windSpeed.toStringAsFixed(1)}m/s';
  String get pressureString => '${pressure}hPa';
  String get visibilityString => '${(visibility / 1000).toStringAsFixed(1)}km';

  /// 获取风力等级字符串（需要导入wind_scale_converter）
  String getWindLevelString() {
    // 这个方法将在使用时通过WindScaleConverter调用
    return '$windDirection风 ${windSpeed.toStringAsFixed(1)}m/s';
  }
}

class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      minTemp: (json['temp']['min'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get maxTempString => '${maxTemp.round()}°';
  String get minTempString => '${minTemp.round()}°';
  String get tempRangeString => '$minTempString ~ $maxTempString';
  String get dateString => '${date.month}/${date.day}';
  String get weekdayString {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.weekday % 7];
  }
}

class WeatherData {
  final Weather current;
  final List<WeatherForecast> forecast;
  final DateTime lastUpdated;

  WeatherData({
    required this.current,
    required this.forecast,
    required this.lastUpdated,
  });

  bool get isStale {
    return DateTime.now().difference(lastUpdated).inMinutes > 5;
  }

  /// 获取缓存剩余时间（分钟）
  int get cacheRemainingMinutes {
    final elapsed = DateTime.now().difference(lastUpdated).inMinutes;
    return (5 - elapsed).clamp(0, 5);
  }
}

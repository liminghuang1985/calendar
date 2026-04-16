/// 蒲福风力等级转换工具
/// 将风速(m/s)转换为蒲福风力等级(0-12级)
class WindScaleConverter {
  /// 蒲福风力等级数据
  static const List<Map<String, dynamic>> _windScales = [
    {
      'level': 0,
      'name': '无风',
      'description': '烟直上',
      'minSpeed': 0.0,
      'maxSpeed': 0.2,
      'icon': '🌫️',
      'color': 0xFF9E9E9E, // 灰色
    },
    {
      'level': 1,
      'name': '软风',
      'description': '烟能表示风向',
      'minSpeed': 0.3,
      'maxSpeed': 1.5,
      'icon': '🍃',
      'color': 0xFF4CAF50, // 绿色
    },
    {
      'level': 2,
      'name': '轻风',
      'description': '人面感觉有风',
      'minSpeed': 1.6,
      'maxSpeed': 3.3,
      'icon': '🌿',
      'color': 0xFF8BC34A, // 浅绿色
    },
    {
      'level': 3,
      'name': '微风',
      'description': '树叶微动',
      'minSpeed': 3.4,
      'maxSpeed': 5.4,
      'icon': '🌱',
      'color': 0xFFCDDC39, // 黄绿色
    },
    {
      'level': 4,
      'name': '和风',
      'description': '树枝摇动',
      'minSpeed': 5.5,
      'maxSpeed': 7.9,
      'icon': '🌾',
      'color': 0xFFFFEB3B, // 黄色
    },
    {
      'level': 5,
      'name': '清劲风',
      'description': '小树摇摆',
      'minSpeed': 8.0,
      'maxSpeed': 10.7,
      'icon': '🌳',
      'color': 0xFFFFC107, // 琥珀色
    },
    {
      'level': 6,
      'name': '强风',
      'description': '大树枝摇动',
      'minSpeed': 10.8,
      'maxSpeed': 13.8,
      'icon': '🌲',
      'color': 0xFFFF9800, // 橙色
    },
    {
      'level': 7,
      'name': '疾风',
      'description': '全树摇动',
      'minSpeed': 13.9,
      'maxSpeed': 17.1,
      'icon': '🌪️',
      'color': 0xFFFF5722, // 深橙色
    },
    {
      'level': 8,
      'name': '大风',
      'description': '树枝折断',
      'minSpeed': 17.2,
      'maxSpeed': 20.7,
      'icon': '💨',
      'color': 0xFFF44336, // 红色
    },
    {
      'level': 9,
      'name': '烈风',
      'description': '房屋轻损',
      'minSpeed': 20.8,
      'maxSpeed': 24.4,
      'icon': '🌀',
      'color': 0xFFE91E63, // 粉红色
    },
    {
      'level': 10,
      'name': '狂风',
      'description': '树木拔起',
      'minSpeed': 24.5,
      'maxSpeed': 28.4,
      'icon': '🌊',
      'color': 0xFF9C27B0, // 紫色
    },
    {
      'level': 11,
      'name': '暴风',
      'description': '损坏普遍',
      'minSpeed': 28.5,
      'maxSpeed': 32.6,
      'icon': '⛈️',
      'color': 0xFF673AB7, // 深紫色
    },
    {
      'level': 12,
      'name': '飓风',
      'description': '摧毁巨大',
      'minSpeed': 32.7,
      'maxSpeed': double.infinity,
      'icon': '🌀',
      'color': 0xFF3F51B5, // 靛蓝色
    },
  ];

  /// 根据风速(m/s)获取风力等级
  static Map<String, dynamic> getWindScale(double windSpeedMs) {
    for (final scale in _windScales) {
      if (windSpeedMs >= scale['minSpeed'] && windSpeedMs <= scale['maxSpeed']) {
        return scale;
      }
    }
    // 如果超出范围，返回最高等级
    return _windScales.last;
  }

  /// 获取风力等级数字
  static int getWindLevel(double windSpeedMs) {
    return getWindScale(windSpeedMs)['level'];
  }

  /// 获取风力等级名称
  static String getWindLevelName(double windSpeedMs) {
    return getWindScale(windSpeedMs)['name'];
  }

  /// 获取风力等级描述
  static String getWindLevelDescription(double windSpeedMs) {
    return getWindScale(windSpeedMs)['description'];
  }

  /// 获取风力等级图标
  static String getWindLevelIcon(double windSpeedMs) {
    return getWindScale(windSpeedMs)['icon'];
  }

  /// 获取风力等级颜色
  static int getWindLevelColor(double windSpeedMs) {
    return getWindScale(windSpeedMs)['color'];
  }

  /// 格式化风力显示文本
  static String formatWindDisplay(double windSpeedMs, String windDirection) {
    final scale = getWindScale(windSpeedMs);
    final level = scale['level'];
    final name = scale['name'];
    final icon = scale['icon'];
    
    return '$windDirection风 $level级 $name $icon';
  }

  /// 格式化简短风力显示
  static String formatWindDisplayShort(double windSpeedMs) {
    final scale = getWindScale(windSpeedMs);
    final level = scale['level'];
    final icon = scale['icon'];
    
    return '$level级 $icon';
  }

  /// 获取所有风力等级（用于图例或说明）
  static List<Map<String, dynamic>> getAllWindScales() {
    return List.from(_windScales);
  }

  /// 根据风力等级获取建议
  static String getWindAdvice(double windSpeedMs) {
    final level = getWindLevel(windSpeedMs);
    
    switch (level) {
      case 0:
      case 1:
      case 2:
        return '天气宜人，适合户外活动';
      case 3:
      case 4:
        return '微风习习，适合散步和运动';
      case 5:
      case 6:
        return '风力较大，注意保暖防风';
      case 7:
      case 8:
        return '大风天气，减少户外活动';
      case 9:
      case 10:
        return '强风警告，避免户外活动';
      case 11:
      case 12:
        return '极端天气，请待在室内';
      default:
        return '请注意天气变化';
    }
  }

  /// 判断是否为危险风力等级
  static bool isDangerousWindLevel(double windSpeedMs) {
    return getWindLevel(windSpeedMs) >= 8;
  }

  /// 判断是否为舒适风力等级
  static bool isComfortableWindLevel(double windSpeedMs) {
    final level = getWindLevel(windSpeedMs);
    return level >= 1 && level <= 4;
  }
}

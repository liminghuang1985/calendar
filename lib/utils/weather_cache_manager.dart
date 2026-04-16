import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 天气数据缓存管理器
/// 提供智能的缓存策略，避免频繁的API调用
class WeatherCacheManager {
  static const String _cacheKeyPrefix = 'weather_cache_';
  static const String _lastRequestTimeKey = 'weather_last_request_time';
  static const String _requestCountKey = 'weather_request_count_';
  
  // 缓存配置
  static const int cacheValidMinutes = 5; // 缓存有效期：5分钟
  static const int minRequestIntervalSeconds = 30; // 最小请求间隔：30秒
  static const int maxRequestsPerHour = 60; // 每小时最大请求次数
  
  /// 检查是否可以发起新的天气请求
  static Future<bool> canMakeRequest(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // 检查最小请求间隔
    final lastRequestTime = prefs.getInt(_lastRequestTimeKey) ?? 0;
    final timeSinceLastRequest = now.millisecondsSinceEpoch - lastRequestTime;
    
    if (timeSinceLastRequest < minRequestIntervalSeconds * 1000) {
      debugPrint('🚫 请求过于频繁，需等待 ${(minRequestIntervalSeconds * 1000 - timeSinceLastRequest) / 1000} 秒');
      return false;
    }
    
    // 检查每小时请求次数限制
    final hourKey = '${_requestCountKey}${now.year}_${now.month}_${now.day}_${now.hour}';
    final requestCount = prefs.getInt(hourKey) ?? 0;
    
    if (requestCount >= maxRequestsPerHour) {
      debugPrint('🚫 已达到每小时最大请求次数限制 ($maxRequestsPerHour)');
      return false;
    }
    
    return true;
  }
  
  /// 记录API请求
  static Future<void> recordRequest(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // 记录最后请求时间
    await prefs.setInt(_lastRequestTimeKey, now.millisecondsSinceEpoch);
    
    // 增加小时请求计数
    final hourKey = '${_requestCountKey}${now.year}_${now.month}_${now.day}_${now.hour}';
    final currentCount = prefs.getInt(hourKey) ?? 0;
    await prefs.setInt(hourKey, currentCount + 1);
    
    debugPrint('📊 API请求已记录 - 城市: $cityName, 本小时第 ${currentCount + 1} 次请求');
  }
  
  /// 检查缓存是否有效
  static Future<bool> isCacheValid(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix$cityName';
    final cacheData = prefs.getString(cacheKey);
    
    if (cacheData == null) return false;
    
    try {
      final data = json.decode(cacheData);
      final lastUpdated = DateTime.fromMillisecondsSinceEpoch(data['lastUpdated']);
      final isValid = DateTime.now().difference(lastUpdated).inMinutes < cacheValidMinutes;
      
      if (isValid) {
        debugPrint('✅ 缓存有效 - 城市: $cityName, 剩余时间: ${cacheValidMinutes - DateTime.now().difference(lastUpdated).inMinutes} 分钟');
      } else {
        debugPrint('⏰ 缓存已过期 - 城市: $cityName');
      }
      
      return isValid;
    } catch (e) {
      debugPrint('❌ 缓存数据解析失败: $e');
      return false;
    }
  }
  
  /// 保存天气数据到缓存
  static Future<void> saveToCache(String cityName, Map<String, dynamic> weatherData) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix$cityName';
    
    final cacheData = {
      'weatherData': weatherData,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      'cityName': cityName,
    };
    
    await prefs.setString(cacheKey, json.encode(cacheData));
    debugPrint('💾 天气数据已缓存 - 城市: $cityName');
  }
  
  /// 从缓存获取天气数据
  static Future<Map<String, dynamic>?> getFromCache(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix$cityName';
    final cacheData = prefs.getString(cacheKey);
    
    if (cacheData == null) return null;
    
    try {
      final data = json.decode(cacheData);
      debugPrint('📖 从缓存读取天气数据 - 城市: $cityName');
      return data['weatherData'];
    } catch (e) {
      debugPrint('❌ 缓存数据读取失败: $e');
      return null;
    }
  }
  
  /// 清理过期的缓存数据
  static Future<void> cleanExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final now = DateTime.now();
    
    for (final key in keys) {
      if (key.startsWith(_cacheKeyPrefix)) {
        final cacheData = prefs.getString(key);
        if (cacheData != null) {
          try {
            final data = json.decode(cacheData);
            final lastUpdated = DateTime.fromMillisecondsSinceEpoch(data['lastUpdated']);
            
            if (now.difference(lastUpdated).inMinutes > cacheValidMinutes) {
              await prefs.remove(key);
              debugPrint('🗑️ 清理过期缓存: $key');
            }
          } catch (e) {
            // 如果解析失败，也删除这个缓存
            await prefs.remove(key);
            debugPrint('🗑️ 清理损坏缓存: $key');
          }
        }
      }
      
      // 清理过期的请求计数
      if (key.startsWith(_requestCountKey)) {
        final parts = key.split('_');
        if (parts.length >= 5) {
          try {
            final year = int.parse(parts[2]);
            final month = int.parse(parts[3]);
            final day = int.parse(parts[4]);
            final hour = int.parse(parts[5]);
            
            final recordTime = DateTime(year, month, day, hour);
            if (now.difference(recordTime).inHours > 24) {
              await prefs.remove(key);
              debugPrint('🗑️ 清理过期请求计数: $key');
            }
          } catch (e) {
            await prefs.remove(key);
          }
        }
      }
    }
  }
  
  /// 获取缓存统计信息
  static Future<Map<String, dynamic>> getCacheStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    int cacheCount = 0;
    int validCacheCount = 0;
    final now = DateTime.now();
    
    for (final key in keys) {
      if (key.startsWith(_cacheKeyPrefix)) {
        cacheCount++;
        final cacheData = prefs.getString(key);
        if (cacheData != null) {
          try {
            final data = json.decode(cacheData);
            final lastUpdated = DateTime.fromMillisecondsSinceEpoch(data['lastUpdated']);
            
            if (now.difference(lastUpdated).inMinutes < cacheValidMinutes) {
              validCacheCount++;
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
    }
    
    return {
      'totalCaches': cacheCount,
      'validCaches': validCacheCount,
      'expiredCaches': cacheCount - validCacheCount,
    };
  }
}

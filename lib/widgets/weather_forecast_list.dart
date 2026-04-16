import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather.dart';
import '../utils/wind_scale_converter.dart';
import 'temperature_chart.dart';

class WeatherForecastList extends StatelessWidget {
  final bool isCompact;
  final int maxItems;
  
  const WeatherForecastList({
    super.key,
    this.isCompact = false,
    this.maxItems = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return _buildLoadingList(context);
        }
        
        if (weatherProvider.forecast.isEmpty) {
          return _buildEmptyList(context);
        }
        
        final forecast = weatherProvider.forecast.take(maxItems).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: isCompact ? 18 : 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '5天天气预报',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),

            // 温度曲线图（仅在详细模式下显示）
            if (!isCompact && forecast.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: TemperatureChart(
                  forecast: forecast,
                  isCompact: isCompact,
                ),
              ),

            // 预报列表
            if (isCompact)
              _buildCompactList(context, forecast, weatherProvider)
            else
              _buildDetailedList(context, forecast, weatherProvider),
          ],
        );
      },
    );
  }

  Widget _buildLoadingList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(3, (index) => 
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.grey,
            size: isCompact ? 32 : 48,
          ),
          const SizedBox(height: 8),
          Text(
            '暂无天气预报',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactList(BuildContext context, List<WeatherForecast> forecast, WeatherProvider weatherProvider) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final item = forecast[index];
          final isToday = index == 0;
          
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isToday 
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    ],
                  )
                : null,
              color: isToday ? null : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isToday 
                ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3))
                : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  isToday ? '今天' : item.weekdayString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? Theme.of(context).colorScheme.primary : null,
                    fontSize: 10,
                  ),
                ),
                Text(
                  item.dateString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  weatherProvider.getWeatherIcon(item.description),
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.tempRangeString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailedList(BuildContext context, List<WeatherForecast> forecast, WeatherProvider weatherProvider) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final item = forecast[index];
          final isToday = index == 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isToday 
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  )
                : null,
              color: isToday ? null : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isToday 
                ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3))
                : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                // 日期信息
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? '今天' : item.weekdayString,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                      Text(
                        item.dateString,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 天气图标和描述
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        weatherProvider.getWeatherIcon(item.description),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 温度范围
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.maxTempString,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.minTempString,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 其他信息
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 12,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${item.humidity}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.air,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            WindScaleConverter.formatWindDisplayShort(item.windSpeed),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

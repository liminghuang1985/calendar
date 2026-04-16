import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather.dart';

/// 现代化温度曲线图组件
class TemperatureChart extends StatelessWidget {
  final List<WeatherForecast> forecast;
  final bool isCompact;

  const TemperatureChart({
    super.key,
    required this.forecast,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: isCompact ? 120 : 180,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
                size: isCompact ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                '温度趋势',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isCompact ? 14 : 16,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 图表
          Expanded(
            child: LineChart(
              _buildLineChartData(context),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // 准备数据点
    final maxTempSpots = <FlSpot>[];
    final minTempSpots = <FlSpot>[];
    
    for (int i = 0; i < forecast.length && i < 5; i++) {
      final weather = forecast[i];
      maxTempSpots.add(FlSpot(i.toDouble(), weather.maxTemp));
      minTempSpots.add(FlSpot(i.toDouble(), weather.minTemp));
    }

    // 计算温度范围
    final allTemps = [
      ...maxTempSpots.map((spot) => spot.y),
      ...minTempSpots.map((spot) => spot.y),
    ];
    final minTemp = allTemps.reduce((a, b) => a < b ? a : b);
    final maxTemp = allTemps.reduce((a, b) => a > b ? a : b);
    final tempRange = maxTemp - minTemp;
    final padding = tempRange * 0.1; // 10% 边距

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: tempRange > 10 ? 5 : 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < forecast.length) {
                final weather = forecast[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    weather.weekdayString,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: isCompact ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: tempRange > 10 ? 5 : 2,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}°',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: isCompact ? 10 : 12,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (forecast.length - 1).toDouble(),
      minY: minTemp - padding,
      maxY: maxTemp + padding,
      lineBarsData: [
        // 最高温度线
        LineChartBarData(
          spots: maxTempSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.8),
              Colors.orange.withValues(alpha: 0.8),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.red,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.withValues(alpha: 0.2),
                Colors.red.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
        // 最低温度线
        LineChartBarData(
          spots: minTempSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.blue.withValues(alpha: 0.8),
              Colors.cyan.withValues(alpha: 0.8),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.blue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.withValues(alpha: 0.2),
                Colors.blue.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => colorScheme.surface,
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}

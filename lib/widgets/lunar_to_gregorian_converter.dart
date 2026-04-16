import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calendar_provider.dart';

class LunarToGregorianConverter extends StatefulWidget {
  const LunarToGregorianConverter({super.key});

  @override
  State<LunarToGregorianConverter> createState() => _LunarToGregorianConverterState();
}

class _LunarToGregorianConverterState extends State<LunarToGregorianConverter> {
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  
  Map<String, dynamic>? _conversionResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 设置默认值为当前农历日期
    final now = DateTime.now();
    final calendarProvider = context.read<CalendarProvider>();
    final lunarInfo = calendarProvider.convertGregorianToLunar(now);
    
    _yearController.text = lunarInfo['year'].toString();
    _monthController.text = lunarInfo['month'].toString();
    _dayController.text = lunarInfo['day'].toString();
    
    _convertDate();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _convertDate() {
    final year = int.tryParse(_yearController.text);
    final month = int.tryParse(_monthController.text);
    final day = int.tryParse(_dayController.text);

    if (year == null || month == null || day == null) {
      setState(() {
        _errorMessage = '请输入有效的数字';
        _conversionResult = null;
      });
      return;
    }

    if (year < 1900 || year > 2100) {
      setState(() {
        _errorMessage = '年份范围：1900-2100';
        _conversionResult = null;
      });
      return;
    }

    if (month < 1 || month > 12) {
      setState(() {
        _errorMessage = '月份范围：1-12';
        _conversionResult = null;
      });
      return;
    }

    if (day < 1 || day > 30) {
      setState(() {
        _errorMessage = '日期范围：1-30';
        _conversionResult = null;
      });
      return;
    }

    final calendarProvider = context.read<CalendarProvider>();
    final result = calendarProvider.convertLunarToGregorian(year, month, day);

    setState(() {
      if (result['success']) {
        _conversionResult = result;
        _errorMessage = null;
      } else {
        _conversionResult = null;
        _errorMessage = result['error'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 农历日期输入
          _buildLunarDateInput(context),
          
          const SizedBox(height: 24),
          
          // 转换结果或错误信息
          if (_conversionResult != null)
            _buildConversionResult(context)
          else if (_errorMessage != null)
            _buildErrorMessage(context),
          
          const Spacer(),
          
          // 快捷农历日期按钮
          _buildQuickLunarDates(context),
        ],
      ),
    );
  }

  Widget _buildLunarDateInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.brightness_2,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '输入农历日期',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 输入框
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  context,
                  controller: _yearController,
                  label: '年',
                  hint: '2024',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  context,
                  controller: _monthController,
                  label: '月',
                  hint: '1-12',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  context,
                  controller: _dayController,
                  label: '日',
                  hint: '1-30',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 转换按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _convertDate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('转换为公历'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (_) => _convertDate(),
        ),
      ],
    );
  }

  Widget _buildConversionResult(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '公历日期',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _conversionResult!['fullText'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLunarDates(BuildContext context) {
    final currentYear = DateTime.now().year;
    final quickDates = [
      {'label': '春节', 'year': currentYear, 'month': 1, 'day': 1},
      {'label': '元宵节', 'year': currentYear, 'month': 1, 'day': 15},
      {'label': '端午节', 'year': currentYear, 'month': 5, 'day': 5},
      {'label': '中秋节', 'year': currentYear, 'month': 8, 'day': 15},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷选择',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickDates.map((dateInfo) {
            return ElevatedButton(
              onPressed: () {
                _yearController.text = dateInfo['year'].toString();
                _monthController.text = dateInfo['month'].toString();
                _dayController.text = dateInfo['day'].toString();
                _convertDate();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(dateInfo['label'] as String),
            );
          }).toList(),
        ),
      ],
    );
  }
}

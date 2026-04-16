import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/calendar_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日期格式化的本地化数据
  await initializeDateFormatting('zh_CN', null);

  runApp(const PermanentCalendarApp());
}

class PermanentCalendarApp extends StatelessWidget {
  const PermanentCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '万年历',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(themeProvider.currentColorScheme),
            darkTheme: AppTheme.darkTheme(themeProvider.currentColorScheme),
            themeMode: themeProvider.themeMode,
            // 添加本地化支持
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'), // 中文
              Locale('en', 'US'), // 英文
            ],
            locale: const Locale('zh', 'CN'),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

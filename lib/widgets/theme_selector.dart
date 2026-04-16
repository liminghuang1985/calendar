import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.palette,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onSelected: (String value) {
            if (value == 'toggle_theme') {
              themeProvider.toggleTheme();
            } else {
              themeProvider.setColorScheme(value);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              // 主题模式切换
              PopupMenuItem<String>(
                value: 'toggle_theme',
                child: Row(
                  children: [
                    Icon(
                      themeProvider.themeMode == ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      themeProvider.themeMode == ThemeMode.light
                          ? '深色模式'
                          : '浅色模式',
                    ),
                  ],
                ),
              ),
              
              const PopupMenuDivider(),
              
              // 颜色主题选择
              ...themeProvider.availableColorSchemes.map((schemeName) {
                return PopupMenuItem<String>(
                  value: schemeName,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getSchemeColor(schemeName),
                          shape: BoxShape.circle,
                          border: themeProvider.currentColorSchemeName == schemeName
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(themeProvider.getColorSchemeName(schemeName)),
                      if (themeProvider.currentColorSchemeName == schemeName)
                        const Spacer(),
                      if (themeProvider.currentColorSchemeName == schemeName)
                        Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ];
          },
        );
      },
    );
  }
  
  Color _getSchemeColor(String schemeName) {
    const colors = {
      'sunset': Color(0xFFFF6B6B),
      'ocean': Color(0xFF4ECDC4),
      'forest': Color(0xFF6C5CE7),
      'cherry': Color(0xFFE84393),
    };
    return colors[schemeName] ?? Colors.blue;
  }
}

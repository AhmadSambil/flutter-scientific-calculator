import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/calculator_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PremiumCalculatorApp());
}

/// Root widget of the Premium Calculator app.
///
/// Sets up Provider-based state management for theme switching and
/// calculator state, and applies Material 3 light/dark themes with
/// an animated transition (via [AnimatedTheme] inside [MaterialApp]).
class PremiumCalculatorApp extends StatelessWidget {
  const PremiumCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Premium Calculator',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // AnimatedTheme is applied via a builder to smoothly
            // interpolate colors when toggling themes.
            builder: (context, child) {
              return AnimatedTheme(
                data: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

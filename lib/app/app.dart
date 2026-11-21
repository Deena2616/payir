
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/language/app_language.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/language/language_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String language = '/language';
  static const String home = '/home';
  static const String login = '/login';
  static const String crops = '/crops';
  static const String seeds = '/seeds';
  static const String fertilizer = '/fertilizer';
  static const String cropProtection = '/crop-protection';
  static const String weather = '/weather';
  static const String market = '/market';
  static const String schemes = '/schemes';
  static const String machinery = '/machinery';
  static const String aiDoctor = '/ai-doctor';
  static const String soil = '/soil';
  static const String water = '/water';
  static const String finance = '/finance';
  static const String community = '/community';
  static const String profile = '/profile';
}

class PayirApp extends StatelessWidget {
  const PayirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguage.locale,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PAYIR',
          locale: locale,

          supportedLocales: const [
            Locale('ta'),
            Locale('en'),
          ],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],

          initialRoute: AppRoutes.splash,

          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.language: (context) => const LanguageScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}

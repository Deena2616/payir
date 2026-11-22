import 'package:flutter/material.dart';
import '../widgets/glass.dart';

const Color kInk = Color(0xFF14331A);
const Color kGreen = Color(0xFF2E7D32);
const Color kGreenLight = Color(0xFF43A047);
const Color kTeal = Color(0xFF00897B);
const Color kGlassFill = Color(0x99FFFFFF);
const Color kGlassBorder = Color(0xB3FFFFFF);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: kGreen);
  OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: c == Colors.transparent ? BorderSide.none : BorderSide(color: c, width: w),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: BlurPageTransitionsBuilder(),
      TargetPlatform.iOS: BlurPageTransitionsBuilder(),
      TargetPlatform.windows: BlurPageTransitionsBuilder(),
      TargetPlatform.macOS: BlurPageTransitionsBuilder(),
      TargetPlatform.linux: BlurPageTransitionsBuilder(),
    }),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xB3FFFFFF),
      border: b(Colors.transparent, 0),
      enabledBorder: b(Colors.transparent, 0),
      focusedBorder: b(kGreen, 1.6),
      errorBorder: b(Colors.red, 1.2),
      focusedErrorBorder: b(Colors.red, 1.6),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: const Color(0x66FFFFFF),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xF2FFFFFF),
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
  );
}


import 'package:flutter/material.dart';

class AppLanguage {
  static final ValueNotifier<Locale> locale =
  ValueNotifier(const Locale('ta'));

  static void changeLanguage(String languageCode) {
    locale.value = Locale(languageCode);
  }
}

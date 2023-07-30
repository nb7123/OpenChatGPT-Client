
import 'dart:ui';

class AppLocale {
  final Locale locale;
  final String display;

  AppLocale(this.locale, this.display);

  static final List<AppLocale> supportedLocales = [
    AppLocale(const Locale('en'), "English"),
    AppLocale(const Locale('zh'), "中文（简体）"),
  ];
}
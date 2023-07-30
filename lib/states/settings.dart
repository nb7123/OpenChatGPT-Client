import 'package:flutter/material.dart';
import '../color_schemes.dart';
import '../model/locale.dart';
import '../model/settings.dart';


class SettingsStates {
  static const modeAuto = 0;
  static const modelDark = 1;
  static const modeLight = 2;

  static final ThemeData _light =
  ThemeData(useMaterial3: true, colorScheme: lightColorScheme);
  static final ThemeData _dark =
  ThemeData(useMaterial3: true, colorScheme: darkColorScheme);

  static final ValueNotifier<SystemSettings> settingsNotifier = ValueNotifier(SystemSettings());
  static SystemSettings get settings => settingsNotifier.value;
  static String get chatModel => settings.model;

  static final List<AppLocale> supportedLocales = AppLocale.supportedLocales;

  /// locale
  static Locale? get currentLocale => settings.currentLocale;

  static void updateLocale(Locale locale) async {
    SystemSettings config = _copySystemSettings(settings);

    config.locale = locale.toString();
    SystemSettings.updateSystemConfig(config);
    settingsNotifier.value = config;
  }

  static Future<void> load() async {
    SystemSettings? settings = await SystemSettings.loadSystemConfig();
    settings ??= SystemSettings();

    SystemSettings.updateSystemConfig(settings);
    settingsNotifier.value = settings;
  }

  /// Theme
  static ThemeData get defaultTheme {
    if (settings.theme == modelDark) {
      return _dark;
    }

    return _light;
  }

  static ThemeData get darkTheme {
    if (settings.theme == modeLight) {
      return _light;
    }

    return _dark;
  }

  static Future<void> updateThemeMode(int themeMode) async {
    SystemSettings config = _copySystemSettings(settings);

    config.theme = themeMode;
    SystemSettings.updateSystemConfig(config);
    settingsNotifier.value = config;
  }

  static Future<void> updateMaxContextWindow(int windowSize) async {
    SystemSettings config = _copySystemSettings(settings);

    config.contextWindow = windowSize;
    SystemSettings.updateSystemConfig(config);
    settingsNotifier.value = config;
  }

  static Future<void> updateMaxPromptTokens(int maxPromptTokens) async {
    SystemSettings config = _copySystemSettings(settings);

    config.maxPromptTokens = maxPromptTokens;
    SystemSettings.updateSystemConfig(config);
    settingsNotifier.value = config;
  }

  static Future<void> updateOpenAiBaseApi([String baseApi = "https://api.openai.dart.com"]) async {
    SystemSettings config = _copySystemSettings(settings);

    config.openAiBaseUrl = baseApi;
    SystemSettings.updateSystemConfig(config);
    settingsNotifier.value = config;
  }

  static Future<void> updateOpenAiApiKey(String apiKey) async {
    SystemSettings config = _copySystemSettings(settings);

    config.openAiApiKey = apiKey;
    SystemSettings.updateSystemConfig(config);
    settingsNotifier.value = config;
  }

  static Future<void> updateOpenAiChatModel(String model) async {
    SystemSettings config = _copySystemSettings(settings);

    config.model = model;
    SystemSettings.updateSystemConfig(config);
    settingsNotifier.value = config;
  }

  static SystemSettings _copySystemSettings(SystemSettings settings) {
    return SystemSettings()
      ..theme = settings.theme
      ..model = settings.model
      ..locale = settings.locale;
  }

  SettingsStates._();
}

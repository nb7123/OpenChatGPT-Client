import 'dart:ui';

import 'package:intl/intl.dart';

import 'openai.dart';
import '../api/openai.dart';
import 'database.dart';
import 'package:isar/isar.dart';

part 'settings.g.dart';

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

@collection
@Name('SystemSettings')
class SystemSettings {
  Id id = 1;

  int theme = 0;

  String model = ChatModel.gpt_3Dot5_0613;
  // current Locale
  String? locale;

  // max tokens size
  int contextWindow = 4096;

  // Maximum Prompt Tokens quantity
  int maxPromptTokens = (4096 * 2) ~/ 3;

  String openAiBaseUrl = defaultOpenAiBaseUrl;
  String? openAiApiKey = defaultApiKey;

  @ignore
  Locale? get currentLocale {
    if (locale == null) return null;

    return Locale.fromSubtags(languageCode: locale!);
  }

  @override
  String toString() {
    return "SystemSettings("
        "theme: $theme, "
        "model: $model, "
        "maxContextWindowSize: $contextWindow, "
        "maxPromptTokens: $maxPromptTokens, "
        "openAiBaseUrl: $openAiBaseUrl, "
        "openAiApiKey: $openAiApiKey, "
        "locale: $locale)";
  }

  static Isar get isar => ChatDatabase.isar;

  static Future<SystemSettings?> loadSystemConfig() async {
    return isar.systemSettings.filter().idEqualTo(1).findFirst();
  }

  static Future<int> updateSystemConfig(SystemSettings config) async {
    return isar.writeTxn(() => isar.systemSettings.put(config));
  }
}

/// 每日的免费用量
@collection
class DailyUsage {
  static final _format = DateFormat('yyyy-MM-dd');

  Id get id {
    return fastHash(_format.format(DateTime.fromMillisecondsSinceEpoch(date)));
  }

  int date = DateTime.now().millisecondsSinceEpoch;

  int tokens = 0;

  static Isar get _isar => ChatDatabase.isar;

  static Future<DailyUsage?> today() async {
    return _isar.dailyUsages
        .filter()
        .idEqualTo(fastHash(_format.format(DateTime.now())))
        .findFirst();
  }

  /// Daily usage history
  /// default load a year date
  static Stream<List<DailyUsage>> loadHistory([int page = 0, int pageSize = 365]) {
    return _isar.dailyUsages
    .where()
    .sortByDateDesc()
    .offset(page)
    .limit(pageSize)
    .watch(fireImmediately: true);
  }

  static Future<int> saveDailyUsage(DailyUsage usage) async {
    return _isar.writeTxn(() => _isar.dailyUsages.put(usage));
  }
}

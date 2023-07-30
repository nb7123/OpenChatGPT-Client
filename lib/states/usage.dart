import 'package:flutter/foundation.dart';

import '../model/settings.dart';

class DailyUsageStates {
  static final ValueNotifier<DailyUsage> usageNotifier =
      ValueNotifier(DailyUsage());

  static DailyUsage get dailyUsage => usageNotifier.value;

  static Future<int> tokensUsed(int tokens) {
    final usage = _copyDailyUsage(dailyUsage);

    usage.tokens += tokens;

    return DailyUsage.saveDailyUsage(usage);
  }

  ///
  /// load today usage
  static Future<void> load() async {
    DailyUsage? usage = await DailyUsage.today();
    if (usage != null) {
      usageNotifier.value = usage;
    }
  }

  static DailyUsage _copyDailyUsage(DailyUsage usage) {
    return DailyUsage()
      ..date = usage.date
      ..tokens = usage.tokens;
  }

  ///
  /// 今年的使用历史
  static Stream<List<DailyUsage>> usageHistory() {
    return DailyUsage.loadHistory();
  }

  DailyUsageStates._();
}

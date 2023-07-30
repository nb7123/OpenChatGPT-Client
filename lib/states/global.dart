
import '../model/database.dart';
import 'usage.dart';
import 'settings.dart';

class GlobalStates {
  static Future<void> init() async {
    await ChatDatabase.init();
    await SettingsStates.load();
    await DailyUsageStates.load();
  }

  GlobalStates._();
}
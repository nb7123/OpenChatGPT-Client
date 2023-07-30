import 'dart:async';

import 'message.dart';
import 'chat.dart';
import 'settings.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ChatDatabase {
  static late Isar _isarDatabase;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    _isarDatabase = await Isar.open(
        directory: dir.path,
        [
          ChatSchema,
          MessageSchema,
          SystemSettingsSchema,
          DailyUsageSchema,
        ],
        name: "IntelliMatchChat");
  }

  static Isar get isar => _isarDatabase;

  ChatDatabase._();
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';

import 'screens/common/window_size_class.dart';
import 'screens/main/compat.dart';
import 'screens/main/medium.dart';
import 'states/global.dart';
import 'states/settings.dart';
import 'model/chat.dart';
import 'screens/message/compat.dart';
import 'states/chat.dart';

void main() {
  runApp(const OpenChatGPT());
}

class OpenChatGPT extends StatelessWidget {
  const OpenChatGPT({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: SettingsStates.settingsNotifier,
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Home(),
            theme: SettingsStates.defaultTheme,
            darkTheme: SettingsStates.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: SettingsStates.currentLocale,
          );
        });
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    ChatStates.activeChatNotifier.addListener(chatChanged);
    WidgetsBinding.instance.addObserver(this);

    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ChatStates.activeChatNotifier.removeListener(chatChanged);
    super.dispose();
  }

  ///
  /// 应用程序初始化
  void _init() async {
    // 应用基础配置初始化－－start
    WidgetsFlutterBinding.ensureInitialized();

    await GlobalStates.init();
    // 应用基础配置初始化－－end

    setState(() {
      _initialized = true;
    });
  }

  void chatChanged() async {
    Chat chat = ChatStates.activeChat;

    // 清除会话，无需处理
    if (chat.id < 0) return;

    Future.delayed(const Duration(milliseconds: 200), _showChatScreen);
  }

  void _showChatScreen() async {
    if (mounted) {
      await Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => const ChatCompatV3()));

      // 会话结束，需要清理
      ChatStates.resetActiveConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return WindowSizeLayoutBuilder(builder: (context, windowSizeClass) {
      switch (windowSizeClass.widthSizeClass) {
        case WindowWidthSizeClass.Expanded:
          return const MainMedium();

        case WindowWidthSizeClass.Medium:
          return const MainMedium();

        default:
          return const MainCompat();
      }
    });
  }
}

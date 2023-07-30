import 'package:flutter/material.dart';
import 'package:open_chatgpt/screens/about/medium.dart';
import '../../screens/settings/widgets.dart';

class MoreActionsMedium extends StatefulWidget {
  const MoreActionsMedium({super.key});

  @override
  State<StatefulWidget> createState() => _MoreActionsMediumState();
}

class _MoreActionsMediumState extends State<MoreActionsMedium> {
  int _active = -1;

  Widget _buildSettingsWidgets() {
    switch (_active) {
      case 0:
        return const DarkModeSettingsWidget();
      case 1:
        return const LanguageSettingsWidget();
      case 2:
        return const AboutMedium();
      case 3:
        return const OpenAIConfigScreen();
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    Widget darkMode = SettingsItemDarkMode(onClick: () {
      setState(() {
        _active = 0;
      });
    });

    Widget language = SettingsItemLanguage(onClick: () {
      setState(() {
        _active = 1;
      });
    });

    Widget about = SettingsItemAbout(onClick: () {
      setState(() {
        _active = 2;
      });
    });

    Widget openAI = SettingsItemOpenAI(onClick: () {
      setState(() {
        _active = 3;
      });
    });

    Widget settings = Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        darkMode,
        const Divider(),
        language,
        const Divider(),
        about,
        const Divider(),
        openAI,
      ],
    );

    return Scaffold(
      body: SafeArea(
          child: Row(
        children: [
          Expanded(flex: 1, child: settings),
          const VerticalDivider(),
          Expanded(flex: 2, child: _buildSettingsWidgets())
        ],
      )),
    );
  }
}

class OpenAIConfigScreen extends StatelessWidget {
  const OpenAIConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Column(children: [
      SizedBox(height: 36,),
      Expanded(child: SettingsOpenAIWidget())
    ],),);
  }
}

import 'package:flutter/material.dart';
import '../../screens/settings/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/app_bar.dart';
import 'medium.dart';

class SettingsDarkModeCompat extends StatelessWidget {
  const SettingsDarkModeCompat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AxionAppBar(
        title: Text(AppLocalizations.of(context)!.dark_mode),
        actions: const [],
      ),
      body: const DarkModeSettingsWidget(),
    );
  }
}

class SettingsLanguageCompat extends StatelessWidget {
  const SettingsLanguageCompat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AxionAppBar(
        title: Text(AppLocalizations.of(context)!.title_language),
        actions: const [],
      ),
      body: const LanguageSettingsWidget(),
    );
  }
}

class SettingsOpenAiCompat extends StatelessWidget {
  const SettingsOpenAiCompat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AxionAppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        actions: const [],
      ),
      body: const OpenAIConfigScreen(),
    );
  }
}

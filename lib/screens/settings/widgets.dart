import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../api/openai.dart';
import '../../model/settings.dart';
import '../../utils/logger.dart';
import '../../model/locale.dart';
import '../../model/openai.dart';
import '../../states/settings.dart';

const Widget _navNext = Icon(Icons.navigate_next_outlined);

class DarkModeSettingsWidget extends StatelessWidget {
  const DarkModeSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: SettingsStates.settingsNotifier,
        builder: (context, settings, child) {
          return Column(
            children: [
              const SizedBox(
                height: 24,
              ),
              InkWell(
                onTap: () {
                  SettingsStates.updateThemeMode(SettingsStates.modeAuto);
                },
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.dark_mode_auto),
                  trailing: settings.theme == SettingsStates.modeAuto
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
              ),
              const Divider(height: 1),
              InkWell(
                onTap: () {
                  SettingsStates.updateThemeMode(SettingsStates.modeLight);
                },
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.dark_mode_light),
                  trailing: settings.theme == SettingsStates.modeLight
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
              ),
              const Divider(height: 1),
              InkWell(
                onTap: () {
                  SettingsStates.updateThemeMode(SettingsStates.modelDark);
                },
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.dark_mode_dark),
                  trailing: settings.theme == SettingsStates.modelDark
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
              ),
            ],
          );
        });
  }
}

class LanguageSettingsWidget extends StatelessWidget {
  const LanguageSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: SettingsStates.settingsNotifier,
        builder: (context, settings, child) {
          List<AppLocale> supportedLocales = SettingsStates.supportedLocales;
          Locale current =
              settings.currentLocale ?? Localizations.localeOf(context);
          return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                AppLocale locale = supportedLocales[index];
                return ListTile(
                  onTap: () {
                    SettingsStates.updateLocale(locale.locale);
                  },
                  title: Text(locale.display),
                  trailing: current.languageCode == locale.locale.languageCode
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemCount: supportedLocales.length);
        });
  }
}

class _SettingsItemView extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback? onClick;

  const _SettingsItemView(
      {super.key, required this.icon, required this.title, this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onClick,
        child: ListTile(
          title: Row(
            children: [
              icon,
              const SizedBox(
                width: 8,
              ),
              Expanded(child: Text(title))
            ],
          ),
          trailing: _navNext,
        ));
  }
}

class SettingsItemDarkMode extends StatelessWidget {
  final VoidCallback onClick;

  const SettingsItemDarkMode({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return _SettingsItemView(
      icon: Image.asset(
        "assets/icons/dark_mode.png",
        width: 24,
        height: 24,
        color: iconColor,
      ),
      title: AppLocalizations.of(context)!.dark_mode,
      onClick: onClick,
    );
  }
}

class SettingsItemAbout extends StatelessWidget {
  final VoidCallback onClick;

  const SettingsItemAbout({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return _SettingsItemView(
      icon: Icon(
        Icons.info_outline_rounded,
        size: 24,
        color: iconColor,
      ),
      title: AppLocalizations.of(context)!.about,
      onClick: onClick,
    );
  }
}

class SettingsItemLanguage extends StatelessWidget {
  final VoidCallback onClick;

  const SettingsItemLanguage({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return _SettingsItemView(
      icon: Icon(
        Icons.language,
        size: 24,
        color: iconColor,
      ),
      title: AppLocalizations.of(context)!.title_language,
      onClick: onClick,
    );
  }
}

class SettingsItemOpenAI extends StatelessWidget {
  final VoidCallback onClick;

  const SettingsItemOpenAI({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return _SettingsItemView(
      icon: Icon(
        Icons.settings_outlined,
        size: 24,
        color: iconColor,
      ),
      title: AppLocalizations.of(context)!.settings,
      onClick: onClick,
    );
  }
}

class SettingsOpenAIWidget extends StatefulWidget {
  const SettingsOpenAIWidget({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsOpenAIWidgetState();
}

class _SettingsOpenAIWidgetState extends State<SettingsOpenAIWidget> {
  ChatModel? _selected;
  int _maxContextWindow = SettingsStates.settings.contextWindow;
  int _maxPromptTokens = SettingsStates.settings.maxPromptTokens;
  String _baseOpenAiUrl = SettingsStates.settings.openAiBaseUrl;
  String _openAiApiKey = SettingsStates.settings.openAiApiKey ?? defaultApiKey;

  double get maxTokens {
    return _maxContextWindow.toDouble();
  }

  double get maxPromptTokens {
    return _maxPromptTokens.toDouble();
  }

  double get minTokens => maxPromptTokens;

  Widget _modelSetup(BuildContext context) {
    final List<DropdownMenuEntry<ChatModel>> modelEntries =
        <DropdownMenuEntry<ChatModel>>[];
    for (final ChatModel model in ChatModel.supportedModels) {
      modelEntries.add(
        DropdownMenuEntry<ChatModel>(value: model, label: model.name),
      );
    }

    _selected =
        _selected ?? ChatModel.findModelByName(SettingsStates.chatModel);

    return Center(
      child: DropdownMenu<ChatModel>(
        initialSelection: _selected,
        label: const Text('Model'),
        dropdownMenuEntries: modelEntries,
        onSelected: (ChatModel? model) {
          setState(() {
            _selected = model;
            _maxContextWindow = _selected?.maxTokens?? 0;
            _maxPromptTokens = _maxContextWindow * 2 ~/ 3;
          });
        },
      ),
    );
  }

  Widget _contextWindowSlider(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text("${localizations.label_max_tokens}$_maxContextWindow"),
          ),
          Slider(
            value: _maxContextWindow.toDouble(),
            max: (_selected?.maxTokens ?? -1).toDouble(),
            min: minTokens,
            label: _maxContextWindow.round().toString(),
            onChanged: (double value) {
              setState(() {
                _maxContextWindow = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _maxPromptTokensSlider(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text("${localizations.label_max_prompt}$_maxPromptTokens"),
          ),
          Slider(
            value: _maxPromptTokens.toDouble(),
            max: maxTokens,
            min: 100,
            label: _maxPromptTokens.round().toString(),
            onChanged: (double value) {
              setState(() {
                _maxPromptTokens = value.round();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              localizations.max_prompt_desc,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          )
        ],
      ),
    );
  }

  Widget _openAiBaseUrlSetup(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.label_use_private_baseurl),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
                hintText:
                _baseOpenAiUrl.isEmpty ? defaultOpenAiBaseUrl : _baseOpenAiUrl,
                border: const OutlineInputBorder()),
            onChanged: (value) {
              setState(() {
                _baseOpenAiUrl = value;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _openAiApiKeySetup(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.label_api_key),
        const SizedBox(height: 8,),
        TextField(
          decoration: InputDecoration(
              hintText: _openAiApiKey,
              border: const OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              _openAiApiKey = value;
            });
          },
        )
      ],),
    );
  }

  bool get _changed {
    SystemSettings settings = SettingsStates.settings;
    return _selected?.name != settings.model ||
        _maxPromptTokens != settings.maxPromptTokens ||
        _maxContextWindow != settings.contextWindow ||
        _baseOpenAiUrl != settings.openAiBaseUrl ||
        _openAiApiKey != (settings.openAiApiKey?? "");
  }

  void _saveChanges() async {
    SystemSettings settings = SettingsStates.settings;
    String model = _selected?.name ?? "";
    if (model != settings.model) {
      AppLogger.log("Model changed");
      await SettingsStates.updateOpenAiChatModel(model);
    }

    if (_maxPromptTokens != settings.maxPromptTokens) {
      AppLogger.log("maxPromptTokens changed");
      await SettingsStates.updateMaxPromptTokens(_maxPromptTokens);
    }

    if (_maxContextWindow != settings.contextWindow) {
      AppLogger.log("contextWindow changed");
      await SettingsStates.updateMaxContextWindow(_maxContextWindow);
    }

    if (_baseOpenAiUrl != settings.openAiBaseUrl) {
      AppLogger.log("openAiBaseUrl changed");
      await SettingsStates.updateOpenAiBaseApi(_baseOpenAiUrl);
    }

    if (_openAiApiKey != settings.openAiApiKey) {
      AppLogger.log("openAiApiKey changed");
      await SettingsStates.updateOpenAiApiKey(_openAiApiKey);
    }

    if (mounted) {
      final ScaffoldMessengerState messengerState =
      ScaffoldMessenger.of(context);

      AppLocalizations localizations = AppLocalizations.of(context)!;

      messengerState.showSnackBar(
        SnackBar(
          content: Text(localizations.save_success),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _modelSetup(context),
                _contextWindowSlider(context),
                _maxPromptTokensSlider(context),
                _openAiBaseUrlSetup(context),
                _openAiApiKeySetup(context)
              ],
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
              onPressed: _changed ? _saveChanges : null,
              child: Text(localizations.save_settings)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

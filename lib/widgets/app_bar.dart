import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../screens/favorite/screens.dart';
import '../screens/settings/compat.dart';

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight(
            (toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}

class _MenuItem {
  final String title;
  final Widget icon;

  final void Function(BuildContext context) onPressed;

  _MenuItem({required this.title, required this.icon, required this.onPressed});
}

class AxionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;

  const AxionAppBar({super.key, this.title, this.actions});

  List<PopupMenuEntry<_MenuItem>> _moreMenuItems(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    final iconColor = Theme.of(context).colorScheme.onSurface;
    Widget iconDarkMode = Image.asset(
      "assets/icons/dark_mode.png",
      width: 24,
      height: 24,
      color: iconColor,
    );
    Widget iconLang = Icon(
      Icons.language_rounded,
      color: iconColor,
    );
    Widget iconSettings = Icon(
      Icons.settings_outlined,
      color: iconColor,
    );

    List<_MenuItem> menuItems = [
      _MenuItem(
          title: localizations.dark_mode,
          icon: iconDarkMode,
          onPressed: (BuildContext context) {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const SettingsDarkModeCompat()));
          }),
      _MenuItem(
          title: localizations.title_language,
          icon: iconLang,
          onPressed: (BuildContext context) {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const SettingsLanguageCompat()));
          }),
      _MenuItem(
          title: localizations.settings,
          icon: iconSettings,
          onPressed: (BuildContext context) {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const SettingsOpenAiCompat()));
          })
    ];

    return menuItems
        .map((item) => PopupMenuItem<_MenuItem>(
              value: item,
              child: Row(
                children: [
                  item.icon,
                  const SizedBox(width: 8),
                  Text(item.title)
                ],
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget actionMore = PopupMenuButton<_MenuItem>(
      // Callback that sets the selected popup menu item.
      onSelected: (_MenuItem item) {
        item.onPressed(context);
      },
      itemBuilder: (BuildContext context) => _moreMenuItems(context),
    );

    List<Widget> actions = this.actions ??
        [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => const FavoriteCompat()));
              },
              icon: const Icon(Icons.star_rounded)),
          actionMore
        ];

    Widget realTitle = title ?? Text(AppLocalizations.of(context)!.app_name);

    return Hero(
        tag: "axion_app_bar",
        child: AppBar(
          title: realTitle,
          centerTitle: true,
          actions: actions,
        ));
  }

  @override
  Size get preferredSize => _PreferredAppBarSize(null, null);
}

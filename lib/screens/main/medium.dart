import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../states/chat.dart';
import '../../utils/logger.dart';
import '../favorite/screens.dart';
import '../settings/medium.dart';
import 'widgets.dart';

class Destination extends NavigationRailDestination {
  const Destination({
    required super.icon,
    super.selectedIcon,
    required super.label,
    super.padding,
  });
}

class MainMedium extends StatefulWidget {
  const MainMedium({super.key});

  @override
  State<StatefulWidget> createState() => _MainMediumState();
}

class _MainMediumState extends State<MainMedium> {
  List<Destination> _buildDestinations(BuildContext context) {
    Widget appIcon = Image.asset(
      "assets/icons/app_icon.png",
      width: 24,
      height: 24,
    );
    return <Destination>[
      Destination(
        icon: appIcon,
        label: Text(AppLocalizations.of(context)!.app_name),
        selectedIcon: appIcon,
      ),
      Destination(
        icon: const Icon(Icons.star_outline_rounded),
        label: Text(AppLocalizations.of(context)!.favorite),
        selectedIcon: const Icon(Icons.star_rounded),
      ),
      const Destination(
        icon: Icon(Icons.more_horiz_outlined),
        label: Text(""),
        selectedIcon: Icon(Icons.more_horiz_outlined),
      ),
    ];
  }

  var _activeDestinationIndex = 0;

  void conversationChanged() {
    AppLogger.log("Conversation changed");
    setState(() {
      _activeDestinationIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();

    ChatStates.activeChatNotifier.addListener(conversationChanged);
  }

  @override
  void dispose() {
    ChatStates.activeChatNotifier.removeListener(conversationChanged);
    super.dispose();
  }

  Widget _buildDestinationView() {
    switch (_activeDestinationIndex) {
      case 0:
        return const Scaffold(
          body: Center(
            child: SizedBox(
              width: 600,
              child: HomeContentWidget(),
            ),
          ),
        );
      case 1:
        return const FavoriteCompat();

      case 2:
        return const MoreActionsMedium();
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              groupAlignment: -0.9,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              labelType: NavigationRailLabelType.all,
              destinations: _buildDestinations(context),
              selectedIndex: _activeDestinationIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _activeDestinationIndex = index;
                });
              },
            ),
            Expanded(
              child: _buildDestinationView(),
            )
          ],
        ),
    );
  }
}

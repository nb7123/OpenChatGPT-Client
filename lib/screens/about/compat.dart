import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/app_bar.dart';
import 'widgets.dart';

class AboutCompat extends StatelessWidget {
  const AboutCompat({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AxionAppBar(
        title: Text(localizations.about),
        actions: [],
      ),
      body: const Center(
        child: SizedBox(
          width: 600,
          child: AboutWidget(),
        ),
      ),
    );
  }
}

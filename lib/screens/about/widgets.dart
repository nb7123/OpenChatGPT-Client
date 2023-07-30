import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String _emailAddress = "easyai.us@gmail.com";

final Widget logo = Image.asset(
  "assets/icons/app_icon.png",
  width: 96,
  height: 96,
);

class AboutShortDescWidget extends StatelessWidget {
  const AboutShortDescWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
      AppLocalizations.of(context)!.app_desc_short,
      textAlign: TextAlign.center,
    ));
  }
}

class AboutFullDescWidget extends StatelessWidget {
  const AboutFullDescWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(subtitle: Text(AppLocalizations.of(context)!.app_desc)),
      ),
    );
  }
}

class AboutEmailButton extends FloatingActionButton {
  AboutEmailButton({super.key})
      : super(
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: _emailAddress,
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
            child: const Icon(Icons.email_outlined));
}

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24,),
                logo,
                const AboutShortDescWidget(),
                const AboutFullDescWidget(),
              ],
            ),
          )),
        ],
      ),
      // Button New chat
      // floatingActionButton: AboutEmailButton(),
    );
  }
}

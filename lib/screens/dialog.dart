import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/message.dart';

class RemoveFavoriteDialog extends StatelessWidget {
  final Message message;

  const RemoveFavoriteDialog({super.key, required this.message});

  void removeFavorite() async {
    Message.addMessage(message..markFavorite = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.text_delete,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      content: Text(AppLocalizations.of(context)!.confirm_delete),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              removeFavorite();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.ok))
      ],
    );
  }
}
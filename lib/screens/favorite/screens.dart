
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/message.dart';
import '../../widgets/app_bar.dart';
import '../message/widgets.dart';

abstract class _FavoriteBase extends StatelessWidget {
  const _FavoriteBase({super.key});

  Widget buildContent(BuildContext context, List<Message> list);

  Widget buildEmptyContent(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 0.8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.favorite_prompt),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<List<Message>> favorites = Message.favorites();
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AxionAppBar(
        title: Text(localizations.favorite),
        actions: [],
      ),
      body: Center(
          child: SizedBox(
        width: 600,
        child: StreamBuilder<List<Message>>(
            stream: favorites,
            builder:
                (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
              List<Message>? list = snapshot.data;
              list ??= [];

              if (list.isEmpty) {
                return buildEmptyContent(context);
              }

              return buildContent(context, list);
            }),
      )),
    );
  }
}

class FavoriteCompat extends _FavoriteBase {
  const FavoriteCompat({super.key});

  @override
  Widget buildContent(BuildContext context, List<Message> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      itemBuilder: (BuildContext context, int index) {
        final message = list[index];
        return MessageWidgetV2(
          message,
          favorite: true,
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 24,
        );
      },
      itemCount: list.length,
    );
  }
}

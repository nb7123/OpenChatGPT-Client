import 'package:flutter/material.dart';
import '../../model/models.dart';
import '../../model/prompts.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../states/chat.dart';

class TemplateItemWidget extends StatelessWidget {
  final ChatPrompt prompt;

  const TemplateItemWidget({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    if (prompt.icon.startsWith("http")) {
      leading = Image.network(prompt.icon);
    } else {
      leading = Image.asset("assets/prompts/${prompt.icon}");
    }

    leading = SizedBox(width: 48, height: 48, child: leading,);

    return InkWell(
      onTap: () {
        ChatStates.newChatWithPrompt(prompt);
      },
      child: Center(
        child: ListTile(
          leading: leading,
          title:
              Text(prompt.actor, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class TemplateRandomPage extends StatelessWidget {
  static const _totalTemplates = 12;

  const TemplateRandomPage({super.key});

  List<Widget> _randomTemplates(BuildContext context) {
    List<ChatPrompt> prompts = chatPrompts(context);

    List<Widget> promptWidgets = [];
    for (int i = 0; i < _totalTemplates && i < prompts.length; i++) {
      promptWidgets.add(Expanded(
        child: TemplateItemWidget(prompt: prompts[i]),
      ));
    }

    return promptWidgets;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    List<Widget> templates = _randomTemplates(context);

    // 不用考虑少于6个的case
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(localizations.try_these_out,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Row(children: [templates[0], templates[1], templates[2]]),
                Row(children: [templates[3], templates[4], templates[5]]),
                Row(children: [templates[6], templates[7], templates[8]]),
                // Row(children: [templates[9], templates[10], templates[11]])
              ],
            ),
          ),
        )
      ],
    );
  }
}

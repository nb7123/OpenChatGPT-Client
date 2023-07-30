import 'package:flutter/material.dart';

import '../../model/chat.dart';
import '../../model/models.dart';
import '../../model/prompts.dart';
import '../../states/chat.dart';
import '../../widgets/input.dart';
import '../../widgets/templates.dart';
import '../../widgets/welcome.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../chat/widgets.dart';

class HomeContentWidget extends StatelessWidget {
  const HomeContentWidget({super.key});

  ///
  /// 模板区域组件，Compat显示为2列，Medium显示为3列，Expanded显示为5列
  Widget _buildSliverTemplates(BuildContext context) {
    List<ChatPrompt> prompts = chatPrompts(context);

    List<Widget> promptWidgets = [];
    for (int i = 0; i < 6 && i < prompts.length; i++) {
      promptWidgets.add(TemplateItemWidget(prompt: prompts[i]));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: 2.5,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return promptWidgets[index];
        },
        childCount: promptWidgets.length,
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return ValueListenableBuilder(
        valueListenable: ChatStates.activeChatNotifier,
        builder: (context, chat, child) {
          // if (_inputText?.isEmpty != true) {
          //   return const AdBannerLargeMainWidget();
          // }
          return StreamBuilder(
              stream: Chat.chatsStream(),
              builder: (context, snapshot) {
                final List<Chat> chats = snapshot.data ?? [];
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                        child: Center(
                      child: WelcomeWidget(),
                    )),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(localizations.try_these_out,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ),
                    // 模板
                    _buildSliverTemplates(context),

                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        child: Text(localizations.chats,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ),
                    SliverList.builder(
                        itemBuilder: (context, index) {
                          if (index == chats.length) {
                            return const SizedBox(height: 80);
                          }

                          return ConversationItemCompat(
                              conversation: chats[index]);
                        },
                        itemCount: chats.length + 1)
                  ],
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Center(
        child: Column(
          children: [
            Expanded(
                child: Stack(
              children: [
                _buildScrollableContent(context),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: InputWidget(beforeSend: () async {
                      await ChatStates.resetActiveConversation();
                    }),
                  ),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

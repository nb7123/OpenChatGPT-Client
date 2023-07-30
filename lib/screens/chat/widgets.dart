import 'package:flutter/material.dart';
import '../../model/chat.dart';
import '../../states/chat.dart';
import '../../states/medium_states.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConversationItemCompat extends StatelessWidget {
  final Chat conversation;

  const ConversationItemCompat({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    // 滑动删除的背景
    Widget textDelete = Text(
      localizations.text_delete,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
    );
    Widget background = Container(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            textDelete,
            Expanded(child: Container(height: 0)),
            textDelete,
          ],
        ),
      ),
    );

    return Dismissible(
        key: Key(conversation.id.toString()),
        background: background,
        onDismissed: (direction) async {
          final ScaffoldMessengerState messengerState =
              ScaffoldMessenger.of(context);

          await Chat.deleteChat(conversation);

          messengerState.showSnackBar(
            SnackBar(
              content: Text(localizations.text_chat_deleted),
              action: SnackBarAction(
                label: localizations.action_cancel,
                onPressed: () {
                  // Code to execute.
                  Chat.addChat(conversation);
                },
              ),
            ),
          );
        },
        child: InkWell(
          onTap: () {
            ChatStates.updateActiveConversation(conversation);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: 0.5, color: Theme.of(context).dividerColor))),
            child: Row(
              children: [
                Expanded(
                    child: ListTile(
                  title: Text(
                    conversation.title ?? "",
                    maxLines: 2,
                  ),
                )),
              ],
            ),
          ),
        ));
  }
}

class ConversationItemMedium extends StatelessWidget {
  final Chat chat;

  const ConversationItemMedium({super.key, required this.chat});

  int get _activeConvId {
    return ChatStates.activeChat.id;
  }

  int get _convId {
    return chat.id;
  }

  bool get _isActive {
    return _convId != -1 && _convId == _activeConvId;
  }

  void _onPressed() {
    ChatStates.updateActiveConversation(chat);
    ChatMediumStates.toggleDrawerState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Chat>(
      valueListenable: ChatStates.activeChatNotifier,
      builder: (BuildContext context, Chat chat, Widget? child) {
        List<Widget> rowItems = [
          Expanded(
              child: Text(
            this.chat.title ?? "...",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )),
        ];

        Widget content = Row(
          children: rowItems,
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: _isActive
              ? FilledButton.tonal(onPressed: _onPressed, child: content)
              : TextButton(
                  onPressed: _onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: content,
                  )),
        );
      },
    );
  }
}

typedef ConversationItemExpanded = ConversationItemMedium;

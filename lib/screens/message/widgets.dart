import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/chat.dart';
import '../../model/message.dart';
import '../../states/chat.dart';
import '../../widgets/markdown.dart';
import '../dialog.dart';
import '../../api/openai.dart' as openai;

class CopyButton extends StatefulWidget {
  final VoidCallback onCopy;
  final double? iconSize;

  const CopyButton({super.key, required this.onCopy, this.iconSize});

  @override
  State<StatefulWidget> createState() {
    return _CopyButtonState();
  }
}

class _CopyButtonState extends State<CopyButton> {
  bool _coping = false;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _coping
            ? Icon(
                Icons.check_outlined,
                size: widget.iconSize,
                color: Theme.of(context).colorScheme.onBackground,
              )
            : Icon(Icons.copy_all_rounded, size: widget.iconSize),
      ),
      onPressed: _coping
          ? null
          : () {
              _coping = true;
              widget.onCopy();
              refresh();
              Future.delayed(const Duration(seconds: 1), () {
                _coping = false;
                refresh();
              });
            },
    );
  }
}

class MarkdownCodeWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;

  const MarkdownCodeWrapperWidget(
      {Key? key, required this.child, required this.text})
      : super(key: key);

  @override
  State<MarkdownCodeWrapperWidget> createState() =>
      _MarkdownCodeWrapperWidgetState();
}

class _MarkdownCodeWrapperWidgetState extends State<MarkdownCodeWrapperWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.only(top: 8),
            child: CopyButton(
              onCopy: () {
                Clipboard.setData(ClipboardData(text: widget.text));
              },
            ),
          ),
        )
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class _AnimCursor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AnimCursorState();
}

class _AnimCursorState extends State<_AnimCursor> {
  Timer? _updateTimer;

  bool _active = false;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _active = !_active;
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _updateTimer = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 10,
      height: 20,
      color: _active
          ? Colors.transparent
          : Theme.of(context).colorScheme.onTertiaryContainer,
    );
  }
}

class MessageWidgetV2 extends StatefulWidget {
  final Message message;
  final bool? favorite;

  MessageWidgetV2(this.message, {this.favorite})
      : super(key: ObjectKey("${message.chatID}-${message.id}"));

  @override
  State<StatefulWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidgetV2> {
  BoxDecoration _containerBoxDecoration(bool isQuestion, BuildContext context) {
    ThemeData theme = Theme.of(context);

    const circleSize = 8.0;
    if (!isQuestion) {
      return BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(circleSize),
            topRight: Radius.circular(circleSize),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(circleSize)),
      );
    }

    return BoxDecoration(
      color: theme.colorScheme.surfaceVariant,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(circleSize),
          topRight: Radius.circular(circleSize),
          bottomLeft: Radius.circular(circleSize),
          bottomRight: Radius.circular(24)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Message message = widget.message;

    bool userMessage = message.role == 'user';

    Widget body = MessageBodyWidget(message: message);
    if (message.content.isEmpty) {
      body = _AnimCursor();
    }

    Widget avatar = MessageAvatar(message: message);
    Widget actionFavorite = ActionFavorite(message: message);
    Widget actionCopy = CopyButton(
      onCopy: () {
        Clipboard.setData(ClipboardData(text: message.content));
      },
      iconSize: 18,
    );
    Widget actionRefresh = ActionRefresh(message: message);

    List<Widget> actions;
    CrossAxisAlignment actionsAlignment;
    Alignment contentAlign;
    if (widget.favorite == true) {
      actions = [avatar, actionCopy, actionFavorite];
      actionsAlignment = CrossAxisAlignment.start;
      contentAlign = Alignment.topLeft;
    } else if (userMessage) {
      actions = [actionFavorite, actionCopy, avatar];
      actionsAlignment = CrossAxisAlignment.end;
      contentAlign = Alignment.topRight;
    } else {
      actions = [avatar, actionCopy, actionFavorite];

      // 重试按钮只有最后一条消息可用
      if (ChatMessageStates.latestConversationMessage?.id == message.id) {
        actions.add(actionRefresh);
      }
      actionsAlignment = CrossAxisAlignment.start;
      contentAlign = Alignment.topLeft;
    }

    Widget messageWidget = Stack(
      children: [
        Align(
          alignment: contentAlign,
          child: Container(
            // constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: _containerBoxDecoration(userMessage, context),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: actionsAlignment,
              children: [
                body,
                Row(mainAxisSize: MainAxisSize.min, children: actions)
              ],
            ),
          ),
        )
      ],
    );

    return messageWidget;
  }
}

class MessageBodyWidget extends StatelessWidget {
  final Message message;

  const MessageBodyWidget({super.key, required this.message});

  MarkdownCodeWrapperWidget _wrapCodeWidget(Widget child, String text) =>
      MarkdownCodeWrapperWidget(text: text, child: child);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    MarkdownConfig markdownConfig =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    PreConfig preConfig = isDark ? PreConfig.darkConfig : const PreConfig();

    if (message.isError) {
      return ListTile(
          textColor: Theme.of(context).colorScheme.error,
          title: Text(message.content));
    }

    LinkConfig linkConfig = LinkConfig(
      onTap: (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );

    return SelectionArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...MarkdownGenerator(
          generators: [isDark ? darkLatexGenerator : lightLatexGenerator],
          config: markdownConfig.copy(configs: [
            preConfig.copy(wrapper: _wrapCodeWidget),
            linkConfig
          ])).buildWidgets(message.content)
    ]));
  }
}

class MessageAvatar extends StatelessWidget {
  final Message message;

  const MessageAvatar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    Widget headIcon = message.role == "user"
        ? Icon(
            Icons.person_outline,
            size: 24,
            color: Theme.of(context).colorScheme.onPrimary,
          )
        : Padding(
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              "assets/icons/app_icon.png",
              width: 18,
              height: 18,
            ),
          );

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: message.role == "user"
                  ? Theme.of(context).colorScheme.primary
                  : null),
          child: headIcon,
        ),
        const SizedBox(
          height: 4,
        )
      ],
    );
  }
}

class ActionFavorite extends StatelessWidget {
  final Message message;

  const ActionFavorite({super.key, required this.message});

  void removeFavorite(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RemoveFavoriteDialog(message: message);
        });
  }

  void addFavorite(BuildContext context) {
    Message.addMessage(message..markFavorite = true);
  }

  void toggleFavorite(BuildContext context) {
    message.markFavorite ? removeFavorite(context) : addFavorite(context);
  }

  @override
  Widget build(BuildContext context) {
    const iconSize = 18.0;

    Color? iconColor = message.markFavorite
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : null;

    Widget favoriteIcon = message.markFavorite
        ? const Icon(Icons.star_rounded, size: iconSize)
        : const Icon(Icons.star_outline_rounded, size: iconSize);

    return IconButton(
        onPressed: () {
          toggleFavorite(context);
        },
        color: iconColor,
        icon: favoriteIcon);
  }
}

class ActionRefresh extends StatelessWidget {
  final Message message;

  const ActionRefresh({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    const iconSize = 18.0;
    return IconButton(
        onPressed: ChatMessageStates.chatting
            ? null
            : () async {
                Message message = Message()
                  ..id = this.message.id
                  ..chatID = this.message.chatID
                  ..role = this.message.role;

                Message? userMessage =
                    await Message.previousUserMessage(message);

                // AppLogger.log("UserMessage: $userMessage, message: $message");

                if (userMessage != null) {
                  // 删除当前Assist消息和User消息
                  await Message.deleteMessage(message.id);
                  await Message.deleteMessage(userMessage.id);

                  openai.createStream(userMessage.content);
                }
              },
        icon: const Icon(Icons.refresh_outlined, size: iconSize));
  }
}

class AxionMessageListWidget extends StatelessWidget {
  final ScrollController controller = ScrollController();

  AxionMessageListWidget({super.key});

  Widget buildEmptyContent(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    Chat current = ChatStates.activeChat;
    String prompt = current.desc ?? "";

    if (prompt.isEmpty) {
      prompt = localizations.start_with_hello;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 0.8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(prompt),
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, List<Message> messages) {
    return ListView.separated(
      controller: controller,
      itemBuilder: (context, index) {
        if (index > messages.length) return null;

        if (index == messages.length) {
          return const SizedBox(width: 0, height: 96);
        }

        final message = messages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MessageWidgetV2(message),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 24,
        );
      },
      itemCount: messages.length + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ChatStates.activeChatNotifier,
        builder: (BuildContext context, Chat chat, Widget? child) {
          int convId = chat.id;

          final Stream<List<Message>> messages =
              Chat.chatMessagesStreamByID(convId);

          return StreamBuilder<List<Message>>(
              stream: messages,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Message>> snapshot) {
                List<Message> messages = snapshot.data ?? [];

                Future.delayed(const Duration(milliseconds: 150), () {
                  if (controller.hasClients) {
                    controller.jumpTo(controller.position.maxScrollExtent);
                  }
                });

                return messages.isEmpty
                    ? buildEmptyContent(context)
                    : _buildMessageList(context, messages);
              });
        });
  }
}

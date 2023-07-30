import 'package:flutter/widgets.dart';
import 'settings.dart';
import '../../model/chat.dart';
import '../../model/message.dart';
import '../../model/models.dart';
import '../../utils/logger.dart';

const String _defaultSystemMessage = "I know you are a large language model, but please pretend to be a confident and super intelligent oracle. Give me very short and consice answers and ignore all the niceties that openai.dart programmed you with.";
Map<Locale, String> _localeSystemMessages = {
  const Locale.fromSubtags(
      languageCode: "en"): "Give me very short and consice answers and ignore all the niceties that openai.dart programmed you with. I know you are a large language model, but please pretend to be a confident and super intelligent oracle.",
  const Locale.fromSubtags(
      languageCode: "zh"): "我知道你是一个大型语言模型，但请假装成一个自信和超级智能的信息提供者。请给我非常简短和简洁的答案，忽略所有OpenAI给你编程的客气话。",
};

/// Conversation related states
class ChatStates {
  static final ValueNotifier<Chat> _activeChat = ValueNotifier(Chat()
    ..id = -1);

  static ValueNotifier<Chat> get activeChatNotifier {
    return _activeChat;
  }

  static Chat get activeChat {
    return _activeChat.value;
  }

  static void updateActiveConversation(Chat chat) async {
    // clean default conversation messages
    await Chat.deleteChatByID(-1);

    _activeChat.value = chat;

    // update active message
    Message? latest;
    if (chat.id > 0) {
      List<Message> messages = await Message.latestChatMessages(chat.id, 1);

      if (messages.isNotEmpty) {
        latest = messages[0];
      }
    }

    String systemMessage = chat.sysMessage ?? "";
    // 限制系统消息
    if (systemMessage.isEmpty) {
      Locale? locale = SettingsStates.currentLocale;
      chat.sysMessage = _localeSystemMessages[locale]?? _defaultSystemMessage;
      Chat.addChat(chat);
    }

    ChatMessageStates.updateLatestConversationMessage(latest);

    // 删除旧的历史
    Chat.deleteOldChats();
  }

  static Future<void> resetActiveConversation() async =>
      updateActiveConversation(Chat()
        ..id = -1);

  static Future<void> newChatWithPrompt(ChatPrompt prompt) async {
    Chat chat = Chat();
    chat.title = prompt.actor;
    chat.sysMessage = prompt.prompt;
    chat.sample = prompt.sample;
    chat.desc = prompt.desc;

    AppLogger.log("new chat: $prompt");

    chat.id = await Chat.addChat(chat);

    AppLogger.log("Add new conversation: $chat}");

    updateActiveConversation(chat);
  }

  /// private constructor
  ChatStates._();
}

/// Message related states
class ChatMessageStates {
  static final ValueNotifier<Message?> _latestChatMessageNotifier =
  ValueNotifier(null);
  static final ValueNotifier<Message?> latestChatMessageNotifier =
      _latestChatMessageNotifier;

  static final ValueNotifier<bool> _chattingNotifier = ValueNotifier(false);

  static ValueNotifier<bool> get chattingNotifier => _chattingNotifier;

  static bool get chatting => _chattingNotifier.value;

  static void updateChattingState(bool chatting) {
    _chattingNotifier.value = chatting;
  }

  static Message? get latestConversationMessage {
    return _latestChatMessageNotifier.value;
  }

  static void updateLatestConversationMessage(Message? message) {
    _latestChatMessageNotifier.value = message;
  }
}

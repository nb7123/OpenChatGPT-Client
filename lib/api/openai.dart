import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import '../model/chat.dart';
import '../model/message.dart';
import '../states/chat.dart';
import '../states/settings.dart';
import '../states/usage.dart';
import '../utils/logger.dart';
import '../utils/utils.dart';

const defaultOpenAiBaseUrl = "https://api.openai.com/";
const defaultApiKey = "Your API-KEY";

Future<Chat> newAndActiveConversation() async {
  // remove temp messages
  await Chat.deleteChatByID(-1);
  Chat chat = Chat()
    ..stream = true
    ..title = '...';

  chat.id = await Chat.addChat(chat);
  AppLogger.log("new conversation: $chat");

  ChatStates.updateActiveConversation(chat);

  return chat;
}

Future<void> createStream(String prompt) async {
  Chat chat = ChatStates.activeChat;
  if (chat.id < 0) {
    chat = await newAndActiveConversation();
    chat.title = prompt;
  }

  // add
  Message promptMessage = Message()
    ..role = OpenAIChatMessageRole.user.name
    ..chatID = chat.id
    ..content = prompt
    ..complete = true;

  promptMessage.id = await Message.addMessage(promptMessage);

  Message assistMessage = Message()
    ..role = OpenAIChatMessageRole.assistant.name
    ..chatID = chat.id;
  assistMessage.id = await Message.addMessage(assistMessage);

  AppLogger.log("(prompt: $promptMessage, assist: $assistMessage)");

  try {
    await _createStream(promptMessage, assistMessage,
        contextSensitive: chat.contextSensitive);
  } catch (e) {
    AppLogger.log("$e");
    assistMessage.finishReason = "error";
    assistMessage.content = e.toString();
  }

  await Message.addMessage(assistMessage..complete = true);
  ChatMessageStates.updateLatestConversationMessage(assistMessage);

  AppLogger.log("Generate completed.");

  ChatMessageStates.updateChattingState(false);
  ChatStates.updateActiveConversation(chat);
}

Future<void> _createStream(Message promptMessage, Message assistMessage,
    {bool contextSensitive = false}) async {
  ChatMessageStates.updateChattingState(true);

  // reset assistant message content
  assistMessage
    ..parentId = promptMessage.id
    ..content = ''
    ..tokens = 0
    ..finishReason = null;

  await Message.addMessage(assistMessage);

  final apiKey = SettingsStates.settings.openAiApiKey ?? "";
  if (apiKey.isEmpty) {
    throw Exception("Invalid api key: $apiKey");
  }

  OpenAI.baseUrl = SettingsStates.settings.openAiBaseUrl;
  OpenAI.apiKey = apiKey;

  OpenAI openAI = OpenAI.instance;

  List<OpenAIChatCompletionChoiceMessageModel> choiceMessages = [];
  int tokens = promptMessage.tokens;

  OpenAIChatCompletionChoiceMessageModel? systemMessage;
  if ((ChatStates.activeChat.sysMessage?? '').isNotEmpty) {
    systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system, content: ChatStates.activeChat.sysMessage?? '');

    tokens += Utils.messageTokenSizeForGPT3Dot5(systemMessage);
  }

  final contextWindow = SettingsStates.settings.contextWindow;
  final promptMaxTokens = SettingsStates.settings.maxPromptTokens;

  if (contextSensitive) {
    List<Message> contextMessages =
        await Message.historyChatMessages(promptMessage, 100);

    for (Message m in contextMessages) {
      // Ignore failed message
      if (m.isError) continue;

      if (promptMessage.parentId == -1) {
        promptMessage.parentId = m.id;
      }

      OpenAIChatMessageRole role = OpenAIChatMessageRole.user;
      if (m.role == OpenAIChatMessageRole.assistant.name) {
        role = OpenAIChatMessageRole.assistant;
      }

      OpenAIChatCompletionChoiceMessageModel message = OpenAIChatCompletionChoiceMessageModel(
          role: role, content: m.content);

      final messageTokens = m.tokens > 0
          ? m.tokens
          : Utils.messageTokenSizeForGPT3Dot5(message);

      // 历史消息最少两条，最大Token数不能超过512，这里应该根据会员等级来处理
      if (tokens + messageTokens > promptMaxTokens) {
        break;
      }

      tokens += messageTokens;

      choiceMessages.insert(
          0,
          message);
    }
  }

  OpenAIChatCompletionChoiceMessageModel prompt =
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: promptMessage.content);
  promptMessage.tokens = Utils.messageTokenSizeForGPT3Dot5(prompt);
  tokens += promptMessage.tokens;

  choiceMessages.add(prompt);

  if (systemMessage != null) {
    choiceMessages.insert(0, systemMessage);
  }

  AppLogger.log("Choices message: $choiceMessages");

  String chatModel = SettingsStates.chatModel;

  final maxTokens = contextWindow - tokens;
  AppLogger.log("Prompt tokens: $tokens, max tokens: $maxTokens");
  Stream<OpenAIStreamChatCompletionModel> chatStream = openAI.chat.createStream(
      model: chatModel, messages: choiceMessages, maxTokens: maxTokens);

  try {
    await for (OpenAIStreamChatCompletionModel message in chatStream) {
      OpenAIStreamChatCompletionChoiceModel choice = message.choices[0];
      String? deltaContent = choice.delta.content;

      if (choice.finishReason != null) {
        assistMessage.finishReason = choice.finishReason;

        await Message.addMessage(assistMessage);
      }

      if (deltaContent == null) continue;

      assistMessage.content = '${assistMessage.content}$deltaContent';

      assistMessage.tokens = Utils.messageTokenSizeForGPT3Dot5(
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.assistant,
              content: assistMessage.content));

      tokens += assistMessage.tokens;
      await Message.addMessage(assistMessage);

      // 更新Tokens用量
      await DailyUsageStates.tokensUsed(tokens);
    }
  } catch (e) {
    assistMessage
      ..content = e.toString()
      ..finishReason = 'error';

    AppLogger.log("Failed message: $assistMessage");
    await Message.addMessage(assistMessage);
  }
}

import 'package:dart_openai/dart_openai.dart';
import '../model/database.dart';
import 'package:isar/isar.dart';

part 'message.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;
  int parentId = -1;

  int chatID = -1;

  String role = 'user';
  String content = '';

  int tokens = -1;

  String? finishReason;

  // 收藏
  bool markFavorite = false;

  int created = DateTime.now().millisecondsSinceEpoch;
  bool complete = false;

  bool get isError {
    return finishReason == 'error';
  }

  @Ignore()
  bool get isUserMessage {
    return role == OpenAIChatMessageRole.user.name;
  }

  @Ignore()
  bool get isSystemMessage {
    return role == OpenAIChatMessageRole.system.name;
  }

  @Ignore()
  bool get isAssistantMessage {
    return role == OpenAIChatMessageRole.assistant.name;
  }

  static Isar get isar => ChatDatabase.isar;

  static Future<List<int>> addChatMessages(List<Message>? messages) async {
    if (messages == null) return Future.value([0]);

    return isar.writeTxn(() {
      return isar.messages.putAll(messages);
    });
  }

  static Future<int> addMessage(Message? message) async {
    if (message == null) return Future.value(0);

    return (await addChatMessages([message]))[0];
  }

  /// find message with int id
  static Future<Message?> findMessageWithId(int id) {
    return isar.messages.filter().idEqualTo(id).findFirst();
  }

  /// find parent message
  static Future<Message?> findParentMessage(Message message) {
    return isar.messages.filter().idEqualTo(message.parentId).findFirst();
  }

  /// The latest [size] messages of the [chatID]'s conversation
  static Future<List<Message>> latestChatMessages(int? chatID, int size) {
    if (chatID == null || chatID == -1) return Future.value([]);

    return isar.messages
        .filter()
        .chatIDEqualTo(chatID)
        .sortByCreatedDesc()
        .limit(size)
        .findAll();
  }

  /// History messages
  static Future<List<Message>> historyChatMessages(Message message, int size) {
    return isar.messages
        .filter()
        .chatIDEqualTo(message.chatID)
        .idLessThan(message.id)
        .sortByCreatedDesc()
        .limit(size)
        .findAll();
  }

  /// Favorite messages
  static Stream<List<Message>> favorites() {
    return isar.messages
        .filter()
        .markFavoriteEqualTo(true)
        .sortByCreated()
        .watch(fireImmediately: true);
  }

  /// 删除消息
  static Future<bool> deleteMessage(int id) {
    return isar.writeTxn(() => isar.messages.delete(id));
  }

  ///
  /// 查询assist消息的直接前一条用户消息
  /// 如果 @param assistMessage 是用户消息，返回null
  static Future<Message?> previousUserMessage(Message assistMessage) async {
    if (assistMessage.role == "user") return null;

    List<Message> messages = await historyChatMessages(assistMessage, 1);
    // AppLogger.log("Messages: $messages");
    if (messages.isNotEmpty && messages[0].role == "user") {
      return messages[0];
    }

    return null;
  }

  @override
  String toString() {
    return 'Message(id: $id,'
        ' parentId: $parentId,'
        ' conversationId: $chatID,'
        ' role: $role,'
        ' content: $content,'
        ' tokens: $tokens,'
        ' finishReason: $finishReason,'
        ' isError: $isError,'
        ' created: $created)';
  }
}

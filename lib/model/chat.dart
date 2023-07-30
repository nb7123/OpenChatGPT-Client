import '../model/database.dart';
import '../model/message.dart';
import 'package:isar/isar.dart';

part 'chat.g.dart';

@collection
@Name('Chat')
class Chat {
  Id id = Isar.autoIncrement;

  String? title;

  // 特定角色
  String? sysMessage;
  String? sample;
  String? desc;

  float temperature = 0.3;
  bool stream = true;
  int maxTokens = -1;

  /// Context sensitive
  bool contextSensitive = true;

  int created = DateTime.now().millisecondsSinceEpoch;

  static Isar get isar => ChatDatabase.isar;

  static Future<List<int>> addChats(List<Chat>? chats) async {
    if (chats == null) return Future.value([0]);

    return isar.writeTxn(() {
      return isar.chats.putAll(chats);
    });
  }

  static Future<int> addChat(Chat? chat) async {
    if (chat == null) return Future.value(0);

    return (await addChats(List.filled(1, chat)))[0];
  }

  static Stream<List<Chat>> chatsStream() {
    return isar.chats
        .filter()
        .idGreaterThan(0)
        .sortByCreatedDesc()
        .watch(fireImmediately: true);
  }

  ///
  static Future<Chat?> findChatByID(int chatID) {
    return isar.chats.filter().idEqualTo(chatID).findFirst();
  }

  static Future<bool> deleteChatByID(int? convId) async {
    if (convId == null) return Future.value(false);

    return isar.writeTxn(() async {
      await isar.messages.filter().chatIDEqualTo(convId).deleteAll();
      return Future.value(await isar.chats.delete(convId));
    });
  }

  static Stream<List<Message>> chatMessagesStream(Chat? chat) =>
      chatMessagesStreamByID(chat?.id);

  static Stream<List<Message>> chatMessagesStreamByID(int? chatID) {
    if (chatID == null) return const Stream.empty();

    return isar.messages
        .filter()
        .chatIDEqualTo(chatID)
        .sortByCreated()
        .watch(fireImmediately: true);
  }

  static Future<bool> deleteChat(Chat? chat) => deleteChatByID(chat?.id);

  ///
  /// 删除旧的历史记录，最多记录100项
  static Future<void> deleteOldChats() async {
    List<Chat> oldest =
        await isar.chats.where().sortByCreatedDesc().offset(100).findAll();

    return isar.writeTxn(
        () => isar.chats.deleteAll(oldest.map((chat) => chat.id).toList()));
  }

  @override
  String toString() {
    return 'ChatConversation(id: $id,'
        ' title: $title,'
        ' systemMessage: $sysMessage,'
        ' temperature: $temperature,'
        ' contextSensitive: $contextSensitive,'
        ' created: $created)';
  }
}

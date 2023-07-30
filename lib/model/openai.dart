
class ChatModel {
  static const String gpt_3Dot5_0613 = "gpt-3.5-turbo-0613";
  static const String gpt_3Dot5_0613_16k = "gpt-3.5-turbo-16k-0613";
  static const String gpt_4_0613 = "gpt-4-0613";
  static const String gpt_4_0613_32k = "gpt-4-32k-0613";

  final String name;
  final int maxTokens;

  ChatModel(this.name, this.maxTokens);

  static ChatModel? findModelByName(String name) {
    for (ChatModel model in supportedModels) {
      if (model.name == name) {
        return model;
      }
    }

    return null;
  }

  static final List<ChatModel> supportedModels = [
    ChatModel(gpt_3Dot5_0613, 4096),
    ChatModel(gpt_3Dot5_0613_16k, 16384),
    ChatModel(gpt_4_0613, 8192),
    ChatModel(gpt_4_0613_32k, 32768),
  ];
}
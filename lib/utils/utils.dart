import 'package:dart_openai/dart_openai.dart';
import 'package:open_chatgpt/utils/logger.dart';
import 'package:tiktoken/tiktoken.dart';

import '../model/openai.dart';

class Utils {
  ///
  /// Tiktoken
  /// 当前模型对应的Token大小
  ///
  static int messageTokenSizeForGPT3Dot5(
      OpenAIChatCompletionChoiceMessageModel message) {
    return messageTokenSize(ChatModel.gpt_3Dot5_0613, message);
  }

  static int messageTokenSize(String model,
      OpenAIChatCompletionChoiceMessageModel message) {
    final encoding = encodingForModel(model);

    const tokensPerMessage = 3;
    int numTokens = 0;

    numTokens += tokensPerMessage;
    numTokens += encoding.encode(message.content).length;
    numTokens += encoding.encode(message.role.name).length;

    numTokens += 3; // every reply is primed with <|start|>assistant<|message|>

    AppLogger.log("Message tokens: $numTokens, $message");
    return numTokens;
  }

  Utils._();
}

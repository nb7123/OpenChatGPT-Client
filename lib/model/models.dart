import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class ChatPrompt {
  @JsonKey(name: 'act')
  final String actor;
  final String prompt;
  @JsonKey(name: 'icon')
  final String icon;
  @JsonKey(name: 'sample')
  final String sample;
  @JsonKey(name: 'desc')
  final String? desc;

  @JsonKey(name: 'context_sensitive')
  final bool? contextSensitive;

  const ChatPrompt(
      {required this.actor,
      required this.prompt,
      required this.sample,
      required this.desc,
      required this.icon,
      this.contextSensitive});

  factory ChatPrompt.fromJson(Map<String, dynamic> json) =>
      _$ChatPromptFromJson(json);

  Map<String, dynamic> toJson() => _$ChatPromptToJson(this);

  @override
  String toString() {
    return 'ChatPrompt(actor: $actor, prompt: $prompt, sample: $sample, desc: $desc)';
  }
}

@JsonSerializable()
class Prompts {
  final List<ChatPrompt> prompts;

  Prompts({required this.prompts});

  factory Prompts.fromJson(Map<String, dynamic> json) =>
      _$PromptsFromJson(json);

  Map<String, dynamic> toJson() => _$PromptsToJson(this);

  @override
  String toString() {
    return 'Prompts(prompts: $prompts)';
  }
}
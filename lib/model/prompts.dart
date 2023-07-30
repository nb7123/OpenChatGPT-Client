
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'prompts-zh.dart';

import 'models.dart';
import 'prompts-en.dart';

Map<Locale, List<ChatPrompt>> _cache = {};

List<ChatPrompt> chatPrompts(BuildContext context, [bool? update]) {
  Locale locale = Localizations.localeOf(context);

  if (update == true || _cache[locale] == null) {
    List<ChatPrompt> prompts = locale.languageCode == "zh" ? promptsZh : promptsEn;

    List<ChatPrompt> shuffleList = List.from(prompts);
    shuffleList.shuffle(Random());

    _cache[locale] = shuffleList;
  }


  return _cache[locale]?? [];
}

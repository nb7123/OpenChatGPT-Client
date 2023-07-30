import 'package:flutter/cupertino.dart';

class ChatMediumStates {
  static final ValueNotifier<bool> _drawerStateNotifier = ValueNotifier(false);

  static ValueNotifier<bool> get drawerStateNotifier => _drawerStateNotifier;

  static bool get drawerState => _drawerStateNotifier.value;

  static void toggleDrawerState() {
    _drawerStateNotifier.value = !_drawerStateNotifier.value;
  }
}
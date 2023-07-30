import 'package:flutter/material.dart';
import '../../states/chat.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/input.dart';
import 'widgets.dart';

class ChatCompatV3 extends StatelessWidget {
  const ChatCompatV3({super.key});

  @override
  Widget build(BuildContext context) {
    String? title = ChatStates.activeChat.title;

    return Scaffold(
      appBar: AxionAppBar(
        title: title != null && title.isNotEmpty
            ? Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
            : null,
        actions: const [],
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: Stack(
            children: [
              AxionMessageListWidget(),
              const Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(child: InputWidget()))
            ],
          ),
        ),
      ),
    );
  }
}
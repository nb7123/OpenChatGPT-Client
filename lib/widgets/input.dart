import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../api/openai.dart' as openai;
import '../model/chat.dart';
import '../states/chat.dart';

class InputWidget extends StatefulWidget {
  final Future<void> Function()? beforeSend;

  const InputWidget({super.key, this.beforeSend});

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback(_frameChanged);
  }

  void _focusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {});
    }
  }

  // 检查焦点情况，激活状态时显示广告区域
  void _frameChanged(Duration ts) => _focusChanged();

  void _hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  // 上一次的输入长度，每一次的按键变化，如果有文本输入，长度会发生变化，
  //考虑到输入法的处理，如果长度没变化的按键，我们不自行处理
  int _enterStart = -1;

  void _handleKeyEvent(RawKeyEvent keyEvent) {
    // Enter 键
    if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
      // Enter down
      if (keyEvent is RawKeyDownEvent) {
        _enterStart = _controller.selection.start;
        return;
      }

      // Enter up，这时候内容发生变化，如果Shift 键按下，则不处理
      if (keyEvent.isShiftPressed) return;
      // 输入的仅是一个换行，需要将换行删掉，然后发送
      String changedString =
          _controller.text.substring(_enterStart, _controller.selection.start);
      // AppLogger.log("Changed text: ${changedString}AAA, is new line: ${changedString == "\n"}");
      if (changedString == "\n") {
        String text = _controller.text;
        text = text.substring(0, _enterStart) +
            text.substring(_controller.selection.start);

        _controller.text = text;
        // AppLogger.log("Final text: $text XXX");
        _callCompletionApi();
        return;
      }
    }

    _enterStart = -1;
  }

  Future<void> _callCompletionApi() async {
    _hideKeyboard(context);

    final prompt = _controller.text.trim();
    if (prompt.isNotEmpty) {
      _controller.clear();

      if (widget.beforeSend != null) {
        await widget.beforeSend!();
      }

      openai.createStream(prompt);
    }

    setState(() {});
  }

  String get _hintText {
    return AppLocalizations.of(context)!.question;
  }

  Widget _textField(BuildContext context) {
    Widget textField = TextField(
      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      cursorColor: Theme.of(context).colorScheme.onPrimary,
      focusNode: _focusNode,
      maxLines: 5,
      minLines: 1,
      controller: _controller,
      textInputAction: TextInputAction.newline,
      onChanged: (text) {
        setState(() {});
      },
      onSubmitted: (text) {
        _callCompletionApi();
      },
      decoration: InputDecoration(
        hintText: _hintText,
        hintStyle:
            TextStyle(color: Theme.of(context).colorScheme.surfaceVariant),
        border: InputBorder.none,
        // errorText: remain >= 0 ? "${localizations.free_count}$remain" : null
      ),
    );

    if (Platform.isAndroid || Platform.isIOS) return textField;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyEvent,
      child: textField,
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // 获得焦点但输入内容为空时，显示为取消输入按钮
    if (_controller.text.trim().isEmpty && _focusNode.hasFocus) {
      return IconButton(
        icon: const Icon(Icons.cancel_rounded),
        color: Theme.of(context).colorScheme.onPrimary,
        onPressed: () {
          _focusNode.unfocus();
          setState(() {});
        },
      );
    }

    // 无焦点时不显示按钮
    if (!_focusNode.hasFocus) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }

    // 默认返回发送按钮
    return _SendButton(_callCompletionApi);
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).addListener(_focusChanged);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations localizations = AppLocalizations.of(context)!;

    final bool active = _focusNode.hasFocus;
    List<Widget> widgets = [];
    if (active) {
      Chat current = ChatStates.activeChat;

      List<Widget> activeWidgets = [];

      if (current.desc?.isNotEmpty == true) {
        activeWidgets.add(SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(current.desc ?? ""),
            ),
          ),
        ));

        activeWidgets.add(const SizedBox(height: 16));
      }

      if (current.sample?.isNotEmpty == true) {
        activeWidgets.add(SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text("${localizations.try_this}\n${current.sample ?? ""}"),
            ),
          ),
        ));
      }

      // 如果activeWidgets 没有的时候，显示一下看广告可以获取免费次数
      // 每天一次
      // if (!UsageLimitStates.usageLimit.rewardedAdShowed &&
      //     AdMobStates.rewardedAd != null) {
      //   activeWidgets.add(Card(child: Text(localizations.free_plan),));
      //   activeWidgets.add(TextButton(
      //     onPressed: () {
      //       _focusNode.unfocus();
      //       setState(() {});
      //       RewardedAd? ad = AdMobStates.rewardedAd;
      //       if (ad != null) {
      //         ad.show(onUserEarnedReward: (ad, rewarded) {
      //           UsageLimitStates.gotRewarded();
      //         });
      //       }
      //     },
      //     child: Text(localizations.watch_ad_get_free_times),
      //   ));
      // }

      widgets.add(Expanded(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: activeWidgets,
          ),
        ),
      ));

      // 广告这样是不可以显示的
      // widgets.add(const AdBannerLargeMainWidget());
      widgets.add(const SizedBox(height: 16));
    }

    Widget inputArea = Container(
      margin: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Card(
        color: colorScheme.primary,
        child: Padding(
          padding: EdgeInsets.only(
              left: 16, top: active ? 6 : 0, right: 8, bottom: active ? 6 : 0),
          child: Row(
            children: [
              Expanded(child: _textField(context)),
              // 上传文件支持
              // IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file_outlined)),

              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );

    inputArea = Hero(
      tag: "inputArea",
      child: Material(
        color: Colors.transparent,
        child: inputArea,
      ),
    );
    // return inputArea;

    Widget mask = active
        ? Opacity(
            opacity: 0.9,
            child: Container(
              color: colorScheme.background,
              // child: ,
            ),
          )
        : const SizedBox(height: 0);

    return Stack(
      children: [
        mask,
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: active ? MainAxisSize.max : MainAxisSize.min,
            children: [...widgets, inputArea],
          ),
        )
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SendButton(this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ChatMessageStates.chattingNotifier,
        builder: (context, value, child) {
          return IconButton(
              onPressed: value ? null : onPressed,
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    // color: colorScheme.onSecondaryContainer,
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(
                  Icons.send_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ));
        });
  }
}

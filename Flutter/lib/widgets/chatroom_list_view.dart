// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voiceroomkit_ui/app_config.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';

import '../generated/l10n.dart';

enum ChatroomMessageType {
  kText,
  kGift,
  kNotify,
}

enum ChatroomNotifyType {
  kMemberJoin,
  kMemberLeave,
}

abstract class ChatroomMessage {
  final ChatroomMessageType messageType;
  final String userUuid;
  final String nickname;

  ChatroomMessage({
    required this.messageType,
    required this.nickname,
    required this.userUuid,
  });
}

class ChatroomTextMessage extends ChatroomMessage {
  String text;
  bool isAnchor;

  ChatroomTextMessage({
    required this.text,
    this.isAnchor = false,
    required nickname,
    required userUuid,
  }) : super(
          messageType: ChatroomMessageType.kText,
          nickname: nickname,
          userUuid: userUuid,
        );
}

class ChatroomGiftMessage extends ChatroomMessage {
  int giftId;

  ChatroomGiftMessage({
    required this.giftId,
    required userUuid,
    required nickname,
  }) : super(
          messageType: ChatroomMessageType.kGift,
          nickname: nickname,
          userUuid: userUuid,
        );
}

class ChatroomNotifyMessage extends ChatroomMessage {
  ChatroomNotifyType notifyType;

  ChatroomNotifyMessage({
    required this.notifyType,
    required userUuid,
    required nickname,
  }) : super(
          messageType: ChatroomMessageType.kNotify,
          nickname: nickname,
          userUuid: userUuid,
        );
}

class ChatroomMessagesValue {
  List<ChatroomMessage> messages;

  ChatroomMessagesValue({
    required this.messages,
  });
}

class ChatroomMessagesController extends ValueNotifier<ChatroomMessagesValue> {
  List<ChatroomMessage> get messages => value.messages;

  ChatroomMessagesController({List<ChatroomMessage>? messages})
      : super(messages == null
            ? ChatroomMessagesValue(
                messages: List<ChatroomMessage>.empty(growable: true))
            : ChatroomMessagesValue(messages: messages));

  addMessage(ChatroomMessage message) {
    messages.add(message);
    value = ChatroomMessagesValue(messages: messages);
  }
}

class ChatroomListView extends StatefulWidget {
  final ChatroomMessagesController controller;

  const ChatroomListView({Key? key, required this.controller})
      : super(key: key);

  @override
  State<ChatroomListView> createState() => _ChatroomListViewState();
}

class _ChatroomListViewState extends State<ChatroomListView> {
  ChatroomMessagesController get controller => widget.controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _scrollController.animateTo(
              0.0, //滚动到底部
              duration: const Duration(milliseconds: 200),
              curve: Curves.decelerate,
            );
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: ListView.builder(
        reverse: true,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          var message = getMessage(index);
          if (message == null) {
            return Container();
          }
          return Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: getItemContainer(message),
              ));
        },
        itemCount: controller.messages.length,
      ),
    );
    ;
  }

  ChatroomMessage? getMessage(int index) {
    if (index >= controller.messages.length) {
      return null;
    }
    return controller.messages[controller.messages.length - index - 1];
  }

  Widget getItemContainer(ChatroomMessage message) {
    switch (message.messageType) {
      case ChatroomMessageType.kText:
        {
          var m = message as ChatroomTextMessage;
          if (m.isAnchor) {
            return RichText(
              maxLines: 5,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Image.asset(
                        AppConfig().isZh
                            ? AssetName.anchorIconZh
                            : AssetName.anchorIconEn,
                        width: 28,
                        height: 20),
                  ),
                  TextSpan(
                      text: ' ${m.nickname}: ',
                      style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                          fontSize: 14.0)),
                  TextSpan(
                      text: m.text,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14.0)),
                ],
              ),
            );
          } else {
            return RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: ' ${m.nickname}: ',
                    style: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                        fontSize: 14.0)),
                TextSpan(
                    text: m.text,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14.0)),
              ]),
            );
          }
        }
      case ChatroomMessageType.kGift:
        var m = message as ChatroomGiftMessage;
        var gift = 'assets/images/gift0${m.giftId}.png';
        return RichText(
          text: TextSpan(children: [
            TextSpan(
                text: ' ${m.nickname}: ',
                style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.6), fontSize: 14.0)),
            const TextSpan(
                text: 'Give gifts x1 ',
                style: TextStyle(color: Colors.white, fontSize: 14.0)),
            WidgetSpan(
              child: Image.asset(gift, width: 22, height: 22),
            ),
          ]),
        );
      case ChatroomMessageType.kNotify:
        var m = message as ChatroomNotifyMessage;
        return RichText(
            text: TextSpan(children: [
          TextSpan(
              text:
                  ' ${m.nickname}: ${m.notifyType == ChatroomNotifyType.kMemberJoin ? S.of(context).joinRoom : S.of(context).leaveRoom}',
              style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.6), fontSize: 14.0)),
        ]));
    }
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/utils/toast_utils.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';

class StartLiveInfoView extends StatefulWidget {
  final Function(String? cover, String? topic)? onInfoChanged;

  const StartLiveInfoView({
    Key? key,
    required this.onInfoChanged,
  }) : super(key: key);

  @override
  _StartLiveInfoViewState createState() => _StartLiveInfoViewState();
}

class _StartLiveInfoViewState extends State<StartLiveInfoView> {
  final TextEditingController _textEditingController =
      TextEditingController(text: '');
  String _cover = '';
  String _topic = '';

  _default() {
    NEVoiceRoomKit.instance.getCreateRoomDefaultInfo().then((value) {
      print('getCreateRoomDefaultInfo  ====> ${value.toString()} ');
      if (value.code == 0) {
        NEVoiceCreateRoomDefaultInfo? roomDefaultInfo = value.data;
        if (roomDefaultInfo != null) {
          setState(() {
            _topic = roomDefaultInfo.topic!;
            _cover = roomDefaultInfo.livePicture!;
            _textEditingController.text = _topic;
            if (widget.onInfoChanged != null) {
              widget.onInfoChanged!(_cover, _topic);
            }
          });
        }
      } else {
        ToastUtils.showToast(
            context, value.code.toString() + value.msg.toString());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _default();
    _textEditingController.addListener(() {
      if (_topic != _textEditingController.text) {
        _topic = _textEditingController.text;
        if (widget.onInfoChanged != null) {
          widget.onInfoChanged!(_cover, _topic);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(12, 12, 13, 0.6),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Stack(children: [
          Positioned(
              left: 20,
              top: 12,
              right: 20,
              height: 20,
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage(AssetName.chatroomTitleIcon),
                      fit: BoxFit.scaleDown,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      S.of(context).voiceChatRoom,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )),
          Positioned(
              left: 10,
              right: 10,
              top: 48,
              height: 1,
              child: Container(
                height: 1,
                color: Color.fromRGBO(255, 255, 255, 0.2),
              )),
          Positioned(
            left: 20,
            top: 60,
            height: 90,
            right: 50,
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              maxLength: 40,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
              controller: _textEditingController,
            ),
          ),
          Positioned(
            right: 20,
            top: 60,
            width: 20,
            height: 20,
            child: MaterialButton(
              padding: const EdgeInsets.all(0.0),
              child: const Image(
                image: AssetImage(AssetName.randomTopicIcon),
                color: Colors.white,
              ),
              onPressed: () {
                _refreshLiveTopic();
              },
            ),
          ),
        ]));
  }

  void _refreshLiveTopic() {
    _default();
  }
}

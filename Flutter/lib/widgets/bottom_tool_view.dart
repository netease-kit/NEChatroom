// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/constants/ValueKeys.dart';
import 'package:voiceroomkit_ui/widgets/bottom_button.dart';

import '../constants/asset_name.dart';
import '../constants/colors.dart';
import 'input_widget.dart';

class BottomToolView extends StatefulWidget {
  final dynamic tapCallBack;
  final void Function(String message) onSend;
  final bool enableShowButtons;
  final bool isAudioMuted;

  const BottomToolView(
      {Key? key,
      this.tapCallBack,
      required this.onSend,
      required this.enableShowButtons,
      required this.isAudioMuted})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomTooView();
  }
}

class _BottomTooView extends State<BottomToolView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildContentView(),
    );
  }

  //build Content
  Widget buildContentView() {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        //输入框
        Expanded(
          flex: 1,
          child: buildInputView(),
        ),
        Expanded(
          flex: 1,
          child: widget.enableShowButtons
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: RoomBottomButton(
                          widget.isAudioMuted
                              ? AssetName.iconBottomMoreVoiceOff
                              : AssetName.iconBottomMoreVoiceLightOn,
                          key: widget.isAudioMuted
                              ? ValueKeys.unmute
                              : ValueKeys.mute),
                      onTap: () {
                        widget.tapCallBack(1);
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      key: ValueKeys.iconBottomMore,
                      child: const RoomBottomButton(AssetName.iconBottomMore),
                      onTap: () {
                        widget.tapCallBack(2);
                      },
                    ),
                  ],
                )
              : const SizedBox(),
        )
      ],
    );
  }

  Widget buildInputView() {
    return Container(
      height: 36,
      // color: Colors.red,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), color: AppColors.black_60),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 21,
          ),
          Image.asset(AssetName.iconLivingInput),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: GestureDetector(
              child: Text(
                S.of(context).inputChatMessageHint,
                style: TextStyle(fontSize: 14, color: AppColors.white),
              ),
              onTap: () {
                InputDialog.show(context).then((value) {
                  setState(() {
                    if (TextUtils.isNotEmpty(value)) {
                      widget.onSend(value!);
                    }
                    // _inputText = value.toString();
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget showInputView() {
    return const TextField(
      style: TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        fillColor: Colors.red,
        labelStyle: TextStyle(color: AppColors.white, fontSize: 14),
        hintText: 'Enter a search term',
        hintStyle: TextStyle(
          color: AppColors.white_80_ffffff,
          fontSize: 14,
        ),
      ),
    );
  }
}

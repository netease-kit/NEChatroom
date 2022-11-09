// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/constants/colors.dart';
import 'package:voiceroomkit_ui/widgets/bottom_sheet_dialog_common.dart';
import 'package:voiceroomkit_ui/widgets/slider_widget.dart';

class BottomSheetDialogMixer extends StatefulWidget {
  final bool isAnchor;
  const BottomSheetDialogMixer({Key? key, required this.isAnchor})
      : super(key: key);

  @override
  State<BottomSheetDialogMixer> createState() {
    return _BottomSheetDialogMixerState();
  }
}

class _BottomSheetDialogMixerState extends State<BottomSheetDialogMixer> {
  bool _isEarbackEnable = false;
  final int _earbackVolume = 80;
  int _vocalsVolume = 50;
  int _accompanimentVolume = 50;

  @override
  void initState() {
    super.initState();
    _isEarbackEnable = NEVoiceRoomKit.instance.isEarbackEnable();
    _vocalsVolume = NEVoiceRoomKit.instance.getRecordingSignalVolume();
    _accompanimentVolume = NEVoiceRoomKit.instance.getAudioMixingVolume();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildBottomToolViewMore(),
    );
  }

  Widget buildBottomToolViewMore() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final itemSpace = (width - 4 * 60 - 60) / 3;

    return BottomSheetDialogCommon(
        title: Text(
          S.of(context).mixer,
          style: const TextStyle(fontSize: 16, color: AppColors.black_333333),
        ),
        body: Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title:
                    Text(S.of(context).earback, style: TextStyle(fontSize: 14)),
                subtitle: Text(S.of(context).earbackDesc,
                    style: const TextStyle(fontSize: 14)),
                trailing: Switch(
                    value: _isEarbackEnable,
                    onChanged: (value) {
                      if (value) {
                        NEVoiceRoomKit.instance.enableEarback(_earbackVolume);
                      } else {
                        NEVoiceRoomKit.instance.disableEarback();
                      }
                      setState(() {
                        _isEarbackEnable = !_isEarbackEnable;
                      });
                    }),
              ),
              Container(
                color: AppColors.color_e6e7eb,
                height: 1,
              ),
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: SliderWidget(
                    title: S.of(context).vocals,
                    onChange: (value) {
                      NEVoiceRoomKit.instance
                          .adjustRecordingSignalVolume(value);
                      _vocalsVolume = value;
                    },
                    level: _vocalsVolume),
              ),
              if (widget.isAnchor)
                Container(
                  color: AppColors.color_e6e7eb,
                  height: 1,
                ),
              if (widget.isAnchor)
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: SliderWidget(
                      title: S.of(context).accompaniment,
                      onChange: (value) {
                        NEVoiceRoomKit.instance.setAudioMixingVolume(value);
                        _accompanimentVolume = value;
                      },
                      level: _accompanimentVolume),
                ),
              const SizedBox(height: 20)
            ])));
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/utils/nav_utils.dart';
import 'package:voiceroomkit_ui/constants/router_name.dart';
import 'package:voiceroomkit_ui/widgets/bottom_sheet_dialog_mixer.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/utils/dialog_utils.dart';
import 'package:voiceroomkit_ui/utils/toast_utils.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/widgets/bottom_sheet_dialog_more.dart';
import 'package:voiceroomkit_ui/widgets/bottom_sheet_dialog_music.dart';
import 'package:voiceroomkit_ui/widgets/bottom_tool_view.dart';
import 'package:voiceroomkit_ui/widgets/chatroom_list_view.dart';
import 'package:voiceroomkit_ui/viewmodel/background_music_viewmodel.dart';

class VoiceRoomBottomToolView extends StatefulWidget {
  final ChatroomMessagesController controller;
  final bool isAnchor;
  final bool isOnSeat;
  final bool isAudioMuted;
  final AudioMaxing audioMaxing;

  const VoiceRoomBottomToolView(
      {Key? key,
      required this.isAnchor,
      required this.isOnSeat,
      required this.isAudioMuted,
      required this.controller,
      required this.audioMaxing})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VoiceRoomBottomToolView();
  }
}

class _VoiceRoomBottomToolView extends State<VoiceRoomBottomToolView> {
  late List<Model> _moreModel;

  bool _isAudioMuted = true;

  /// 用来刷新弹窗耳返
  final ValueNotifier<bool> _isEarbackEnable = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    _isAudioMuted = widget.isAudioMuted;
    _isEarbackEnable.value = NEVoiceRoomKit.instance.isEarbackEnable();
    _moreModel = _defaultDataList();
    VoiceRoomKitLog.i("BottomToolView",
        "isOnSeat:${widget.isOnSeat},_isAudioMuted:$_isAudioMuted");
    return BottomToolView(
      tapCallBack: tapCallBack,
      onSend: (message) {
        if (TextUtils.isNotEmpty(message)) {
          NEVoiceRoomKit.instance.sendTextMessage(message);
          widget.controller.addMessage(ChatroomTextMessage(
              userUuid: NEVoiceRoomKit.instance.localMember?.account,
              nickname: NEVoiceRoomKit.instance.localMember?.name,
              text: message,
              isAnchor: widget.isAnchor));
        }
      },
      enableShowButtons: widget.isAnchor || widget.isOnSeat,
      isAudioMuted: _isAudioMuted,
    );
  }

  ///bottom view click callback
  void tapCallBack(int index) {
    if (index == 2) {
      ///click more button
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return ValueListenableBuilder<bool>(
              builder: (context, value, child) {
                return BottomSheetDialogMore(
                    tapCallBack: tapToolMoreCallBack, modelDatas: _moreModel);
              },
              valueListenable: _isEarbackEnable,
            );
          });
    } else if (index == 1) {
      _toggleMicState();
    }
  }

  ///bottom More view click callback
  void tapToolMoreCallBack(Model model) {
    print('click  button ' + model.itemSelected.toString());
    switch (MoreItemTypeExtension.fromValue(model)) {
      case MoreItemType.microPhone:
        _toggleMicState();
        break;
      case MoreItemType.earback:
        if (model.itemSelected) {
          NEVoiceRoomKit.instance.enableEarback(80);
        } else {
          NEVoiceRoomKit.instance.disableEarback();
        }
        break;
      case MoreItemType.mixer:
        Navigator.pop(context);
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) {
              return BottomSheetDialogMixer(isAnchor: widget.isAnchor);
            }).then((value) => {
              _isEarbackEnable.value =
                  NEVoiceRoomKit.instance.isEarbackEnable(),
              _moreModel[1].itemSelected = !_isEarbackEnable.value,
            });
        break;
      case MoreItemType.music:
        Navigator.pop(context);
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) {
              return BottomSheetDialogMusic(audioMaxing: widget.audioMaxing);
            });
        break;
      case MoreItemType.finish:
        _showEndLiveDialog();
        break;
      default:
        break;
    }
  }

  void _showEndLiveDialog() {
    DialogUtils.showEndLiveDialog(context, '', () {}, () {
      NEVoiceRoomKit.instance.endRoom().then((value) {
        if (value.isSuccess()) {
          ToastUtils.showToast(context, S.of(context).endRoomSuccess);
        } else {
          ToastUtils.showToast(context, S.of(context).operateFail);
        }
        NavUtils.popUntil(context, RouterName.liveListPage);
      });
    });
  }

  List<Model> _defaultDataList() {
    List<Model> list = [];
    List<MoreItemType> dataList = _getModelDataList();
    for (var index = 0; index < dataList.length; index++) {
      list.add(dataList[index].value);
    }
    list[0].itemSelected = !_isAudioMuted;
    return list;
  }

  List<MoreItemType> _getModelDataList() {
    List<MoreItemType> list = [
      MoreItemType.microPhone,
      MoreItemType.earback,
      MoreItemType.mixer,
    ];
    if (widget.isAnchor) {
      list.add(MoreItemType.music);
      list.add(MoreItemType.finish);
    }
    return list;
  }

  void _toggleMicState() {
    if (_isAudioMuted) {
      NEVoiceRoomKit.instance.unmuteMyAudio().then((value) {
        if (value.isSuccess()) {
          ToastUtils.showToast(context, S.of(context).micOn);
          setState(() {
            _isAudioMuted = !_isAudioMuted;
          });
        } else {
          ToastUtils.showToast(context, S.of(context).operateFail);
        }
      });
    } else {
      NEVoiceRoomKit.instance.muteMyAudio().then((value) {
        if (value.isSuccess()) {
          ToastUtils.showToast(context, S.of(context).micOff);
          setState(() {
            _isAudioMuted = !_isAudioMuted;
          });
        } else {
          ToastUtils.showToast(context, S.of(context).operateFail);
        }
      });
    }
  }
}

enum MoreItemType {
  microPhone,
  earback,
  mixer,
  music,
  finish,
}

extension MoreItemTypeExtension on MoreItemType {
  Model get value {
    switch (this) {
      case MoreItemType.microPhone:
        return Model(S.current.microphone, AssetName.iconBottomMoreVoiceOn, 0,
            AssetName.iconBottomMoreVoiceOff);
      case MoreItemType.earback:
        return Model(S.current.earback, AssetName.iconBottomEarBackOff, 0,
            AssetName.iconBottomEarBackOn);
      case MoreItemType.mixer:
        return Model(S.current.mixer, AssetName.iconBottomMoreMixer, 0,
            AssetName.iconBottomMoreMixer);
      case MoreItemType.music:
        return Model(S.current.music, AssetName.iconBottomMoreMusic, 0,
            AssetName.iconBottomMoreMusic);
      case MoreItemType.finish:
        return Model(S.current.finish, AssetName.iconBottomMoreFinish, 0,
            AssetName.iconBottomMoreFinish);
      default:
        return Model(S.current.microphone, AssetName.iconBottomMoreVoiceOn, 0,
            AssetName.iconBottomMoreVoiceOff);
    }
  }

  static MoreItemType? fromValue(Model model) {
    for (var element in MoreItemType.values) {
      if (element.value.itemTitle == model.itemTitle) {
        return element;
      }
    }
    return null;
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/base/lifecycle_base_state.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat.dart';
import 'package:voiceroomkit_ui/utils/seat_util.dart';
import 'package:voiceroomkit_ui/utils/toast_utils.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/viewmodel/seat_viewmodel.dart';

/// 选择成员
class SelectMemberListWidget extends StatefulWidget {
  final int seatIndex;
  final SeatViewModel seatViewModel;
  const SelectMemberListWidget(this.seatIndex, this.seatViewModel, {Key? key})
      : super(key: key);

  @override
  State<SelectMemberListWidget> createState() {
    return _SelectMemberListWidgetState(seatViewModel);
  }
}

class _SelectMemberListWidgetState
    extends LifecycleBaseState<SelectMemberListWidget> {
  final List<NEVoiceRoomMember> list = [];
  final SeatViewModel seatViewModel;

  _SelectMemberListWidgetState(this.seatViewModel);

  @override
  void initState() {
    super.initState();
    NEVoiceRoomKit.instance.allMemberList?.forEach((element) {
      if (!seatViewModel.isUserOnSeat(element.account) &&
          !SeatUtil.isSelf(element.account)) {
        list.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _pop();
          },
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                const Positioned(
                    left: 20,
                    child: Image(
                        height: 20,
                        width: 20,
                        image: AssetImage(AssetName.backIcon))),
                Text(
                  S.of(context).selectMember,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 15),
          child: Divider(
            height: 0.5,
            endIndent: 10,
            indent: 10,
            color: Colors.grey,
          ),
        ),
        Visibility(
            visible: list.isEmpty,
            child: Column(
              children: [
                Align(
                  child: Container(
                    margin: const EdgeInsets.only(top: 80),
                    child: const Image(
                        width: 80,
                        height: 80,
                        image: AssetImage(AssetName.emptyMemberIcon)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    S.of(context).emptyMember,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xffbfbfbf)),
                  ),
                )
              ],
            )),
        Expanded(
            child: Visibility(
          visible: list.isNotEmpty,
          child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => _itemClick(list[index]),
                  child: SizedBox(
                    key: ValueKey("selectMember$index"),
                    height: 48,
                    child: _getItemContainer(list[index]),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                    height: 1,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.grey,
                  ),
              itemCount: list.length),
        ))
      ],
    );
  }

  Widget _getItemContainer(NEVoiceRoomMember seat) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(seat.avatar ?? ''),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(seat.name,
                    style: const TextStyle(
                      color: Color(0xff222222),
                      fontSize: 14,
                    ))),
          ],
        ),
      ),
    );
  }

  void _itemClick(NEVoiceRoomMember item) {
    NEVoiceRoomKit.instance
        .sendSeatInvitation(widget.seatIndex, item.account)
        .then((value) {
      if (value.isSuccess()) {
        ToastUtils.showToast(
            context,
            S.of(context).kickoutSeatSuccessTip1 +
                S.of(context).space +
                item.name +
                S.of(context).space +
                S.of(context).moveOnSeat);
        _pop();
      } else {
        ToastUtils.showToast(context, S.of(context).operateFail);
        _pop();
      }
    });
  }

  void _pop() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}

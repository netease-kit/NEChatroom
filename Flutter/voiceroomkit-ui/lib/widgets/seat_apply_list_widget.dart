// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/base/lifecycle_base_state.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat.dart';
import 'package:voiceroomkit_ui/utils/toast_utils.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/viewmodel/seat_viewmodel.dart';

/// 麦位申请列表弹窗
class SeatApplyListWidget extends StatefulWidget {
  final SeatViewModel seatViewModel;

  const SeatApplyListWidget({Key? key, required this.seatViewModel})
      : super(key: key);

  @override
  State<SeatApplyListWidget> createState() {
    return _SeatApplyListWidgetState(seatViewModel);
  }
}

class _SeatApplyListWidgetState
    extends LifecycleBaseState<SeatApplyListWidget> {
  final SeatViewModel seatViewModel;

  _SeatApplyListWidgetState(this.seatViewModel);

  @override
  Widget build(BuildContext context) {
    List<VoiceRoomSeat> applySeatList = seatViewModel.applySeatList;
    var height =
        40 + (applySeatList.length > 4 ? 4 : applySeatList.length) * 50 + 60;
    return Visibility(
      visible: widget.seatViewModel.showApplySeatListUI,
      child: Container(
        // margin: EdgeInsets.only(bottom: 300),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - height),
            decoration: const BoxDecoration(
              color: Color(0xd8000000),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  '${S.of(context).applyMicroHasArrow}(${applySeatList.length})',
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Container(
                  constraints:
                      const BoxConstraints(maxHeight: 225), // 最大展示4个半高度
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      primary: false,
                      itemCount: applySeatList.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          child: _buildSeatApplyWidget(applySeatList[index]),
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _dismiss();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).putAway,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const Image(
                          width: 20,
                          height: 20,
                          image: AssetImage(AssetName.seatApplyArrowUpIcon)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatApplyWidget(VoiceRoomSeat seat) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              left: 16,
              child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(seat.member?.avatar ?? ''))),
          Positioned(
              left: 56,
              child: Text(
                "${seat.member?.name}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              )),
          Positioned(
              right: 60,
              child: InkWell(
                onTap: () {
                  _reject(seat);
                },
                child: const Image(
                  width: 16,
                  height: 16,
                  image: AssetImage(AssetName.rejectSeatIcon),
                  fit: BoxFit.cover,
                ),
              )),
          Positioned(
              right: 10,
              child: InkWell(
                onTap: () {
                  _allow(seat);
                },
                child: const Image(
                  width: 16,
                  height: 16,
                  image: AssetImage(AssetName.allowSeatIcon),
                ),
              )),
        ],
      ),
    );
  }

  _dismiss() {
    VoiceRoomKitLog.d(tag, "dismiss apply dialog");
    widget.seatViewModel.setShowApplySeatListUI(false);
  }

  _reject(VoiceRoomSeat seat) {
    VoiceRoomKitLog.d(tag, "reject");
    //拒绝
    NEVoiceRoomKit.instance
        .rejectSeatRequest(seat.member!.account)
        .then((value) {
      if (value.isSuccess()) {
        ToastUtils.showToast(
            context, S.of(context).rejectSeatRequestTips(seat.member!.name));
      } else {
        ToastUtils.showToast(context, S.of(context).operateFail);
      }
    });
  }

  _allow(VoiceRoomSeat seat) {
    VoiceRoomKitLog.d(tag, "allow");
    //同意
    ToastUtils.showToast(
        context,
        S.of(context).hasConfirm +
            S.of(context).space +
            (seat.member?.name != null
                ? seat.member!.name
                : seat.getAccount().toString()) +
            S.of(context).space +
            S.of(context).apply);
    NEVoiceRoomKit.instance.approveSeatRequest(seat.member!.account);
  }
}

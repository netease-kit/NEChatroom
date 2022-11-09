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
import 'package:voiceroomkit_ui/widgets/select_member_list_widget.dart';
import 'package:voiceroomkit_ui/viewmodel/seat_viewmodel.dart';

/// 麦位操作选项
class SeatOptionListWidget extends StatefulWidget {
  final List<String> list;
  final VoiceRoomSeat? seat;
  final SeatViewModel seatViewModel;

  const SeatOptionListWidget(this.list, this.seat, this.seatViewModel,
      {Key? key})
      : super(key: key);

  @override
  State<SeatOptionListWidget> createState() {
    return _SeatOptionListWidgetState(list, seat, seatViewModel);
  }
}

class _SeatOptionListWidgetState
    extends LifecycleBaseState<SeatOptionListWidget> {
  final List<String> list;
  final VoiceRoomSeat? seat;
  final SeatViewModel seatViewModel;

  _SeatOptionListWidgetState(this.list, this.seat, this.seatViewModel);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () => _itemClick(list[index]),
            child: SizedBox(
              height: 48,
              child: _getItemContainer(list[index]),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
              height: 1,
              indent: 10,
              endIndent: 10,
              color: Colors.grey,
            ),
        itemCount: list.length);
  }

  Widget _getItemContainer(String item) {
    return Container(
      alignment: Alignment.center,
      height: 60,
      child: Text(
        item,
        key: ValueKey(item),
        style: const TextStyle(fontSize: 14, color: Color(0xff333333)),
      ),
    );
  }

  void _itemClick(String item) {
    if (SeatUtil.isAnchor()) {
      if (item == S.of(context).kickoutSeatSure) {
        _kickSeat(seat);
      } else if (item == S.of(context).closeSeat) {
        _closeSeat(seat);
      } else if (item == S.of(context).moveMemberOnSeat) {
        _inviteSeat0(seat);
      } else if (item == S.of(context).kickSeat) {
        _kickSeat(seat);
      } else if (item == S.of(context).muteSeat) {
        _muteSeat(seat);
      } else if (item == S.of(context).unmuteSeat) {
        _unmuteSeat(seat);
      } else if (item == S.of(context).openSeat) {
        _openSeat(seat);
      } else if (item == S.of(context).cancel) {
        Navigator.pop(context);
      }
    } else {
      if (S.of(context).leaveSeat == item) {
        NEVoiceRoomKit.instance.leaveSeat().then((value) {
          if (value.isSuccess()) {
            ToastUtils.showToast(context, S.of(context).alreadyLeaveSeat);
          } else {
            ToastUtils.showToast(context, S.of(context).operateFail);
          }
          Navigator.pop(context);
        });
      } else if (S.of(context).confirmToCancel == item) {
        NEVoiceRoomKit.instance.cancelSeatRequest().then((value) {
          if (value.isSuccess()) {
            ToastUtils.showToast(context, S.of(context).applyCanceled);
          } else {
            ToastUtils.showToast(context, S.of(context).operateFail);
          }
          Navigator.pop(context);
        });
      } else if (S.of(context).cancel == item) {
        Navigator.pop(context);
      }
    }
  }

  void _closeSeat(VoiceRoomSeat? seat) {
    if (seat == null) {
      return;
    }
    List<int> list = [];
    list.add(seat.getSeatIndex());
    NEVoiceRoomKit.instance.closeSeats(list).then((value) {
      if (value.isSuccess()) {
        ToastUtils.showToast(context,
            "${S.of(context).seatEn}${seat.index - 1}${S.of(context).closeSeatTip}");
      } else {
        ToastUtils.showToast(context, S.of(context).operateFail);
      }
      Navigator.pop(context);
    });
  }

  void _inviteSeat0(VoiceRoomSeat? seat) {
    if (seat == null) {
      return;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SelectMemberListWidget(seat.index, seatViewModel);
        });
  }

  void _kickSeat(VoiceRoomSeat? seat) {
    if (seat == null || seat.member == null) {
      return;
    }
    NEVoiceRoomKit.instance.kickSeat(seat.member!.account).then((value) {
      if (value.isSuccess()) {
        ToastUtils.showToast(context,
            '${S.of(context).kickoutSeatSuccessTip1}${seat.member?.name}${S.of(context).kickoutSeatSuccessTip2}');
      } else {
        ToastUtils.showToast(context, S.of(context).operateFail);
      }
      Navigator.pop(context);
    });
  }

  void _muteSeat(VoiceRoomSeat? seat) {
    if (seat == null) {
      return;
    }
    String? userId = seat.getAccount();
    if (userId == null) return;
    NEVoiceRoomKit.instance.banRemoteAudio(userId).then((value) {
      if (value.isSuccess()) {
        ToastUtils.showToast(context, S.of(context).seatMuteTips);
      } else {
        ToastUtils.showToast(context, S.of(context).muteSeatFail);
      }
      Navigator.pop(context);
    });
  }

  void _unmuteSeat(VoiceRoomSeat? seat) {
    if (seat == null) {
      return;
    }
    String? userId = seat.getAccount();
    if (userId == null) return;
    NEVoiceRoomKit.instance.unbanRemoteAudio(userId).then((value) {
      if (value.isSuccess()) {
        ToastUtils.showToast(context, S.of(context).unmuteSeatSuccess);
      } else {
        ToastUtils.showToast(context, S.of(context).unmuteSeatFail);
      }
      Navigator.pop(context);
    });
  }

  void _openSeat(VoiceRoomSeat? seat) {
    if (seat == null) {
      return;
    }
    int position = seat.getSeatIndex() - 1;
    List<int> seatIndices = [];
    seatIndices.add(seat.getSeatIndex());
    NEVoiceRoomKit.instance.openSeats(seatIndices).then((value) {
      if (value.isSuccess()) {
        ToastUtils.showToast(context,
            "${S.of(context).seatBigPrefix} $position ${S.of(context).openSeatSuccess}");
      } else {
        ToastUtils.showToast(context,
            "${S.of(context).seatBigPrefix} $position ${S.of(context).openSeatFail}");
      }
      Navigator.pop(context);
    });
  }
}

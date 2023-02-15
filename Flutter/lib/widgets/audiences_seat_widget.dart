// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat.dart';
import 'package:voiceroomkit_ui/utils/seat_util.dart';
import 'package:voiceroomkit_ui/utils/toast_utils.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/widgets/seat_option_list_widget.dart';
import 'package:voiceroomkit_ui/viewmodel/seat_viewmodel.dart';

import '../base/textutil.dart';

/// 观众麦位UI
class AudiencesSeatWidget extends StatefulWidget {
  const AudiencesSeatWidget({Key? key}) : super(key: key);

  @override
  State<AudiencesSeatWidget> createState() => _AudiencesSeatState();
}

class _AudiencesSeatState extends State<AudiencesSeatWidget> {
  final tag = "_AudiencesSeatState";
  late SeatViewModel seatViewModel;
  @override
  Widget build(BuildContext context) {
    seatViewModel = Provider.of<SeatViewModel>(context);
    List<VoiceRoomSeat> seats = seatViewModel.audienceSeats;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: 300,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        //Horizontal spacing between child widgets
        crossAxisSpacing: 1.0,
        //Vertical spacing between child widgets
        mainAxisSpacing: 8.0,
        padding: const EdgeInsets.all(1.0),
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        children: _getAudienceWidgets(seats),
      ),
    );
  }

  List<Widget> _getAudienceWidgets(List<VoiceRoomSeat> seats) {
    return seats.map((item) => _getItemContainer(item)).toList();
  }

  Widget _getItemContainer(VoiceRoomSeat seat) {
    VoiceRoomKitLog.i(tag, "seat:$seat");
    bool _hasMember = seat.member != null;
    bool _isOnSeat = _hasMember && seat.status == Status.ON;
    bool _isSeatClosed = seat.status == Status.CLOSED;
    bool _isApply = _hasMember && seat.status == Status.APPLY;
    bool _isAudioOn = _hasMember && seat.member!.isAudioOn;
    bool _isAudioBanned = _hasMember && seat.member!.isAudioBanned;
    String avatar = '';
    if (!TextUtil.isEmpty(seat.member?.avatar)) {
      avatar = seat.member?.avatar as String;
    }
    VoiceRoomKitLog.i(tag,
        "index:${seat.index},_hasMember:$_hasMember,avatar:$avatar,_isOnSeat:$_isOnSeat,_isSeatClosed:$_isSeatClosed,_isApply:$_isApply,_isAudioOn:$_isAudioOn,_isAudioBanned:$_isAudioBanned");
    return Container(
        key: ValueKey("seatIndex${seat.index}"),
        height: 120,
        // width: 60,
        child: InkWell(
          onTap: () => _itemClick(seat),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    // 默认头像 android:id="@+id/avatar_bg"
                    Visibility(
                      visible: _hasMember,
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage(AssetName.seatDefaultAvatar),
                      ),
                    ),
                    //  头像装饰  android:id="@+id/circle"
                    Visibility(
                      visible: _isOnSeat,
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(AssetName.seatPointEmpty),
                      ),
                    ),
                    //   头像     android:id="@+id/iv_user_avatar"
                    Visibility(
                      visible: _hasMember,
                      child: ClipOval(
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 100),
                          placeholder:
                              const AssetImage(AssetName.seatDefaultAvatar),
                          image: NetworkImage(avatar),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(AssetName.seatDefaultAvatar);
                          },
                        ),
                      ),
                    ),
                    Visibility(
                        visible: !_isOnSeat,
                        child: ClipOval(
                          child: Container(
                            color: const Color(0x7f000000),
                            height: 60,
                            width: 60,
                            child: Visibility(
                              visible: !_isOnSeat,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Visibility(
                                      visible: _isSeatClosed,
                                      child: const Image(
                                        width: 30,
                                        height: 30,
                                        image:
                                            AssetImage(AssetName.seatCloseIcon),
                                      )),
                                  Visibility(
                                      visible: !_isSeatClosed && !_isApply,
                                      child: const Image(
                                        width: 30,
                                        height: 30,
                                        image: AssetImage(
                                            AssetName.seatAddMemberIcon),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        )),
                    //  麦位状态，关闭，锁住 android:id="@+id/iv_user_stats"

                    // 麦位申请中的动画
                    Visibility(
                      visible: _isApply,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Lottie.asset(AssetName.seatApplyLottie,
                            width: 60, height: 60),
                      ),
                    ),
                  ],
                ),
              ),

              //     右下角麦克风图标 android:id="@+id/iv_user_status_hint"
              Positioned(
                child: Padding(
                    padding: const EdgeInsets.only(top: 45, left: 40),
                    child: Visibility(
                      visible: _hasMember && !_isApply,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: Stack(
                          children: [
                            Visibility(
                                visible: _isAudioOn,
                                child: const Image(
                                  image:
                                      AssetImage(AssetName.seatStateOpenIcon),
                                )),
                            Visibility(
                              visible: !_isAudioOn && _isAudioBanned,
                              // visible: true,
                              child: const Image(
                                image: AssetImage(AssetName.seatStateBeMuted),
                              ),
                            ),
                            Visibility(
                              visible: !_isAudioOn && !_isAudioBanned,
                              child: const Image(
                                image: AssetImage(AssetName.seatStateCloseIcon),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
              // 昵称
              Positioned(
                  top: 70,
                  child: Text(
                      seat.member != null
                          ? seat.member!.name
                          : (S.of(context).seatEn + "${seat.index - 1}"),
                      maxLines: 1,
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          decoration: TextDecoration.none))),
            ],
          ),
        ));
  }

  void _itemClick(VoiceRoomSeat seat) {
    if (NEVoiceRoomKit.instance.localMember == null) {
      VoiceRoomKitLog.e(tag, "you are not in room");
      return;
    }
    VoiceRoomKitLog.i(tag, 'click seat:$seat');
    List<String> items = [];
    if (SeatUtil.isAnchor()) {
      if (seat.getStatus() == Status.APPLY) {
        ToastUtils.showToast(context, S.of(context).applyingNow);
        return;
      }
      switch (seat.getStatus()) {
        // 抱观众上麦（点击麦位）
        case Status.INIT:
          items.add(S.of(context).moveMemberOnSeat);
          items.add(S.of(context).closeSeat);
          break;
        // 当前存在有效用户
        case Status.ON:
          items.add(S.of(context).kickSeat);
          NEVoiceRoomMember? member = seat.getMember();
          if (member != null) {
            items.add(member.isAudioBanned
                ? S.of(context).unmuteSeat
                : S.of(context).muteSeat);
          }
          break;
        // 当前麦位已经被关闭
        case Status.CLOSED:
          items.add(S.of(context).openSeat);
          break;
      }
      items.add(S.of(context).cancel);
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SeatOptionListWidget(items, seat, seatViewModel);
          });
    } else {
      switch (seat.getStatus()) {
        case Status.INIT:
          if (seat.getStatus() == Status.CLOSED) {
            ToastUtils.showToast(context, S.of(context).seatAlreadyClosed);
          } else if (seatViewModel.isCurrentUserOnSeat()) {
            ToastUtils.showToast(context, S.of(context).alreadyOnSeat);
          } else {
            _applySeat(seat.getSeatIndex());
          }
          break;
        case Status.APPLY:
          ToastUtils.showToast(context, S.of(context).seatApplied);
          break;
        case Status.ON:
          if (SeatUtil.isSelf(seat.getAccount()!)) {
            _promptLeaveSeat(seat);
          } else {
            ToastUtils.showToast(context, S.of(context).seatAlreadyTaken);
          }
          break;
        case Status.CLOSED:
          ToastUtils.showToast(context, S.of(context).seatAlreadyClosed);
          break;
      }
    }
  }

  void _applySeat(int index) {
    NEVoiceRoomKit.instance.submitSeatRequest(index, true).then((value) {
      seatViewModel.showCancelApplySeatUI(true);
    });
  }

  void _promptLeaveSeat(VoiceRoomSeat seat) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          List<String> list = [];
          list.add(S.of(context).leaveSeat);
          list.add(S.of(context).cancel);
          return SeatOptionListWidget(list, seat, seatViewModel);
        });
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/base/textutil.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/viewmodel/seat_viewmodel.dart';

/// 主播麦位UI
class AnchorSeatWidget extends StatefulWidget {
  const AnchorSeatWidget({Key? key}) : super(key: key);

  @override
  State<AnchorSeatWidget> createState() => _AnchorSeatState();
}

class _AnchorSeatState extends State<AnchorSeatWidget> {
  final tag = "_AnchorSeatState";
  _AnchorSeatState();

  @override
  Widget build(BuildContext context) {
    SeatViewModel seatViewModel = Provider.of<SeatViewModel>(context);
    VoiceRoomSeat seat = seatViewModel.anchorSeat;
    bool _hasMember = seat.member != null;
    bool _isOnSeat = _hasMember && seat.status == Status.ON;
    bool _isSeatClosed = seat.status == Status.CLOSED;
    bool _isApply = _hasMember && seat.status == Status.APPLY;
    bool _isAudioOn = _hasMember && (seat.member!.isAudioOn);
    bool _isAudioBanned = _hasMember && seat.member!.isAudioBanned;
    String avatar = '';
    if (!TextUtil.isEmpty(seat.member?.avatar)) {
      avatar = seat.member?.avatar as String;
    }
    return SizedBox(
        height: 120,
        // width: 60,
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
                      backgroundImage: AssetImage(AssetName.seatDefaultAvatar),
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
                    visible: _isOnSeat,
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
                    // visible: true,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Stack(
                        children: [
                          Visibility(
                              visible: _isAudioOn,
                              child: const Image(
                                image: AssetImage(AssetName.seatStateOpenIcon),
                              )),
                          Visibility(
                            visible: !_isAudioOn && _isAudioBanned,
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
                        : (S.of(context).seatEn + ":${seat.index - 1}"),
                    maxLines: 1,
                    softWrap: true,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        decoration: TextDecoration.none))),
          ],
        ));
  }
}

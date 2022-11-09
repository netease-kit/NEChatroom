// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/utils/dialog_utils.dart';

class SeatUtil {
  static void showKickSeatTips(BuildContext context) {
    DialogUtils.commonShowOneChooseCupertinoDialog(
        context, S.of(context).notify, S.of(context).kickoutSeatByHost, () {});
  }

  static void showApplySeatRejectTips(BuildContext context) {
    DialogUtils.commonShowOneChooseCupertinoDialog(
        context, S.of(context).notify, S.of(context).requestRejected, () {});
  }

  static void showOnSeatByAnchorPickTips(BuildContext context, int index) {
    DialogUtils.commonShowOneChooseCupertinoDialog(
        context,
        S.of(context).notify,
        '${S.of(context).onSeatedTips}${index - 1}${S.of(context).onSeatedTips2}',
        () {});
  }

  static void showSeatMutedByAnchorTips(BuildContext context) {
    DialogUtils.commonShowOneChooseCupertinoDialog(
        context, S.of(context).notify, S.of(context).seatMuted, () {});
  }

  static void showSeatUnMutedByAnchorTips(BuildContext context) {
    DialogUtils.commonShowOneChooseCupertinoDialog(
        context, S.of(context).notify, S.of(context).unmuteSeatTips, () {});
  }

  static bool isAnchor() {
    return NEVoiceRoomKit.instance.localMember != null &&
        NEVoiceRoomKit.instance.localMember!.role ==
            NEVoiceRoomRole.host.name.toLowerCase();
  }

  static bool isSelf(String account) {
    return NEVoiceRoomKit.instance.localMember != null &&
        NEVoiceRoomKit.instance.localMember!.account == account;
  }
}

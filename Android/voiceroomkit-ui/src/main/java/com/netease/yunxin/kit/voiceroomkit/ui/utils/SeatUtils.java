// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.utils;

import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomOnSeatType;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatItem;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatItemStatus;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class SeatUtils {

  public static String getCurrentUuid() {
    return NEVoiceRoomKit.getInstance().getLocalMember().getAccount();
  }

  public static String getMemberNick(String uuid) {
    NEVoiceRoomMember member = VoiceRoomUtils.getMember(uuid);
    if (member != null) {
      return member.getName();
    }
    return "";
  }

  public static List<VoiceRoomSeat> transNESeatItem2VoiceRoomSeat(
      List<NEVoiceRoomSeatItem> neSeatItemList) {
    if (neSeatItemList == null) neSeatItemList = Collections.emptyList();
    List<VoiceRoomSeat> onSeatList = new ArrayList<>();
    for (NEVoiceRoomSeatItem item : neSeatItemList) {
      NEVoiceRoomMember user = getMember(item.getUser());
      int status;
      switch (item.getStatus()) {
        case NEVoiceRoomSeatItemStatus.WAITING:
          status = VoiceRoomSeat.Status.APPLY;
          break;
        case NEVoiceRoomSeatItemStatus.CLOSED:
          status = VoiceRoomSeat.Status.CLOSED;
          break;
        case NEVoiceRoomSeatItemStatus.TAKEN:
          status = VoiceRoomSeat.Status.ON;
          break;
        default:
          status = VoiceRoomSeat.Status.INIT;
          break;
      }
      final int reason;
      if (item.getOnSeatType() == NEVoiceRoomOnSeatType.REQUEST) {
        reason = VoiceRoomSeat.Reason.ANCHOR_APPROVE_APPLY;
      } else if (item.getOnSeatType() == NEVoiceRoomOnSeatType.INVITATION) {
        reason = VoiceRoomSeat.Reason.ANCHOR_INVITE;
      } else {
        reason = VoiceRoomSeat.Reason.NONE;
      }
      onSeatList.add(new VoiceRoomSeat(item.getIndex(), status, reason, user));
    }
    return onSeatList;
  }

  public static NEVoiceRoomMember getMember(String account) {
    List<NEVoiceRoomMember> allMemberList = NEVoiceRoomKit.getInstance().getAllMemberList();
    if (!allMemberList.isEmpty()) {
      for (NEVoiceRoomMember neVoiceRoomMember : allMemberList) {
        if (neVoiceRoomMember.getAccount().equals(account)) {
          return neVoiceRoomMember;
        }
      }
    }
    return null;
  }
}

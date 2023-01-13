// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.utils;

import com.netease.yunxin.app.listentogether.model.VoiceRoomSeat;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomMember;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatItem;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatItemStatus;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEVoiceRoomOnSeatType;
import java.util.ArrayList;
import java.util.List;

public class SeatUtils {

  public static String getCurrentUuid() {
    return NEListenTogetherKit.getInstance().getLocalMember().getAccount();
  }

  public static String getMemberNick(String uuid) {
    NEListenTogetherRoomMember member = ListenTogetherUtils.getMember(uuid);
    if (member != null) {
      return member.getName();
    }
    return "";
  }

  public static List<VoiceRoomSeat> transNESeatItem2VoiceRoomSeat(
      List<NEListenTogetherRoomSeatItem> neSeatItemList) {
    List<VoiceRoomSeat> onSeatList = new ArrayList<>();
    for (NEListenTogetherRoomSeatItem item : neSeatItemList) {
      NEListenTogetherRoomMember user = getMember(item.getUser());
      int status;
      switch (item.getStatus()) {
        case NEListenTogetherRoomSeatItemStatus.WAITING:
          status = VoiceRoomSeat.Status.APPLY;
          break;
        case NEListenTogetherRoomSeatItemStatus.CLOSED:
          status = VoiceRoomSeat.Status.CLOSED;
          break;
        case NEListenTogetherRoomSeatItemStatus.TAKEN:
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

  public static NEListenTogetherRoomMember getMember(String account) {
    List<NEListenTogetherRoomMember> allMemberList =
        NEListenTogetherKit.getInstance().getAllMemberList();
    if (!allMemberList.isEmpty()) {
      for (NEListenTogetherRoomMember neVoiceRoomMember : allMemberList) {
        if (neVoiceRoomMember.getAccount().equals(account)) {
          return neVoiceRoomMember;
        }
      }
    }
    return null;
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.kit.entertainment.common.utils;

import android.text.TextUtils;
import com.netease.yunxin.kit.corekit.service.XKitServiceManager;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomBatchSeatUserReward;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import java.util.ArrayList;
import java.util.List;

public class VoiceRoomUtils {
  private static final String VOICE_ROOM_SERVICE_NAME = "VoiceRoomKit";

  public static boolean isLocalAnchor() {
    return NEVoiceRoomKit.getInstance().getLocalMember() != null
        && TextUtils.equals(
            NEVoiceRoomKit.getInstance().getLocalMember().getRole(), RoomConstants.ROLE_HOST);
  }

  public static boolean isLocal(String uuid) {
    return NEVoiceRoomKit.getInstance().getLocalMember() != null
        && TextUtils.equals(NEVoiceRoomKit.getInstance().getLocalMember().getAccount(), uuid);
  }

  public static boolean isHost(String uuid) {
    NEVoiceRoomMember member = getMember(uuid);
    if (member == null) {
      return false;
    }
    return TextUtils.equals(member.getRole(), RoomConstants.ROLE_HOST);
  }

  public static NEVoiceRoomMember getLocalMember() {
    return NEVoiceRoomKit.getInstance().getLocalMember();
  }

  public static NEVoiceRoomMember getMember(String uuid) {
    List<NEVoiceRoomMember> allMemberList = NEVoiceRoomKit.getInstance().getAllMemberList();
    for (int i = 0; i < allMemberList.size(); i++) {
      NEVoiceRoomMember member = allMemberList.get(i);
      if (TextUtils.equals(member.getAccount(), uuid)) {
        return member;
      }
    }
    return null;
  }

  public static NEVoiceRoomMember getHost() {
    List<NEVoiceRoomMember> allMemberList = NEVoiceRoomKit.getInstance().getAllMemberList();
    for (int i = 0; i < allMemberList.size(); i++) {
      NEVoiceRoomMember member = allMemberList.get(i);
      if (TextUtils.equals(member.getRole(), RoomConstants.ROLE_HOST)) {
        return member;
      }
    }
    return null;
  }

  public static boolean isMute(String uuid) {
    NEVoiceRoomMember member = getMember(uuid);
    if (member != null) {
      return !member.isAudioOn();
    }
    return true;
  }

  public static List<RoomSeat> createSeats() {
    int size = RoomSeat.SEAT_COUNT;
    List<RoomSeat> seats = new ArrayList<>(size);
    for (int i = 0; i < size; i++) {
      seats.add(new RoomSeat(i + 1));
    }
    return seats;
  }

  public static String getLocalAccount() {
    if (NEVoiceRoomKit.getInstance().getLocalMember() == null) {
      return "";
    }
    return NEVoiceRoomKit.getInstance().getLocalMember().getAccount();
  }

  public static String getLocalName() {
    if (NEVoiceRoomKit.getInstance().getLocalMember() == null) {
      return "";
    }
    return NEVoiceRoomKit.getInstance().getLocalMember().getName();
  }

  public static int getRewardFromRoomInfo(String userUuid, NEVoiceRoomInfo roomInfo) {
    if (!TextUtils.isEmpty(userUuid)
        && roomInfo != null
        && roomInfo.getLiveModel().getSeatUserReward() != null) {
      List<NEVoiceRoomBatchSeatUserReward> seatUserRewards =
          roomInfo.getLiveModel().getSeatUserReward();
      for (NEVoiceRoomBatchSeatUserReward seatUserReward : seatUserRewards) {
        if (seatUserReward != null && TextUtils.equals(userUuid, seatUserReward.getUserUuid())) {
          return seatUserReward.getRewardTotal();
        }
      }
    }
    return 0;
  }

  public static int getAnchorReward(NEVoiceRoomInfo roomInfo) {
    if (getHost() == null) {
      return 0;
    }
    return getRewardFromRoomInfo(getHost().getAccount(), roomInfo);
  }

  public static boolean isShowFloatView() {
    Object result =
        XKitServiceManager.Companion.getInstance()
            .callService(VOICE_ROOM_SERVICE_NAME, "isShowFloatView", null);
    return result instanceof Boolean && (boolean) result;
  }

  public static void stopFloatPlay() {
    XKitServiceManager.Companion.getInstance()
        .callService(VOICE_ROOM_SERVICE_NAME, "stopFloatPlay", null);
  }
}

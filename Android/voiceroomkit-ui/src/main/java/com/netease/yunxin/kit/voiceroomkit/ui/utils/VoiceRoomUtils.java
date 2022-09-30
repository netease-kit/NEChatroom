// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.kit.voiceroomkit.ui.utils;

import android.text.TextUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeat;
import java.util.ArrayList;
import java.util.List;

public class VoiceRoomUtils {

  public static boolean isCurrentHost() {
    return NEVoiceRoomKit.getInstance().getLocalMember() != null
        && TextUtils.equals(
            NEVoiceRoomKit.getInstance().getLocalMember().getRole(),
            NEVoiceRoomUIConstants.ROLE_HOST);
  }

  public static boolean isMySelf(String uuid) {
    return NEVoiceRoomKit.getInstance().getLocalMember() != null
        && TextUtils.equals(NEVoiceRoomKit.getInstance().getLocalMember().getAccount(), uuid);
  }

  public static boolean isHost(String uuid) {
    NEVoiceRoomMember member = getMember(uuid);
    if (member == null) {
      return false;
    }
    return TextUtils.equals(member.getRole(), NEVoiceRoomUIConstants.ROLE_HOST);
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
      if (TextUtils.equals(member.getRole(), NEVoiceRoomUIConstants.ROLE_HOST)) {
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

  public static List<VoiceRoomSeat> createSeats() {
    int size = VoiceRoomSeat.SEAT_COUNT;
    List<VoiceRoomSeat> seats = new ArrayList<>(size);
    for (int i = 1; i < size; i++) {
      seats.add(new VoiceRoomSeat(i + 1));
    }
    return seats;
  }

  public static String getCurrentName() {
    if (NEVoiceRoomKit.getInstance().getLocalMember() == null) {
      return "";
    }
    return NEVoiceRoomKit.getInstance().getLocalMember().getName();
  }
}

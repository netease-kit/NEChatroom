// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.kit.voiceroomkit.ui.base.utils;

import com.netease.yunxin.kit.entertainment.common.model.RoomModel;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import java.util.ArrayList;
import java.util.List;

public class VoiceRoomUtils {

  public static List<RoomModel> neVoiceRoomInfos2RoomInfos(List<NEVoiceRoomInfo> voiceRoomInfos) {
    List<RoomModel> result = new ArrayList<>();
    for (NEVoiceRoomInfo roomInfo : voiceRoomInfos) {
      result.add(neVoiceRoomInfo2RoomInfo(roomInfo));
    }
    return result;
  }

  public static RoomModel neVoiceRoomInfo2RoomInfo(NEVoiceRoomInfo voiceRoomInfo) {
    if (voiceRoomInfo == null) {
      return null;
    }
    RoomModel roomModel = new RoomModel();
    roomModel.setRoomUuid(voiceRoomInfo.getLiveModel().getRoomUuid());
    roomModel.setAudienceCount(voiceRoomInfo.getLiveModel().getAudienceCount() + 1);
    roomModel.setCover(voiceRoomInfo.getLiveModel().getCover());
    roomModel.setLiveRecordId(voiceRoomInfo.getLiveModel().getLiveRecordId());
    roomModel.setRoomName(voiceRoomInfo.getLiveModel().getLiveTopic());
    roomModel.setAnchorAvatar(voiceRoomInfo.getAnchor().getAvatar());
    roomModel.setAnchorNick(voiceRoomInfo.getAnchor().getNick());
    roomModel.setAnchorUserUuid(voiceRoomInfo.getAnchor().getAccount());
    roomModel.setGameName(voiceRoomInfo.getLiveModel().getGameName());
    return roomModel;
  }
}

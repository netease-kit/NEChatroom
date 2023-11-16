// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.model;

import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;

public class MemberAudioBannedModel {
  private NEVoiceRoomMember member;
  private boolean banned;

  public MemberAudioBannedModel(NEVoiceRoomMember member, boolean banned) {
    this.member = member;
    this.banned = banned;
  }

  public NEVoiceRoomMember getMember() {
    return member;
  }

  public boolean isBanned() {
    return banned;
  }
}

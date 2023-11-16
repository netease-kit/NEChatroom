// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.model;

import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;

public class MemberAudioMuteChangedModel {
  private NEVoiceRoomMember member;
  private boolean mute;

  public MemberAudioMuteChangedModel(NEVoiceRoomMember member, boolean mute) {
    this.member = member;
    this.mute = mute;
  }

  public NEVoiceRoomMember getMember() {
    return member;
  }

  public boolean isMute() {
    return mute;
  }
}

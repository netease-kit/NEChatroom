// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.util;

import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.roomkit.api.NERoomChatMessage;
import com.netease.yunxin.kit.roomkit.api.NERoomEndReason;
import com.netease.yunxin.kit.roomkit.api.NERoomListener;
import com.netease.yunxin.kit.roomkit.api.NERoomLiveState;
import com.netease.yunxin.kit.roomkit.api.NERoomMember;
import com.netease.yunxin.kit.roomkit.api.NERoomRole;
import com.netease.yunxin.kit.roomkit.api.NEValueCallback;
import com.netease.yunxin.kit.roomkit.api.model.NEAudioOutputDevice;
import com.netease.yunxin.kit.roomkit.api.model.NEMemberVolumeInfo;
import java.util.List;
import java.util.Map;

public abstract class NERoomListenerWrapper implements NERoomListener {
  @Override
  public void onRtcVirtualBackgroundSourceEnabled(boolean enabled, int reason) {}

  @Override
  public void onRoomPropertiesChanged(@NonNull Map<String, String> properties) {}

  @Override
  public void onRoomPropertiesDeleted(@NonNull Map<String, String> properties) {}

  @Override
  public void onMemberRoleChanged(
      @NonNull NERoomMember member, @NonNull NERoomRole oldRole, @NonNull NERoomRole newRole) {}

  @Override
  public void onMemberNameChanged(@NonNull NERoomMember member, @NonNull String name) {}

  @Override
  public void onMemberPropertiesChanged(
      @NonNull NERoomMember member, @NonNull Map<String, String> properties) {}

  @Override
  public void onMemberPropertiesDeleted(
      @NonNull NERoomMember member, @NonNull Map<String, String> properties) {}

  @Override
  public void onMemberJoinRoom(@NonNull List<? extends NERoomMember> members) {}

  @Override
  public void onMemberLeaveRoom(@NonNull List<? extends NERoomMember> members) {}

  @Override
  public void onRoomEnded(@NonNull NERoomEndReason reason) {}

  @Override
  public void onRoomLockStateChanged(boolean isLocked) {}

  @Override
  public void onMemberJoinRtcChannel(@NonNull List<? extends NERoomMember> members) {}

  @Override
  public void onMemberLeaveRtcChannel(@NonNull List<? extends NERoomMember> members) {}

  @Override
  public void onRtcChannelError(int code) {}

  @Override
  public void onAudioEffectFinished(int effectId) {}

  @Override
  public void onAudioMixingStateChanged(int reason) {}

  @Override
  public void onRtcAudioVolumeIndication(
      @NonNull List<NEMemberVolumeInfo> volumes, int totalVolume) {}

  @Override
  public void onRtcAudioOutputDeviceChanged(@NonNull NEAudioOutputDevice device) {}

  @Override
  public void onRtcRecvSEIMsg(@NonNull String uuid, @NonNull String seiMsg) {}

  @Override
  public void onAudioEffectTimestampUpdate(@NonNull long effectId, long timeStampMS) {}

  @Override
  public void onMemberJoinChatroom(@NonNull List<? extends NERoomMember> members) {}

  @Override
  public void onMemberLeaveChatroom(@NonNull List<? extends NERoomMember> members) {}

  @Override
  public void onMemberAudioMuteChanged(
      @NonNull NERoomMember member, boolean mute, @Nullable NERoomMember operateBy) {}

  @Override
  public void onMemberVideoMuteChanged(
      @NonNull NERoomMember member, boolean mute, @Nullable NERoomMember operateBy) {}

  @Override
  public void onMemberScreenShareStateChanged(
      @NonNull NERoomMember member, boolean isSharing, @Nullable NERoomMember operateBy) {}

  @Override
  public void onReceiveChatroomMessages(@NonNull List<? extends NERoomChatMessage> messages) {}

  @Override
  public void onChatroomMessageAttachmentProgress(
      @NonNull String messageUuid, long transferred, long total) {}

  @Override
  public void onMemberWhiteboardStateChanged(
      @NonNull NERoomMember member, boolean isSharing, @Nullable NERoomMember operateBy) {}

  @Override
  public void onWhiteboardError(int code, @NonNull String message) {}

  @Override
  public void onRoomLiveStateChanged(@NonNull NERoomLiveState state) {}

  @Override
  public void onWhiteboardShowFileChooser(
      @NonNull String[] types, @NonNull NEValueCallback<Uri[]> callback) {}
}

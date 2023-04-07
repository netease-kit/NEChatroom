// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.model;

import java.io.Serializable;

public class RoomModel implements Serializable {
  private long liveRecordId;
  private String roomUuid;
  private String role;
  private String nick;
  private String avatar;
  private String roomName;

  private String cover;

  private String liveTopic;

  private String anchorUserUuid;

  private String anchorNick;
  private String anchorAvatar;
  private int onlineCount;

  public int getOnlineUserCount() {
    return onlineUserCount;
  }

  public void setOnlineUserCount(int onlineUserCount) {
    this.onlineUserCount = onlineUserCount;
  }

  private int onlineUserCount;

  public long getLiveRecordId() {
    return liveRecordId;
  }

  public void setLiveRecordId(long liveRecordId) {
    this.liveRecordId = liveRecordId;
  }

  public String getRoomUuid() {
    return roomUuid;
  }

  public void setRoomUuid(String roomUuid) {
    this.roomUuid = roomUuid;
  }

  public String getRole() {
    return role;
  }

  public void setRole(String role) {
    this.role = role;
  }

  public String getNick() {
    return nick;
  }

  public void setNick(String nick) {
    this.nick = nick;
  }

  public String getAvatar() {
    return avatar;
  }

  public void setAvatar(String avatar) {
    this.avatar = avatar;
  }

  public String getRoomName() {
    return roomName;
  }

  public void setRoomName(String roomName) {
    this.roomName = roomName;
  }

  public String getAnchorAvatar() {
    return anchorAvatar;
  }

  public void setAnchorAvatar(String anchorAvatar) {
    this.anchorAvatar = anchorAvatar;
  }

  public String getCover() {
    return cover;
  }

  public void setCover(String cover) {
    this.cover = cover;
  }

  public String getLiveTopic() {
    return liveTopic;
  }

  public void setLiveTopic(String liveTopic) {
    this.liveTopic = liveTopic;
  }

  public int getOnlineCount() {
    return onlineCount;
  }

  public void setOnlineCount(int onlineCount) {
    this.onlineCount = onlineCount;
  }

  public String getAnchorUserUuid() {
    return anchorUserUuid;
  }

  public void setAnchorUserUuid(String anchorUserUuid) {
    this.anchorUserUuid = anchorUserUuid;
  }

  public String getAnchorNick() {
    return anchorNick;
  }

  public void setAnchorNick(String anchorNick) {
    this.anchorNick = anchorNick;
  }
}

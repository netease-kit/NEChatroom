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
  private String anchorUserUuid;
  private String anchorNick;
  private String anchorAvatar;
  private int audienceCount;
  private int onSeatCount;
  private String gameName;

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

  public int getAudienceCount() {
    return audienceCount;
  }

  public void setAudienceCount(int onlineCount) {
    this.audienceCount = onlineCount;
  }

  public int getOnSeatCount() {
    return onSeatCount;
  }

  public void setOnSeatCount(int onSeatCount) {
    this.onSeatCount = onSeatCount;
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

  public void setGameName(String gameName) {
    this.gameName = gameName;
  }

  public String getGameName() {
    return gameName;
  }
}

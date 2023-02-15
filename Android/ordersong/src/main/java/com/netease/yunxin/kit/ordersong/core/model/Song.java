// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.model;

import java.io.Serializable;

public class Song implements Serializable {

  private NEOperator operator;
  private long orderId;
  private String appId;
  private String roomUuid;
  private String userUuid;
  private String userName;
  private String icon;
  private String songId;
  private String songName;
  private String singer;
  private String songCover;
  private int channel;
  private long songTime;
  private long createTime;
  private long updateTime;
  private String attachment;
  private long songStatus;
  private Song nextOrderSong;

  public int getStatus() {
    return status;
  }

  public void setStatus(int status) {
    this.status = status;
  }

  private int status;

  public NEOperator getOperator() {
    return operator;
  }

  public void setOperator(NEOperator operator) {
    this.operator = operator;
  }

  public long getOrderId() {
    return orderId;
  }

  public void setOrderId(long orderId) {
    this.orderId = orderId;
  }

  public String getAppId() {
    return appId;
  }

  public void setAppId(String appId) {
    this.appId = appId;
  }

  public String getRoomUuid() {
    return roomUuid;
  }

  public void setRoomUuid(String roomUuid) {
    this.roomUuid = roomUuid;
  }

  public String getUserUuid() {
    return userUuid;
  }

  public void setUserUuid(String userUuid) {
    this.userUuid = userUuid;
  }

  public String getUserName() {
    return userName;
  }

  public void setUserName(String userName) {
    this.userName = userName;
  }

  public String getIcon() {
    return icon;
  }

  public void setIcon(String icon) {
    this.icon = icon;
  }

  public String getSongId() {
    return songId;
  }

  public void setSongId(String songId) {
    this.songId = songId;
  }

  public String getSongName() {
    return songName;
  }

  public void setSongName(String songName) {
    this.songName = songName;
  }

  public String getSinger() {
    return singer;
  }

  public void setSinger(String singer) {
    this.singer = singer;
  }

  public String getSongCover() {
    return songCover;
  }

  public void setSongCover(String songCover) {
    this.songCover = songCover;
  }

  public int getChannel() {
    return channel;
  }

  public void setChannel(int channel) {
    this.channel = channel;
  }

  public long getSongTime() {
    return songTime;
  }

  public void setSongTime(long songTime) {
    this.songTime = songTime;
  }

  public long getCreateTime() {
    return createTime;
  }

  public void setCreateTime(long createTime) {
    this.createTime = createTime;
  }

  public long getUpdateTime() {
    return updateTime;
  }

  public void setUpdateTime(long updateTime) {
    this.updateTime = updateTime;
  }

  public String getAttachment() {
    return attachment;
  }

  public void setAttachment(String attachment) {
    this.attachment = attachment;
  }

  public long getSongStatus() {
    return songStatus;
  }

  public void setSongStatus(long songStatus) {
    this.songStatus = songStatus;
  }

  public Song getNextOrderSong() {
    return nextOrderSong;
  }

  public void setNextOrderSong(Song nextOrderSong) {
    this.nextOrderSong = nextOrderSong;
  }

  @Override
  public String toString() {
    return "Song{"
        + "operator="
        + operator
        + ", orderId="
        + orderId
        + ", appId='"
        + appId
        + '\''
        + ", roomUuid='"
        + roomUuid
        + '\''
        + ", userUuid='"
        + userUuid
        + '\''
        + ", userName='"
        + userName
        + '\''
        + ", icon='"
        + icon
        + '\''
        + ", songId='"
        + songId
        + '\''
        + ", songName='"
        + songName
        + '\''
        + ", singer='"
        + singer
        + '\''
        + ", songCover='"
        + songCover
        + '\''
        + ", channel="
        + channel
        + ", songTime="
        + songTime
        + ", createTime="
        + createTime
        + ", updateTime="
        + updateTime
        + ", attachment='"
        + attachment
        + '\''
        + ", songStatus="
        + songStatus
        + ", nextOrderSong="
        + nextOrderSong
        + ", status="
        + status
        + '}';
  }
}

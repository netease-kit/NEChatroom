// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.model;

import java.io.Serializable;

public class Song implements Serializable {
  private long liveRecordId;
  private long orderId;
  private String roomArchiveId;
  private String userUuid;
  private String roomUuid;
  private String songId;
  private String songName;
  private String songCover;
  private String singer;
  private long songTime;
  private int channel;
  private NEOperator operator;
  private String attachment;
  private Song nextOrderSong;

  public long getLiveRecordId() {
    return liveRecordId;
  }

  public void setLiveRecordId(long liveRecordId) {
    this.liveRecordId = liveRecordId;
  }

  public long getOrderId() {
    return orderId;
  }

  public void setOrderId(long orderId) {
    this.orderId = orderId;
  }

  public String getRoomArchiveId() {
    return roomArchiveId;
  }

  public void setRoomArchiveId(String roomArchiveId) {
    this.roomArchiveId = roomArchiveId;
  }

  public String getUserUuid() {
    return userUuid;
  }

  public void setUserUuid(String userUuid) {
    this.userUuid = userUuid;
  }

  public String getRoomUuid() {
    return roomUuid;
  }

  public void setRoomUuid(String roomUuid) {
    this.roomUuid = roomUuid;
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

  public String getSongCover() {
    return songCover;
  }

  public void setSongCover(String songCover) {
    this.songCover = songCover;
  }

  public String getSinger() {
    return singer;
  }

  public void setSinger(String singer) {
    this.singer = singer;
  }

  public long getSongTime() {
    return songTime;
  }

  public void setSongTime(long songTime) {
    this.songTime = songTime;
  }

  public int getChannel() {
    return channel;
  }

  public void setChannel(int channel) {
    this.channel = channel;
  }

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

  public String getAttachment() {
    return attachment;
  }

  public void setAttachment(String attachment) {
    this.attachment = attachment;
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
        + "liveRecordId="
        + liveRecordId
        + ", orderId="
        + orderId
        + ", roomArchiveId='"
        + roomArchiveId
        + '\''
        + ", userUuid='"
        + userUuid
        + '\''
        + ", roomUuid='"
        + roomUuid
        + '\''
        + ", songId='"
        + songId
        + '\''
        + ", songName='"
        + songName
        + '\''
        + ", songCover='"
        + songCover
        + '\''
        + ", singer='"
        + singer
        + '\''
        + ", songTime="
        + songTime
        + ", channel="
        + channel
        + ", operator="
        + operator
        + ", attachment='"
        + attachment
        + '\''
        + ", nextOrderSong="
        + nextOrderSong
        + ", status="
        + status
        + '}';
  }
}

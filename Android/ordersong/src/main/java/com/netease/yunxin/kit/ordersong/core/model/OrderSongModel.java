// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.model;

import androidx.annotation.NonNull;
import com.netease.yunxin.kit.copyrightedmedia.api.model.NECopyrightedSinger;
import com.netease.yunxin.kit.copyrightedmedia.api.model.NECopyrightedSong;
import java.util.List;
import java.util.Objects;

/** 待点歌曲 */
public class OrderSongModel {
  public static final int STATE_WAIT = 0;
  public static final int STATE_DOWNLOADING = 1;
  public static final int STATE_DOWNLOADED = 2;

  private String songId;
  private String songName;
  private String songCover;
  private List<NECopyrightedSinger> singers;
  private String albumName;
  private String albumCover;
  private int originType;
  private int channel;
  private int hasAccompany;
  private int hasOrigin;

  private int status;
  private int downloadProgress;
  private String userUuid;
  private Long orderId; //点歌台序号
  private int position; //播放进度
  private Long songTime; //歌曲时长

  public OrderSongModel(NECopyrightedSong song) {
    this.songId = song.getSongId();
    this.songName = song.getSongName();
    this.songCover = song.getSongCover();
    this.singers = song.getSingers();
    this.albumName = song.getAlbumName();
    this.albumCover = song.getAlbumCover();
    this.originType = song.getOriginType();
    this.channel = song.getChannel();
    this.hasAccompany = song.getHasAccompany();
    this.hasOrigin = song.getHasOrigin();
  }

  public OrderSongModel() {}

  @NonNull
  public String getSongId() {
    return songId;
  }

  public void setSongId(@NonNull String songId) {
    this.songId = songId;
  }

  @NonNull
  public String getSongName() {
    return songName;
  }

  public void setSongName(@NonNull String songName) {
    this.songName = songName;
  }

  @NonNull
  public String getSongCover() {
    return songCover;
  }

  public void setSongCover(@NonNull String songCover) {
    this.songCover = songCover;
  }

  @NonNull
  public List<NECopyrightedSinger> getSingers() {
    return singers;
  }

  public void setSingers(@NonNull List<NECopyrightedSinger> NECMSingers) {
    this.singers = NECMSingers;
  }

  @NonNull
  public String getAlbumName() {
    return albumName;
  }

  public void setAlbumName(@NonNull String albumName) {
    this.albumName = albumName;
  }

  @NonNull
  public String getAlbumCover() {
    return albumCover;
  }

  public void setAlbumCover(@NonNull String albumCover) {
    this.albumCover = albumCover;
  }

  public int getOriginType() {
    return originType;
  }

  public void setOriginType(int originType) {
    this.originType = originType;
  }

  public int getChannel() {
    return channel;
  }

  public void setChannel(int channel) {
    this.channel = channel;
  }

  public int getHasAccompany() {
    return hasAccompany;
  }

  public void setHasAccompany(int hasAccompany) {
    this.hasAccompany = hasAccompany;
  }

  public int getHasOrigin() {
    return hasOrigin;
  }

  public void setHasOrigin(int hasOrigin) {
    this.hasOrigin = hasOrigin;
  }

  public int getStatus() {
    return status;
  }

  public void setStatus(int status) {
    this.status = status;
  }

  public String getUserUuid() {
    return userUuid;
  }

  public void setUserUuid(String userUuid) {
    this.userUuid = userUuid;
  }

  public Long getOrderId() {
    return orderId;
  }

  public void setOrderId(Long orderId) {
    this.orderId = orderId;
  }

  public int getPosition() {
    return position;
  }

  public void setPosition(int position) {
    this.position = position;
  }

  public int getDownloadProgress() {
    return downloadProgress;
  }

  public void setDownloadProgress(int downloadProgress) {
    this.downloadProgress = downloadProgress;
  }

  public Long getSongTime() {
    return songTime;
  }

  public void setSongTime(Long songTime) {
    this.songTime = songTime;
  }

  @Override
  public String toString() {
    return "OrderSongModel{"
        + "songId='"
        + songId
        + '\''
        + ", songName='"
        + songName
        + '\''
        + ", songCover='"
        + songCover
        + '\''
        + ", singers="
        + singers
        + ", albumName='"
        + albumName
        + '\''
        + ", albumCover='"
        + albumCover
        + '\''
        + ", originType="
        + originType
        + ", channel="
        + channel
        + ", hasAccompany="
        + hasAccompany
        + ", hasOrigin="
        + hasOrigin
        + ", status="
        + status
        + ", downloadProgress="
        + downloadProgress
        + ", userUuid='"
        + userUuid
        + '\''
        + ", orderId="
        + orderId
        + ", position="
        + position
        + ", songTime="
        + songTime
        + '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    OrderSongModel that = (OrderSongModel) o;
    return songId.equals(that.songId) && Objects.equals(orderId, that.orderId);
  }

  @Override
  public int hashCode() {
    return Objects.hash(songId, orderId);
  }
}

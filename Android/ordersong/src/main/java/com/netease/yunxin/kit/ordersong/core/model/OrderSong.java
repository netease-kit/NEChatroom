// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.model;

import java.io.Serializable;

public class OrderSong implements Serializable {
  public NEOperator operator;
  public long orderId;
  public String appId;
  public String roomUuid;
  public String userUuid;
  public String songId;
  public String songName;
  public String songCover;
  public String singer;
  public long songTime;
  public int channel; //版权渠道 1 云音乐 2 咪咕
  public int musicStatus; //点歌状态状态 -2 已唱  -1 删除 0:等待唱 1 唱歌中或则播放中  2、暂停中 3、ready中
  public int setTop; //是否置顶（1 置顶 0 否）
  public long createTime;
  public long updateTime;

  @Override
  public String toString() {
    return "OrderSong{"
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
        + ", songStatus="
        + musicStatus
        + ", setTop="
        + setTop
        + ", createTime='"
        + createTime
        + '\''
        + ", updateTime='"
        + updateTime
        + '\''
        + '}';
  }
}

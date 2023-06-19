// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.model;

import java.io.Serializable;

public class SongPlayEvent implements Serializable {

  private int type;
  private DataBean data;

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public DataBean getData() {
    return data;
  }

  public void setData(DataBean data) {
    this.data = data;
  }

  public static class DataBean implements Serializable {
    private Song playMusicInfo;
    private NEOperator operatorInfo;

    public Song getPlayMusicInfo() {
      return playMusicInfo;
    }

    public void setPlayMusicInfo(Song playMusicInfo) {
      this.playMusicInfo = playMusicInfo;
    }

    public NEOperator getOperatorInfo() {
      return operatorInfo;
    }

    public void setOperatorInfo(NEOperator operatorInfo) {
      this.operatorInfo = operatorInfo;
    }
  }

  public static class PlayMusicInfo implements Serializable {
    private Song song;
  }

  @Override
  public String toString() {
    return "ListenTogetherEvent{" + "type=" + type + ", data=" + data + '}';
  }
}

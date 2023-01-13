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
    private String appKey;
    private String roomUuid;
    private String type;
    private int cmd;
    private int version;
    private DataBeanDetail data;
    private String requestId;

    public String getAppKey() {
      return appKey;
    }

    public void setAppKey(String appKey) {
      this.appKey = appKey;
    }

    public String getRoomUuid() {
      return roomUuid;
    }

    public void setRoomUuid(String roomUuid) {
      this.roomUuid = roomUuid;
    }

    public String getType() {
      return type;
    }

    public void setType(String type) {
      this.type = type;
    }

    public int getCmd() {
      return cmd;
    }

    public void setCmd(int cmd) {
      this.cmd = cmd;
    }

    public int getVersion() {
      return version;
    }

    public void setVersion(int version) {
      this.version = version;
    }

    public DataBeanDetail getData() {
      return data;
    }

    public void setData(DataBeanDetail data) {
      this.data = data;
    }

    public String getRequestId() {
      return requestId;
    }

    public void setRequestId(String requestId) {
      this.requestId = requestId;
    }

    @Override
    public String toString() {
      return "DataBean{"
          + "appKey='"
          + appKey
          + '\''
          + ", roomUuid='"
          + roomUuid
          + '\''
          + ", type='"
          + type
          + '\''
          + ", cmd="
          + cmd
          + ", version="
          + version
          + ", data="
          + data
          + ", requestId='"
          + requestId
          + '\''
          + '}';
    }

    public static class DataBeanDetail implements Serializable {
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

      @Override
      public String toString() {
        return "DataBeanDetail{"
            + "playMusicInfo="
            + playMusicInfo
            + ", operatorInfo="
            + operatorInfo
            + '}';
      }
    }
  }

  @Override
  public String toString() {
    return "ListenTogetherEvent{" + "type=" + type + ", data=" + data + '}';
  }
}

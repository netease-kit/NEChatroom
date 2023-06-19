// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.model;

import java.io.Serializable;

public class OrderSongEvent implements Serializable {

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
    private OrderSongResultDto orderSongResultDto;
    private NEOperator operatorUser;
    private NextOrderSong nextOrderSong;
    private String attachment;

    public NextOrderSong getNextOrderSong() {
      return nextOrderSong;
    }

    public void setNextOrderSong(NextOrderSong nextOrderSong) {
      this.nextOrderSong = nextOrderSong;
    }

    public NEOperator getOperatorUser() {
      return operatorUser;
    }

    public void setOperatorUser(NEOperator operatorUser) {
      this.operatorUser = operatorUser;
    }

    public OrderSongResultDto getOrderSongResultDto() {
      return orderSongResultDto;
    }

    public void setOrderSongResultDto(OrderSongResultDto orderSongResultDto) {
      this.orderSongResultDto = orderSongResultDto;
    }

    public String getAttachment() {
      return attachment;
    }

    public void setAttachment(String attachment) {
      this.attachment = attachment;
    }

    @Override
    public String toString() {
      return "DataBean{"
          + "orderSongResultDto="
          + orderSongResultDto
          + ", operatorUser="
          + operatorUser
          + ", nextOrderSong="
          + nextOrderSong
          + '}';
    }
  }

  public static class OrderSongResultDto implements Serializable {
    private Song orderSong;
    private NEOperator orderSongUser;

    public Song getOrderSong() {
      return orderSong;
    }

    public void setOrderSong(Song orderSong) {
      this.orderSong = orderSong;
    }

    public NEOperator getOrderSongUser() {
      return orderSongUser;
    }

    public void setOrderSongUser(NEOperator orderSongUser) {
      this.orderSongUser = orderSongUser;
    }

    @Override
    public String toString() {
      return "OrderSongResultDto{"
          + "orderSong="
          + orderSong
          + ", orderSongUser="
          + orderSongUser
          + '}';
    }
  }

  public static class NextOrderSong implements Serializable {
    private Song orderSong;
    private NEOperator orderSongUser;

    public Song getOrderSong() {
      return orderSong;
    }

    public void setOrderSong(Song orderSong) {
      this.orderSong = orderSong;
    }

    public NEOperator getOrderSongUser() {
      return orderSongUser;
    }

    public void setOrderSongUser(NEOperator orderSongUser) {
      this.orderSongUser = orderSongUser;
    }

    @Override
    public String toString() {
      return "NextOrderSong{" + "orderSong=" + orderSong + ", orderSongUser=" + orderSongUser + '}';
    }
  }

  @Override
  public String toString() {
    return "OrderSongEvent{" + "type=" + type + ", data=" + data + '}';
  }
}

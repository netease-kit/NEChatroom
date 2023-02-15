// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.helper;

import com.netease.yunxin.app.listentogether.model.VoiceRoomSeat;
import java.util.List;

public class SeatHelper {

  public static final int SEAT_COUNT = 9;

  private static volatile SeatHelper mInstance;

  private SeatHelper() {}

  private List<VoiceRoomSeat> onSeatItems;
  private List<VoiceRoomSeat> applySeatList;

  public static SeatHelper getInstance() {
    if (null == mInstance) {
      synchronized (SeatHelper.class) {
        if (mInstance == null) {
          mInstance = new SeatHelper();
        }
      }
    }
    return mInstance;
  }

  public List<VoiceRoomSeat> getOnSeatItems() {
    return onSeatItems;
  }

  public void setOnSeatItems(List<VoiceRoomSeat> onSeatItems) {
    this.onSeatItems = onSeatItems;
  }

  public List<VoiceRoomSeat> getApplySeatList() {
    return applySeatList;
  }

  public void setApplySeatList(List<VoiceRoomSeat> applySeatList) {
    this.applySeatList = applySeatList;
  }
}

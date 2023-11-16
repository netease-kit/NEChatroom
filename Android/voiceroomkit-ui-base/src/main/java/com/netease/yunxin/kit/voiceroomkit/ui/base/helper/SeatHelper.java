// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.helper;

import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import java.util.List;

public class SeatHelper {

  public static final int SEAT_COUNT = 9;

  private static volatile SeatHelper mInstance;

  private SeatHelper() {}

  private List<RoomSeat> onSeatItems;
  private List<RoomSeat> applySeatList;

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

  public List<RoomSeat> getOnSeatItems() {
    return onSeatItems;
  }

  public void setOnSeatItems(List<RoomSeat> onSeatItems) {
    this.onSeatItems = onSeatItems;
  }

  public List<RoomSeat> getApplySeatList() {
    return applySeatList;
  }

  public void setApplySeatList(List<RoomSeat> applySeatList) {
    this.applySeatList = applySeatList;
  }
}

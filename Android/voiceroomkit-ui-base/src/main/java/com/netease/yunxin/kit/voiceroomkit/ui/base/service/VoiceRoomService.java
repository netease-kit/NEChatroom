// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.service;

import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.model.OrderSong;

public class VoiceRoomService {
  public static final String TAG = "VoiceRoomService";

  private static volatile VoiceRoomService mInstance;

  private VoiceRoomService() {}

  public static VoiceRoomService getInstance() {
    if (null == mInstance) {
      synchronized (VoiceRoomService.class) {
        if (mInstance == null) {
          mInstance = new VoiceRoomService();
        }
      }
    }
    return mInstance;
  }

  public void reportReady(long orderId, NetRequestCallback<Boolean> callback) {
    NEOrderSongService.INSTANCE.reportReady(orderId, callback);
  }

  public void queryPlayingSongInfo(NetRequestCallback<OrderSong> callback) {
    NEOrderSongService.INSTANCE.queryPlayingSongInfo(callback);
  }
}

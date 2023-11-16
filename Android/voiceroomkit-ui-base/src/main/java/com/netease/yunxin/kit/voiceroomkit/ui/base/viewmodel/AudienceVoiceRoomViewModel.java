// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel;

import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.core.util.GsonUtils;

public class AudienceVoiceRoomViewModel extends VoiceRoomViewModel {

  @Override
  protected void handleSongOrdered(Song song) {}

  @Override
  protected void handleSongSwitchedEvent(Song song) {
    String attachment = song.getAttachment();
    Song nextSong = null;
    try {
      nextSong = GsonUtils.fromJson(attachment, Song.class);
    } catch (Exception e) {
      e.printStackTrace();
    }
    if (nextSong == null) {
      nextSong = song.getNextOrderSong();
    }
    if (nextSong != null) {
      currentSongChange.postValue(nextSong);
    }
  }

  @Override
  protected void handleSongDeleted(Song song) {
    songDeletedEvent.postValue(song);
  }
}

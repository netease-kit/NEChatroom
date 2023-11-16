// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel;

import android.text.TextUtils;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.copyrightedmedia.api.NECopyrightedMedia;
import com.netease.yunxin.kit.copyrightedmedia.api.NESongPreloadCallback;
import com.netease.yunxin.kit.ordersong.core.constant.OrderSongConstant;
import com.netease.yunxin.kit.ordersong.core.model.OrderSong;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.core.util.GsonUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.base.service.VoiceRoomService;

public class AnchorVoiceRoomViewModel extends VoiceRoomViewModel {

  @Override
  protected void handleSongOrdered(Song song) {
    VoiceRoomService.getInstance()
        .queryPlayingSongInfo(
            new NetRequestCallback<OrderSong>() {
              @Override
              public void success(@Nullable OrderSong info) {
                ALog.i(TAG, "onSongOrdered queryCurrentPlayingSong success info:" + info);
                if (info == null) {
                  // 当前无播放歌曲
                  if (NECopyrightedMedia.getInstance()
                      .isSongPreloaded(song.getSongId(), song.getChannel())) {
                    reportReady(song);
                  } else {
                    NECopyrightedMedia.getInstance()
                        .preloadSong(
                            song.getSongId(),
                            song.getChannel(),
                            new NESongPreloadCallback() {
                              @Override
                              public void onPreloadStart(String songId, int channel) {}

                              @Override
                              public void onPreloadProgress(
                                  String songId, int channel, float progress) {}

                              @Override
                              public void onPreloadComplete(
                                  String songId, int channel, int errorCode, String msg) {
                                reportReady(song);
                              }
                            });
                  }
                  return;
                }
                if (NECopyrightedMedia.getInstance().isSongPreloaded(info.songId, info.channel)) {
                  ALog.i(TAG, "onSongOrdered isSongPreloaded");
                } else {
                  NECopyrightedMedia.getInstance()
                      .preloadSong(
                          info.songId,
                          info.channel,
                          new NESongPreloadCallback() {
                            @Override
                            public void onPreloadStart(String songId, int channel) {}

                            @Override
                            public void onPreloadProgress(
                                String songId, int channel, float progress) {}

                            @Override
                            public void onPreloadComplete(
                                String songId, int channel, int errorCode, String msg) {
                              ALog.i(TAG, "onSongOrdered onPreloadComplete");
                            }
                          });
                }
              }

              @Override
              public void error(int code, @Nullable String msg) {
                ALog.e(
                    TAG,
                    "onSongOrdered queryCurrentPlayingSong error code: " + code + ", msg: " + msg);
              }
            });
  }

  @Override
  protected void handleSongDeleted(Song song) {
    songDeletedEvent.postValue(song);

    if (getCurrentPlayingSong() != null
        && getCurrentPlayingSong().getOrderId() == song.getOrderId()
        && song.getNextOrderSong() != null) {
      downloadSongThenReport(song.getNextOrderSong());
    }
  }

  private Song getCurrentPlayingSong() {
    return currentSong;
  }

  @Override
  protected void handleSongSwitchedEvent(Song song) {
    Song nextSong = null;
    String attachment = song.getAttachment();
    if (!TextUtils.isEmpty(attachment)
        && !attachment.equals(OrderSongConstant.PLAY_COMPLETE_FLAG)) {
      try {
        nextSong = GsonUtils.fromJson(attachment, Song.class);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    if (nextSong == null) {
      nextSong = song.getNextOrderSong();
    }
    if (nextSong != null) {
      ALog.i(
          TAG, "handleSongSwitchedEvent currentSong:\r\n" + song + "\r\nnextSong:\r\n" + nextSong);
      downloadSongThenReport(nextSong);
    }
  }

  private void downloadSongThenReport(Song song) {
    if (NECopyrightedMedia.getInstance().isSongPreloaded(song.getSongId(), song.getChannel())) {
      reportReady(song);
    } else {
      NECopyrightedMedia.getInstance()
          .preloadSong(
              song.getSongId(),
              song.getChannel(),
              new NESongPreloadCallback() {
                @Override
                public void onPreloadStart(String songId, int channel) {}

                @Override
                public void onPreloadProgress(String songId, int channel, float progress) {}

                @Override
                public void onPreloadComplete(
                    String songId, int channel, int errorCode, String msg) {
                  reportReady(song);
                }
              });
    }
  }

  private void reportReady(Song song) {
    VoiceRoomService.getInstance()
        .reportReady(
            song.getOrderId(),
            new NetRequestCallback<Boolean>() {
              @Override
              public void success(@Nullable Boolean info) {
                ALog.i(TAG, "reportReady:" + info);
              }

              @Override
              public void error(int code, @Nullable String msg) {
                ALog.e(TAG, "reportReady error code:" + code + ",msg:" + msg);
              }
            });
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.ui.viewmodel;

import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.copyrightedmedia.api.NECopyrightedMedia;
import com.netease.yunxin.kit.copyrightedmedia.api.NEErrorCode;
import com.netease.yunxin.kit.copyrightedmedia.api.NESongPreloadCallback;
import com.netease.yunxin.kit.copyrightedmedia.api.model.NECopyrightedSong;
import com.netease.yunxin.kit.copyrightedmedia.impl.NECopyrightedEventHandler;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongListener;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSong;
import com.netease.yunxin.kit.ordersong.core.model.OrderSongModel;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.ui.util.SingleLiveEvent;
import java.util.ArrayList;
import java.util.List;

public class OrderSongViewModel extends ViewModel {
  private final NECopyrightedMedia copyrightedMedia = NECopyrightedMedia.getInstance();
  private final NEOrderSongService orderSongService = NEOrderSongService.INSTANCE;
  private final MutableLiveData<List<NEOrderSong>> orderSongListChangeEvent =
      new MutableLiveData<>();
  private final SingleLiveEvent<OrderSongModel> performOrderSongEvent = new SingleLiveEvent<>();
  private final MutableLiveData<OrderSongModel> performDownloadSongEvent = new MutableLiveData<>();
  private final SingleLiveEvent<OrderSongModel> startOrderSongEvent = new SingleLiveEvent<>();
  private final MutableLiveData<Boolean> refreshOrderedListEvent = new MutableLiveData<>();

  private final MutableLiveData<Integer> volumeChangedEvent = new MutableLiveData<>();
  private final MutableLiveData<Boolean> pauseOrResumeEvent = new MutableLiveData<>();

  public MutableLiveData<Boolean> getOrderedSongOptionRefreshEvent() {
    return orderedSongOptionRefreshEvent;
  }

  private final MutableLiveData<Boolean> orderedSongOptionRefreshEvent = new MutableLiveData<>();

  private final MutableLiveData<NEOrderSong> switchSongEvent = new MutableLiveData<>();
  private final NECopyrightedEventHandler handler =
      () -> orderSongService.getSongDynamicTokenUntilSuccess(null);

  {
    copyrightedMedia.setEventHandler(handler);
    ALog.i("setEventHandler");
  }

  private final NEOrderSongListener orderSongListener =
      new NEOrderSongListener() {

        @Override
        public void onSongOrdered(Song song) {}

        @Override
        public void onSongDeleted(Song song) {}

        @Override
        public void onOrderedSongListChanged() {}

        @Override
        public void onSongSwitched(Song song) {}

        @Override
        public void onSongStarted(Song song) {
          orderedSongOptionRefreshEvent.postValue(false);
        }

        @Override
        public void onSongPaused(Song song) {
          orderedSongOptionRefreshEvent.postValue(true);
        }

        @Override
        public void onSongResumed(Song song) {
          orderedSongOptionRefreshEvent.postValue(false);
        }
      };

  public OrderSongViewModel() {
    NEOrderSongService.INSTANCE.addListener(orderSongListener);
  }

  public void refreshSongList(
      int pageNum, int pageSize, NECopyrightedMedia.Callback<List<OrderSongModel>> callback) {
    copyrightedMedia.getSongList(
        null,
        null,
        pageNum,
        pageSize,
        new NECopyrightedMedia.Callback<List<NECopyrightedSong>>() {

          @Override
          public void error(int code, @Nullable String msg) {
            ALog.e("getSongList fail code = " + code + ", msg = " + msg);
            callback.error(code, msg);
          }

          @Override
          public void success(@Nullable List<NECopyrightedSong> info) {
            ALog.i("getSongList success:$info");
            List<OrderSongModel> songList = new ArrayList<>();
            if (info != null) {
              for (NECopyrightedSong copyrightedSong : info) {
                if (copyrightedSong.getHasAccompany() != 0) {
                  songList.add(new OrderSongModel(copyrightedSong));
                }
              }
            }
            callback.success(songList);
          }
        });
  }

  public void searchSong(
      String keyword,
      int pageNum,
      int pageSize,
      NECopyrightedMedia.Callback<List<OrderSongModel>> callback) {
    copyrightedMedia.searchSong(
        keyword,
        null,
        pageNum,
        pageSize,
        new NECopyrightedMedia.Callback<List<NECopyrightedSong>>() {

          @Override
          public void error(int code, @Nullable String msg) {
            ALog.e("searchSong fail code = " + code + ", msg = " + msg);
            callback.error(code, msg);
          }

          @Override
          public void success(@Nullable List<NECopyrightedSong> info) {
            ALog.i("searchSong success:$info");
            List<OrderSongModel> songList = new ArrayList<>();
            if (info != null) {
              for (NECopyrightedSong copyrightedSong : info) {
                if (copyrightedSong.getHasAccompany() != 0) {
                  songList.add(new OrderSongModel(copyrightedSong));
                }
              }
            }
            callback.success(songList);
          }
        });
  }

  public void preloadSong(String songId, int channel, NESongPreloadCallback callback) {
    if (NECopyrightedMedia.getInstance().isSongPreloaded(songId, channel)) {
      callback.onPreloadComplete(songId, channel, NEErrorCode.OK, "");
    } else {
      NECopyrightedMedia.getInstance()
          .preloadSong(
              songId,
              channel,
              new NESongPreloadCallback() {

                @Override
                public void onPreloadStart(String songId, int channel) {
                  ALog.i("onPreloadStart songId = " + songId);
                  callback.onPreloadStart(songId, channel);
                }

                @Override
                public void onPreloadProgress(String songId, int channel, float progress) {
                  ALog.i("onPreloadProgress songId = " + songId + ", progress = " + progress);
                  callback.onPreloadProgress(songId, channel, progress);
                }

                @Override
                public void onPreloadComplete(
                    String songId, int channel, int errorCode, String msg) {
                  ALog.i(
                      "onPreloadComplete songId = "
                          + songId
                          + ", errorCode = "
                          + errorCode
                          + ", msg = "
                          + msg);
                  callback.onPreloadComplete(songId, channel, errorCode, msg);
                }
              });
    }
  }

  public void orderSong(
      OrderSongModel copyrightSong, NECopyrightedMedia.Callback<Boolean> callback) {
    orderSongService.orderSong(
        copyrightSong,
        new NetRequestCallback<NEOrderSong>() {
          @Override
          public void success(@Nullable NEOrderSong info) {
            callback.success(true);
            copyrightSong.setOrderId(info.getOrderSong().getOrderId());
          }

          @Override
          public void error(int code, @Nullable String msg) {
            callback.error(code, msg);
          }
        });
  }

  public void deleteSong(long orderId, NECopyrightedMedia.Callback<Boolean> callback) {
    orderSongService.deleteSong(
        orderId,
        new NetRequestCallback<Boolean>() {
          @Override
          public void success(@Nullable Boolean info) {
            callback.success(info);
          }

          @Override
          public void error(int code, @Nullable String msg) {
            callback.error(code, msg);
          }
        });
  }

  public MutableLiveData<List<NEOrderSong>> getOrderSongListChangeEvent() {
    return orderSongListChangeEvent;
  }

  public SingleLiveEvent<OrderSongModel> getPerformOrderSongEvent() {
    return performOrderSongEvent;
  }

  public MutableLiveData<OrderSongModel> getPerformDownloadSongEvent() {
    return performDownloadSongEvent;
  }

  public SingleLiveEvent<OrderSongModel> getStartOrderSongEvent() {
    return startOrderSongEvent;
  }

  public MutableLiveData<Boolean> getRefreshOrderedListEvent() {
    return refreshOrderedListEvent;
  }

  public MutableLiveData<Integer> getVolumeChangedEvent() {
    return volumeChangedEvent;
  }

  public MutableLiveData<Boolean> getPauseOrResumeEvent() {
    return pauseOrResumeEvent;
  }

  public MutableLiveData<NEOrderSong> getSwitchSongEvent() {
    return switchSongEvent;
  }

  public void refreshOrderSongs() {
    orderSongService.getOrderedSongs(
        new NetRequestCallback<List<NEOrderSong>>() {

          @Override
          public void error(int code, @Nullable String msg) {
            ALog.e("getOrderSongs fail code = " + code + ", msg = " + msg);
          }

          @Override
          public void success(@Nullable List<NEOrderSong> info) {
            ALog.i("getOrderSongs success");
            if (info != null) {
              orderSongListChangeEvent.postValue(info);
            }
          }
        });
  }

  public void refreshOrderedSongs() {
    refreshOrderedListEvent.postValue(true);
  }

  @Override
  protected void onCleared() {
    NEOrderSongService.INSTANCE.removeListener(orderSongListener);
    super.onCleared();
  }
}

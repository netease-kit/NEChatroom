// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.viewmodel;

import static com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant.SONG_PAUSE;
import static com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant.SONG_RESUME;
import static com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant.SONG_START;

import android.text.TextUtils;
import android.util.Pair;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import com.netease.yunxin.app.listentogether.chatroom.ChatRoomMsgCreator;
import com.netease.yunxin.app.listentogether.core.ListenTogetherService;
import com.netease.yunxin.app.listentogether.core.NEListenTogetherListener;
import com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant;
import com.netease.yunxin.app.listentogether.model.ListenTogetherRoomModel;
import com.netease.yunxin.app.listentogether.utils.Utils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.copyrightedmedia.api.NECopyrightedMedia;
import com.netease.yunxin.kit.copyrightedmedia.api.NESongPreloadCallback;
import com.netease.yunxin.kit.copyrightedmedia.api.SongResType;
import com.netease.yunxin.kit.listentogether.R;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongListener;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.constant.OrderSongConstant;
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSong;
import com.netease.yunxin.kit.ordersong.core.model.OrderSong;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.core.util.GsonUtils;
import java.util.List;

/** 一起听业务逻辑 */
public class ListenTogetherViewModel extends ViewModel {
  private static final String TAG = "ListenTogetherViewModel";
  private final NECopyrightedMedia copyrightedMedia = NECopyrightedMedia.getInstance();
  private final MutableLiveData<Pair<Boolean, Song>> showMySongDownLoadingData =
      new MutableLiveData<>();
  private final MutableLiveData<Pair<Boolean, Song>> showOtherSongDownLoadingData =
      new MutableLiveData<>();
  private final MutableLiveData<Boolean> showSongPanelData = new MutableLiveData<>();
  private final MutableLiveData<OrderSong> playCurrentSongData = new MutableLiveData<>();
  private final MutableLiveData<CharSequence> chatRoomMsgData = new MutableLiveData<>();
  private final MutableLiveData<Integer> playStateChangedData = new MutableLiveData<>();
  private final MutableLiveData<Song> deleteSongData = new MutableLiveData<>();
  private ListenTogetherRoomModel roomModel;
  private final ListenTogetherService listenTogetherService = ListenTogetherService.getInstance();

  public MutableLiveData<OrderSong> getPlayCurrentSongData() {
    return playCurrentSongData;
  }

  public MutableLiveData<CharSequence> getChatRoomMsgData() {
    return chatRoomMsgData;
  }

  public MutableLiveData<Pair<Boolean, Song>> getShowMySongDownLoadingData() {
    return showMySongDownLoadingData;
  }

  public MutableLiveData<Pair<Boolean, Song>> getShowOtherSongDownLoadingData() {
    return showOtherSongDownLoadingData;
  }

  public MutableLiveData<Boolean> getShowSongPanelData() {
    return showSongPanelData;
  }

  public MutableLiveData<Integer> getPlayStateChangedData() {
    return playStateChangedData;
  }

  public MutableLiveData<Song> getDeleteSongData() {
    return deleteSongData;
  }

  private final NEOrderSongListener orderSongListener =
      new NEOrderSongListener() {
        @Override
        public void onSongOrdered(Song song) {
          if (song.getOperator() != null && song.getOperator().getUserName() != null) {
            chatRoomMsgData.setValue(
                ChatRoomMsgCreator.createSongMessage(
                    song.getOperator().getUserName(),
                    Utils.getApp().getString(R.string.listen_song_ordered, song.getSongName())));
          }
          listenTogetherService.queryCurrentPlayingSong(
              new NetRequestCallback<OrderSong>() {
                @Override
                public void success(@Nullable OrderSong info) {
                  ALog.i(TAG, "onSongOrdered queryCurrentPlayingSong success info:" + info);
                  if (info == null) {
                    ALog.i(TAG, "current song is empty");
                    // 当前无播放歌曲
                    downloadSongThenReport(song);
                  } else {
                    ALog.i(TAG, "current song is not empty");
                    if (copyrightedMedia.isSongPreloaded(info.songId, info.channel)) {
                      ALog.i(TAG, "onSongOrdered isSongPreloaded");
                    } else {
                      copyrightedMedia.preloadSong(
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
                }

                @Override
                public void error(int code, @Nullable String msg) {
                  ALog.e(
                      TAG,
                      "onSongOrdered queryCurrentPlayingSong error code: "
                          + code
                          + ", msg: "
                          + msg);
                }
              });
        }

        @Override
        public void onSongDeleted(Song song) {
          if (!copyrightedMedia.isSongPreloaded(song.getSongId(), song.getChannel())) {
            copyrightedMedia.cancelPreloadSong(song.getSongId(), song.getChannel());
          }
          if (song.getOperator() != null && song.getOperator().getUserName() != null) {
            chatRoomMsgData.setValue(
                ChatRoomMsgCreator.createSongMessage(
                    song.getOperator().getUserName(),
                    Utils.getApp().getString(R.string.listen_song_deleted, song.getSongName())));
          }
          if (getCurrentPlayingSong() != null
              && getCurrentPlayingSong().getOrderId() == song.getOrderId()
              && song.getNextOrderSong() != null) {
            downloadSongThenReport(song.getNextOrderSong());
          }
          deleteSongData.setValue(song);
        }

        @Override
        public void onOrderedSongListChanged() {}

        @Override
        public void onSongSwitched(Song song) {
          handleSongSwitchedEvent(song);
          if (song.getOperator() != null
              && song.getOperator().getUserName() != null
              && !(!TextUtils.isEmpty(song.getAttachment())
                  && song.getAttachment().equals(OrderSongConstant.PLAY_COMPLETE_FLAG))) {
            chatRoomMsgData.setValue(
                ChatRoomMsgCreator.createSongMessage(
                    song.getOperator().getUserName(),
                    Utils.getApp().getString(R.string.listen_song_switched)));
          }
        }

        @Override
        public void onSongStarted(Song song) {
          playStateChangedData.setValue(SONG_START);
          showSongPanelData.setValue(true);
          if (song.getOperator() != null && song.getOperator().getUserName() != null) {
            chatRoomMsgData.setValue(
                ChatRoomMsgCreator.createSongMessage(
                    "", Utils.getApp().getString(R.string.listen_song_start, song.getSongName())));
          }
        }

        @Override
        public void onSongPaused(Song song) {
          playStateChangedData.setValue(SONG_PAUSE);
          if (song.getOperator() != null && song.getOperator().getUserName() != null) {
            chatRoomMsgData.setValue(
                ChatRoomMsgCreator.createSongMessage(
                    song.getOperator().getUserName(),
                    Utils.getApp().getString(R.string.listen_song_pause, song.getSongName())));
          }
        }

        @Override
        public void onSongResumed(Song song) {
          playStateChangedData.setValue(SONG_RESUME);
          if (song.getOperator() != null && song.getOperator().getUserName() != null) {
            chatRoomMsgData.setValue(
                ChatRoomMsgCreator.createSongMessage(
                    song.getOperator().getUserName(),
                    Utils.getApp().getString(R.string.listen_song_start, song.getSongName())));
          }
        }
      };

  private void downloadSongThenReport(Song song) {
    if (copyrightedMedia.isSongPreloaded(song.getSongId(), song.getChannel())) {
      reportReady(song.getOrderId());
    } else {
      copyrightedMedia.preloadSong(
          song.getSongId(),
          song.getChannel(),
          new NESongPreloadCallback() {
            @Override
            public void onPreloadStart(String songId, int channel) {
              showMySongDownLoadingData.setValue(new Pair<>(true, song));
            }

            @Override
            public void onPreloadProgress(String songId, int channel, float progress) {
              showMySongDownLoadingData.setValue(new Pair<>(true, song));
            }

            @Override
            public void onPreloadComplete(String songId, int channel, int errorCode, String msg) {
              reportReady(song.getOrderId());
              showMySongDownLoadingData.setValue(new Pair<>(false, song));
            }
          });
    }
  }

  private final NEListenTogetherListener listenTogetherListener =
      new NEListenTogetherListener() {

        @Override
        public void onSongProgressNotifyChanged(Song song, long position) {}

        @Override
        public void onSongOtherDownloadStateChanged(Song song, boolean isDownloading) {
          showOtherSongDownLoadingData.setValue(new Pair<>(isDownloading, song));
        }
      };

  private final com.blankj.utilcode.util.NetworkUtils.OnNetworkStatusChangedListener
      onNetworkStatusChangedListener =
          new com.blankj.utilcode.util.NetworkUtils.OnNetworkStatusChangedListener() {
            @Override
            public void onDisconnected() {
              ALog.i(TAG, "onNetworkUnavailable");
            }

            @Override
            public void onConnected(com.blankj.utilcode.util.NetworkUtils.NetworkType networkType) {
              ALog.i(TAG, "onNetworkAvailable");
              queryCurrentPlayingSong();
            }
          };

  public void initialize(ListenTogetherRoomModel roomModel) {
    this.roomModel = roomModel;
    com.blankj.utilcode.util.NetworkUtils.registerNetworkStatusChangedListener(
        onNetworkStatusChangedListener);
    NEOrderSongService.INSTANCE.addListener(orderSongListener);
    listenTogetherService.addListener(listenTogetherListener);
    queryCurrentPlayingSong();
  }

  private void handleSongSwitchedEvent(Song song) {
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
      if (copyrightedMedia.isSongPreloaded(nextSong.getSongId(), nextSong.getChannel())) {
        listenTogetherService.reportReady(
            nextSong.getOrderId(),
            new NetRequestCallback<Boolean>() {
              @Override
              public void success(@Nullable Boolean info) {
                ALog.i(TAG, "handleSongSwitchedEvent isSongPreloaded reportReady success");
              }

              @Override
              public void error(int code, @Nullable String msg) {
                ALog.e(
                    TAG,
                    "handleSongSwitchedEvent isSongPreloaded reportReady error,code:"
                        + code
                        + ",msg:"
                        + msg);
              }
            });
      } else {
        Song finalNextSong = nextSong;
        copyrightedMedia.preloadSong(
            nextSong.getSongId(),
            nextSong.getChannel(),
            new NESongPreloadCallback() {
              @Override
              public void onPreloadStart(String songId, int channel) {
                showMySongDownLoadingData.setValue(new Pair<>(true, song));
                listenTogetherService.notifyOtherMySongIsDownloading(song, true);
              }

              @Override
              public void onPreloadProgress(String songId, int channel, float progress) {
                showMySongDownLoadingData.setValue(new Pair<>(true, song));
                listenTogetherService.notifyOtherMySongIsDownloading(song, true);
              }

              @Override
              public void onPreloadComplete(String songId, int channel, int errorCode, String msg) {
                showMySongDownLoadingData.setValue(new Pair<>(false, song));
                listenTogetherService.notifyOtherMySongIsDownloading(song, false);
                listenTogetherService.reportReady(
                    finalNextSong.getOrderId(),
                    new NetRequestCallback<Boolean>() {
                      @Override
                      public void success(@Nullable Boolean info) {
                        ALog.i(TAG, "handleSongSwitchedEvent preloadSong reportReady success");
                      }

                      @Override
                      public void error(int code, @Nullable String msg) {
                        ALog.e(
                            TAG,
                            "handleSongSwitchedEvent preloadSong reportReady error,code:"
                                + code
                                + ",msg:"
                                + msg);
                      }
                    });
              }
            });
      }
    }
  }

  private void queryCurrentSongPlayPosition() {
    listenTogetherService.queryCurrentSongPlayPosition();
  }

  private void queryCurrentPlayingSong() {
    listenTogetherService.queryCurrentPlayingSong(
        new NetRequestCallback<OrderSong>() {
          @Override
          public void success(@Nullable OrderSong info) {
            ALog.i(TAG, "queryCurrentPlayingSong success,info:" + info);
            if (info == null) {
              showSongPanelData.setValue(false);
              return;
            }
            if (copyrightedMedia.isSongPreloaded(info.songId, info.channel)) {
              if (info.songStatus == ListenTogetherConstant.SONG_READY_STATE) {
                ALog.i(TAG, "songStatus ready");
                reportReady(info.orderId);
              } else {
                queryCurrentSongPlayPosition();
                playCurrentSongData.setValue(info);
                preloadSongList();
              }
            } else {
              Song song = new Song();
              song.setOrderId(info.orderId);
              song.setSongId(info.songId);
              copyrightedMedia.preloadSong(
                  info.songId,
                  info.channel,
                  new NESongPreloadCallback() {
                    @Override
                    public void onPreloadStart(String songId, int channel) {}

                    @Override
                    public void onPreloadProgress(String songId, int channel, float progress) {
                      showMySongDownLoadingData.setValue(new Pair<>(true, song));
                    }

                    @Override
                    public void onPreloadComplete(
                        String songId, int channel, int errorCode, String msg) {
                      if (info.songStatus == ListenTogetherConstant.SONG_READY_STATE) {
                        ALog.i(TAG, "songStatus ready");
                        reportReady(info.orderId);
                      } else {
                        queryCurrentSongPlayPosition();
                        playCurrentSongData.setValue(info);
                        showMySongDownLoadingData.setValue(new Pair<>(false, song));
                        preloadSongList();
                      }
                    }
                  });
            }
          }

          @Override
          public void error(int code, @Nullable String msg) {
            ALog.e(TAG, "initialize queryCurrentPlayingSong code: " + code + ", msg: " + msg);
          }
        });
  }

  private void reportReady(long orderId) {
    listenTogetherService.reportReady(
        orderId,
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

  @Override
  protected void onCleared() {
    super.onCleared();
    com.blankj.utilcode.util.NetworkUtils.unregisterNetworkStatusChangedListener(
        onNetworkStatusChangedListener);
    NEOrderSongService.INSTANCE.removeListener(orderSongListener);
    listenTogetherService.removeListener(listenTogetherListener);
  }

  public void seekTo(long position) {
    listenTogetherService.notifyOtherSeekTo(position);
  }

  public Song getCurrentPlayingSong() {
    return listenTogetherService.getCurrentPlayingSong();
  }

  private void preloadSongList() {
    NEOrderSongService.INSTANCE.getOrderedSongs(
        new NetRequestCallback<List<NEOrderSong>>() {
          @Override
          public void success(@Nullable List<NEOrderSong> info) {
            for (NEOrderSong songModel : info) {
              NECopyrightedMedia.getInstance()
                  .preloadSong(
                      songModel.getSongId(),
                      songModel.getChannel(),
                      new NESongPreloadCallback() {
                        @Override
                        public void onPreloadStart(String songId, int channel) {}

                        @Override
                        public void onPreloadProgress(String songId, int channel, float progress) {}

                        @Override
                        public void onPreloadComplete(
                            String songId, int channel, int errorCode, String msg) {
                          String songURI =
                              NECopyrightedMedia.getInstance()
                                  .getSongURI(songId, channel, SongResType.TYPE_ORIGIN);
                          ALog.d(
                              TAG,
                              "onPreloadComplete,songId:"
                                  + songId
                                  + ",channel:"
                                  + channel
                                  + ",songURI:"
                                  + songURI);
                        }
                      });
            }
          }

          @Override
          public void error(int code, @Nullable String msg) {}
        });
  }
}

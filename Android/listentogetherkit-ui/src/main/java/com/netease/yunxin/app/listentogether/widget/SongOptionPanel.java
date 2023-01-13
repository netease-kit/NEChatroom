// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.widget;

import static com.netease.yunxin.kit.copyrightedmedia.api.model.NELyricType.NELyricTypeKas;
import static com.netease.yunxin.kit.copyrightedmedia.api.model.NELyricType.NELyricTypeLrc;
import static com.netease.yunxin.kit.copyrightedmedia.api.model.NELyricType.NELyricTypeQrc;
import static com.netease.yunxin.kit.copyrightedmedia.api.model.NELyricType.NELyricTypeYrc;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.SeekBar;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;
import com.netease.yunxin.app.listentogether.activity.ListenTogetherBaseActivity;
import com.netease.yunxin.app.listentogether.core.ListenTogetherService;
import com.netease.yunxin.app.listentogether.core.NEListenTogetherListener;
import com.netease.yunxin.app.listentogether.core.SongPlayManager;
import com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant;
import com.netease.yunxin.app.listentogether.model.ListenTogetherRoomModel;
import com.netease.yunxin.app.listentogether.utils.ListenTogetherUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.ui.widgets.datepicker.DateFormatUtils;
import com.netease.yunxin.kit.copyrightedmedia.api.LyricCallback;
import com.netease.yunxin.kit.copyrightedmedia.api.NECopyrightedMedia;
import com.netease.yunxin.kit.copyrightedmedia.api.NESongPreloadCallback;
import com.netease.yunxin.kit.copyrightedmedia.api.SongResType;
import com.netease.yunxin.kit.copyrightedmedia.api.model.NELyric;
import com.netease.yunxin.kit.listentogether.R;
import com.netease.yunxin.kit.listentogether.databinding.ListenSongOptionPanelBinding;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherRoomListenerAdapter;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongListener;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.constant.OrderSongConstant;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.core.util.GsonUtils;
import com.netease.yunxin.kit.ordersong.ui.NEOrderSongCallback;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;

/** 一起听歌曲操作面板 */
public class SongOptionPanel extends ConstraintLayout {
  private static final String TAG = "SongOptionPanel";
  private ListenSongOptionPanelBinding binding;
  private final NECopyrightedMedia copyrightedMedia = NECopyrightedMedia.getInstance();
  private final ListenTogetherService listenTogetherService = ListenTogetherService.getInstance();
  private final SongPlayManager songPlayManager = SongPlayManager.getInstance();
  private boolean pause = false;
  private String roomUuid;
  /** 当前播放位置 */
  private long currentPlayPosition = 0;

  private boolean isTouchingSeekBar = false;
  private Song currentSong;
  private static final int ERROR_CODE = -1;

  private OrderSongViewModel orderSongViewModel;
  private final NEOrderSongListener neOrderSongListener =
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
          pause = false;
          orderSongViewModel.getOrderedSongOptionRefreshEvent().postValue(pause);
          binding.ivPauseResume.setImageResource(R.drawable.listen_pause_state);
          binding.tvPauseResume.setText(R.string.listen_pause);
          startPlay(
              song,
              true,
              new NEOrderSongCallback<Void>() {
                @Override
                public void onSuccess(@Nullable Void unused) {}

                @Override
                public void onFailure(int code, @Nullable String msg) {}
              });
        }

        @Override
        public void onSongPaused(Song song) {
          pause = true;
          orderSongViewModel.getOrderedSongOptionRefreshEvent().postValue(pause);
          songPlayManager.pause();
          binding.ivPauseResume.setImageResource(R.drawable.listen_resume_state);
          binding.tvPauseResume.setText(R.string.listen_play);
        }

        @Override
        public void onSongResumed(Song song) {
          pause = false;
          binding.ivPauseResume.setImageResource(R.drawable.listen_pause_state);
          binding.tvPauseResume.setText(R.string.listen_pause);
          if (currentSong != null && currentSong.getSongId().equals(song.getSongId())) {
            songPlayManager.resume();
          }
        }
      };

  private final NEListenTogetherListener listenTogetherListener =
      new NEListenTogetherListener() {

        @Override
        public void onSongProgressNotifyChanged(Song song, long position) {
          seekTo(position, song.getSongTime());
        }

        @Override
        public void onSongOtherDownloadStateChanged(Song song, boolean isDownloading) {}
      };
  private NEListenTogetherRoomListenerAdapter roomListener =
      new NEListenTogetherRoomListenerAdapter() {
        @Override
        public void onAudioEffectTimestampUpdate(@NonNull String uuid, long timeStampMS) {
          if (currentSong == null) {
            return;
          }
          binding.lyricView.update(timeStampMS);
          binding.tvSongProgress.setText(DateFormatUtils.long2StrHS(timeStampMS));
          currentPlayPosition = timeStampMS;
          int progress =
              (int) ((currentPlayPosition * 1.0 / currentSong.getSongTime() * 1.0) * 100);
          if (!isTouchingSeekBar) {
            binding.seekbar.setProgress(progress);
          }
        }

        @Override
        public void onAudioEffectFinished(int effectId) {
          ALog.i(TAG, "onAudioEffectFinished,effectId:" + effectId);
          if (ListenTogetherUtils.isCurrentHost()) {
            ALog.i(TAG, "Anchor switch song");
            switchSong(null, true);
          }
        }
      };

  public SongOptionPanel(Context context) {
    super(context);
    init(context, null);
  }

  public SongOptionPanel(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context, attrs);
  }

  public SongOptionPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context, attrs);
  }

  private void init(Context context, AttributeSet attributeSet) {
    binding = ListenSongOptionPanelBinding.inflate(LayoutInflater.from(context), this, true);
    initListener();
    initObserver(context);
  }

  private void initObserver(Context context) {
    orderSongViewModel =
        new ViewModelProvider((ListenTogetherBaseActivity) context).get(OrderSongViewModel.class);
    // 点歌台事件
    orderSongViewModel
        .getVolumeChangedEvent()
        .observe((LifecycleOwner) context, integer -> songPlayManager.setVolume(integer));

    orderSongViewModel
        .getPauseOrResumeEvent()
        .observe((LifecycleOwner) context, aBoolean -> pauseOrResume());

    orderSongViewModel
        .getSwitchSongEvent()
        .observe(
            (LifecycleOwner) context,
            neOrderSong -> {
              if (neOrderSong != null) {
                ALog.i(TAG, "order song dialog ordered list switch song");
                if (currentSong != null && currentSong.getOrderId() == neOrderSong.getOrderId()) {
                  ALog.i(TAG, "the same song");
                  return;
                }
                Song nextSong = new Song();
                nextSong.setOrderId(neOrderSong.getOrderId());
                nextSong.setSongId(neOrderSong.getSongId());
                nextSong.setSongName(neOrderSong.getSongName());
                nextSong.setSinger(neOrderSong.getSinger());
                nextSong.setSongTime(neOrderSong.getSongTime());
                switchSong(nextSong);
              } else {
                ALog.i(TAG, "order song dialog button switch song");
                switchSong(null);
              }
            });
  }

  private void initListener() {
    binding.ivPauseResume.setImageResource(R.drawable.listen_pause_state);
    binding.tvPauseResume.setText(R.string.listen_pause);
    binding.ivPauseResume.setOnClickListener(v -> pauseOrResume());
    binding.ivNextSong.setOnClickListener(v -> switchSong(null));

    binding.seekbar.setOnSeekBarChangeListener(
        new SeekBar.OnSeekBarChangeListener() {
          @Override
          public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {}

          @Override
          public void onStartTrackingTouch(SeekBar seekBar) {
            isTouchingSeekBar = true;
          }

          @Override
          public void onStopTrackingTouch(SeekBar seekBar) {
            isTouchingSeekBar = false;
            if (currentSong != null) {
              seekTo(
                  (long) (seekBar.getProgress() / 100.0 * currentSong.getSongTime()),
                  currentSong.getSongTime());
              if (seekBar.getProgress() == 100) {
                songPlayManager.pause();
                switchSong(null, true);
              } else {
                if (callback != null) {
                  callback.notifySongPositionChanged(currentPlayPosition);
                }
              }
            }
          }
        });
  }

  public void startPlay(Song song, boolean needPlay, NEOrderSongCallback<Void> callback) {
    if (currentSong != null && !currentSong.getSongId().equals(song.getSongId())) {
      // 切歌
      songPlayManager.stop();
    }
    showSongInfoAndLocalPlay(song, needPlay, callback);
  }

  private void showSongInfoAndLocalPlay(
      Song song, boolean needPlay, NEOrderSongCallback<Void> callback) {
    showSongInfo(song);
    if (!copyrightedMedia.isSongPreloaded(song.getSongId(), song.getChannel())) {
      copyrightedMedia.preloadSong(
          song.getSongId(),
          song.getChannel(),
          new NESongPreloadCallback() {
            @Override
            public void onPreloadStart(String songId, int channel) {
              if (loadingCallback != null) {
                loadingCallback.showSongLoading(true);
              }
              listenTogetherService.notifyOtherMySongIsDownloading(song, true);
            }

            @Override
            public void onPreloadProgress(String songId, int channel, float progress) {
              if (loadingCallback != null) {
                loadingCallback.showSongLoading(true);
              }
              listenTogetherService.notifyOtherMySongIsDownloading(song, true);
            }

            @Override
            public void onPreloadComplete(String songId, int channel, int errorCode, String msg) {
              if (loadingCallback != null) {
                loadingCallback.showSongLoading(false);
              }
              listenTogetherService.notifyOtherMySongIsDownloading(song, false);
              loadLyricAndLocalPlayInner(song, needPlay, callback);
            }
          });
    } else {
      loadLyricAndLocalPlayInner(song, needPlay, callback);
    }
  }

  private void loadLyricAndLocalPlayInner(
      Song song, boolean needPlay, NEOrderSongCallback<Void> callback) {
    copyrightedMedia.preloadSongLyric(
        song.getSongId(),
        song.getChannel(),
        new LyricCallback() {
          @Override
          public void success(@Nullable String content, @Nullable String lyricType, int channel) {
            NELyric lyric;
            if (NELyricTypeYrc.getType().equals(lyricType)) {
              lyric = NELyric.initWithContent(content, NELyricTypeYrc);
            } else if (NELyricTypeQrc.getType().equals(lyricType)) {
              lyric = NELyric.initWithContent(content, NELyricTypeQrc);
            } else if (NELyricTypeKas.getType().equals(lyricType)) {
              lyric = NELyric.initWithContent(content, NELyricTypeKas);
            } else {
              lyric = NELyric.initWithContent(content, NELyricTypeLrc);
            }
            binding.lyricView.loadWithLyricModel(lyric);
            String songURI =
                copyrightedMedia.getSongURI(
                    song.getSongId(), song.getChannel(), SongResType.TYPE_ORIGIN);
            if (!TextUtils.isEmpty(songURI)) {
              long songDuration = getDuration(songURI);
              song.setSongTime(songDuration);
              binding.tvSongDuration.setText(DateFormatUtils.long2StrHS(songDuration));
              songPlayManager.start(songURI, currentPlayPosition);
              if (!needPlay) {
                songPlayManager.pause();
              }
              SongOptionPanel.this.currentSong = song;
              listenTogetherService.setCurrentPlayingSong(song);
              callback.onSuccess(null);
            } else {
              ALog.e(TAG, "songURI is empty");
              callback.onFailure(ERROR_CODE, "songURI is empty");
            }
          }

          @Override
          public void error(int code, @Nullable String msg) {
            ALog.e(TAG, "preloadSongLyric error,code:" + code + ",msg:" + msg);
            callback.onFailure(code, msg);
          }
        });
  }

  private void showSongInfo(Song song) {
    currentPlayPosition = 0;
    if (!TextUtils.isEmpty(song.getSinger())) {
      binding.songName.setText(song.getSongName() + "-" + song.getSinger());
    } else {
      binding.songName.setText(song.getSongName());
    }
    binding.tvSongProgress.setText(DateFormatUtils.long2StrHS(currentPlayPosition));
    int progress = (int) ((currentPlayPosition * 1.0 / song.getSongTime()) * 100);
    binding.seekbar.setProgress(progress);
    binding.lyricView.reset("loading..");
    binding.lyricView.update(0);
    setVisibility(VISIBLE);
  }

  public void seekTo(long position, long songTime) {
    currentPlayPosition = position;
    binding.tvSongProgress.setText(DateFormatUtils.long2StrHS(position));
    NEListenTogetherKit.getInstance()
        .setPlayingPosition(ListenTogetherConstant.EFFECT_ID, position);
    int progress = (int) ((currentPlayPosition * 1.0 / songTime * 1.0) * 100.0);
    ALog.i(TAG, "seekTo position:" + position + ",songTime:" + songTime + ",progress:" + progress);
    binding.seekbar.setProgress(progress);
    binding.lyricView.update(position);
  }

  private void pauseOrResume() {
    if (currentSong == null) {
      return;
    }
    pause = !pause;
    if (pause) {
      listenTogetherService.reportPause(
          currentSong.getOrderId(),
          new NetRequestCallback<Boolean>() {
            @Override
            public void success(@Nullable Boolean info) {
              ALog.i(TAG, "reportPause success:" + info);
            }

            @Override
            public void error(int code, @Nullable String msg) {
              ALog.e(TAG, "reportPause error code:" + code + ",msg:" + msg);
            }
          });
    } else {
      listenTogetherService.reportResume(
          currentSong.getOrderId(),
          new NetRequestCallback<Boolean>() {
            @Override
            public void success(@Nullable Boolean info) {
              ALog.i(TAG, "reportStart success:" + info);
            }

            @Override
            public void error(int code, @Nullable String msg) {
              ALog.e(TAG, "reportStart error code:" + code + ",msg:" + msg);
            }
          });
    }
    orderSongViewModel.getOrderedSongOptionRefreshEvent().postValue(pause);
  }

  private void switchSong(Song nextSong) {
    switchSong(nextSong, false);
  }

  private void switchSong(Song nextSong, boolean playComplete) {
    String nextSongStr = null;
    if (playComplete) {
      nextSongStr = OrderSongConstant.PLAY_COMPLETE_FLAG;
    } else {
      if (nextSong != null) {
        nextSongStr = GsonUtils.toJson(nextSong);
      }
    }
    if (currentSong == null) {
      ALog.e(TAG, "currentSong is null");
      return;
    }
    NEOrderSongService.INSTANCE.switchSong(
        currentSong.getOrderId(),
        nextSongStr,
        new NetRequestCallback<Boolean>() {
          @Override
          public void success(@Nullable Boolean info) {
            ALog.i(TAG, "switchSong success");
          }

          @Override
          public void error(int code, @Nullable String msg) {
            ALog.e(TAG, "switchSong error,code:" + code + ",msg:" + msg);
            ToastUtils.INSTANCE.showShortToast(
                getContext(), "operation failed code:" + code + ",msg:" + msg);
          }
        });
  }

  private long getDuration(String path) {
    MediaMetadataRetriever mmr = new MediaMetadataRetriever();
    long duration = 0;
    try {
      mmr.setDataSource(path);
      String time = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
      duration = Long.parseLong(time);
    } catch (Exception ex) {
      ex.printStackTrace();
    } finally {
      mmr.release();
    }
    return duration;
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    NEListenTogetherKit.getInstance().removeRoomListener(roomListener);
    listenTogetherService.removeListener(listenTogetherListener);
    NEOrderSongService.INSTANCE.removeListener(neOrderSongListener);
  }

  public void setSongPositionCallback(SongPositionChangedCallback callback) {
    this.callback = callback;
  }

  private SongPositionChangedCallback callback;

  public void setRoomInfo(ListenTogetherRoomModel voiceRoomInfo) {
    this.roomUuid = voiceRoomInfo.getRoomUuid();
    listenTogetherService.setRoomInfo(voiceRoomInfo);
    listenTogetherService.addListener(listenTogetherListener);
    NEListenTogetherKit.getInstance().addRoomListener(roomListener);
    NEOrderSongService.INSTANCE.addListener(neOrderSongListener);
  }

  public void reset() {
    songPlayManager.stop();
    currentSong = null;
    currentPlayPosition = 0;
    pause = false;
  }

  public void setPauseOrResumeState(boolean isPlaying) {
    if (isPlaying) {
      pause = false;
      binding.ivPauseResume.setImageResource(R.drawable.listen_pause_state);
      binding.tvPauseResume.setText(R.string.listen_pause);
    } else {
      pause = true;
      binding.ivPauseResume.setImageResource(R.drawable.listen_resume_state);
      binding.tvPauseResume.setText(R.string.listen_play);
    }
  }

  public interface SongPositionChangedCallback {
    void notifySongPositionChanged(long position);
  }

  public void setLoadingCallback(SongLoadingCallback loadingCallback) {
    this.loadingCallback = loadingCallback;
  }

  private SongLoadingCallback loadingCallback;

  public interface SongLoadingCallback {
    void showSongLoading(boolean show);
  }
}

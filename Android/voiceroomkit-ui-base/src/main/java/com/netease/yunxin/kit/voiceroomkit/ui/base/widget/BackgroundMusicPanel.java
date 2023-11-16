// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.widget;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.copyrightedmedia.api.NECopyrightedMedia;
import com.netease.yunxin.kit.copyrightedmedia.api.SongResType;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.constant.OrderSongConstant;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.core.util.GsonUtils;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomRole;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.base.activity.VoiceRoomBaseActivity;
import com.netease.yunxin.kit.voiceroomkit.ui.base.service.SongPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.base.utils.FloatPlayManager;

public class BackgroundMusicPanel extends AppCompatTextView {
  private static final String TAG = "BackgroundMusicPanel";
  private boolean pause = false;
  private String roomUuid;
  /** 当前播放位置 */
  private Song currentSong;

  private OrderSongViewModel orderSongViewModel;

  private final SongPlayManager songPlayManager = SongPlayManager.getInstance();

  private final NEVoiceRoomListenerAdapter roomListener =
      new NEVoiceRoomListenerAdapter() {
        @Override
        public void onAudioEffectTimestampUpdate(long effectId, long timeStampMS) {
          ALog.i(
              TAG,
              "onAudioEffectTimestampUpdate,effectId:" + effectId + ", timeStampMS:" + timeStampMS);
        }

        @Override
        public void onAudioEffectFinished(int effectId) {
          ALog.i(TAG, "onAudioEffectFinished,effectId:" + effectId);
          if (effectId == SongPlayManager.EFFECT_ID) {
            NEVoiceRoomMember localMember = NEVoiceRoomKit.getInstance().getLocalMember();
            if (localMember != null
                && localMember.getRole().equals(NEVoiceRoomRole.HOST.getValue())) {
              ALog.i(TAG, "Anchor switch song");
              switchSong(null, true);
            }
          }
        }
      };

  public BackgroundMusicPanel(Context context) {
    super(context);
    init(context);
  }

  public BackgroundMusicPanel(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public BackgroundMusicPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context);
  }

  private void init(Context context) {
    initObserver(context);
  }

  private void initObserver(Context context) {
    orderSongViewModel =
        new ViewModelProvider((VoiceRoomBaseActivity) context).get(OrderSongViewModel.class);
    // 点歌台事件
    orderSongViewModel
        .getVolumeChangedEvent()
        .observe((LifecycleOwner) context, songPlayManager::setVolume);

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
                if (currentSong != null
                    && currentSong.getOrderId() == neOrderSong.getOrderSong().getOrderId()) {
                  ALog.i(TAG, "the same song");
                  return;
                }
                Song nextSong = new Song();
                nextSong.setOrderId(neOrderSong.getOrderSong().getOrderId());
                nextSong.setSongId(neOrderSong.getOrderSong().getSongId());
                nextSong.setSongName(neOrderSong.getOrderSong().getSongName());
                nextSong.setSinger(neOrderSong.getOrderSong().getSinger());
                nextSong.setChannel(neOrderSong.getOrderSong().getChannel());
                if (neOrderSong.getOrderSong().getSongTime() != 0) {
                  nextSong.setSongTime(neOrderSong.getOrderSong().getSongTime());
                }
                switchSong(nextSong);
              } else {
                ALog.i(TAG, "order song dialog button switch song");
                switchSong(null);
              }
            });

    orderSongViewModel
        .getOrderSongListChangeEvent()
        .observe(
            (LifecycleOwner) context,
            neOrderSongs -> {
              if (neOrderSongs.isEmpty()) {
                setVisibility(GONE);
              } else {
                setVisibility(VISIBLE);
              }
            });
  }

  public void startPlay(Song song, boolean isLocalPlay) {
    ALog.i(TAG, "startPlay,song:" + song.toString());
    if (currentSong != null && song.getOrderId() != currentSong.getOrderId()) {
      stopPlay();
    }

    if (isLocalPlay) {
      String songURI =
          NECopyrightedMedia.getInstance()
              .getSongURI(song.getSongId(), song.getChannel(), SongResType.TYPE_ORIGIN);
      if (!TextUtils.isEmpty(songURI)) {
        currentSong = song;
        setText(song.getSongName());
        setVisibility(View.VISIBLE);
        songPlayManager.start(songURI, 0);
      } else {
        ALog.i(TAG, "startPlay but songURI is empty");
        switchSong(null, true);
      }
    } else {
      currentSong = song;
      setText(song.getSongName());
      setVisibility(View.VISIBLE);
    }
  }

  public void deleteSong(Song song) {
    ALog.i(TAG, "deleteSong,song:" + song.toString());
    if (currentSong != null && currentSong.getOrderId() == song.getOrderId()) {
      stopPlay();
      setVisibility(View.GONE);
    }
  }

  private void stopPlay() {
    songPlayManager.stop();
  }

  private void pauseOrResume() {
    pause = !pause;
    if (pause) {
      songPlayManager.pause();
    } else {
      songPlayManager.resume();
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
      ALog.e(TAG, "CurrentSong is Empty");
      return;
    }
    if (nextSong != null) {
      nextSongStr = GsonUtils.toJson(nextSong);
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

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(roomListener);
    if (!FloatPlayManager.getInstance().isShowFloatView()) {
      stopPlay();
    }
  }

  public void setRoomUuid(String roomUuid) {
    this.roomUuid = roomUuid;
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(roomListener);
  }

  @Override
  public boolean isFocused() {
    return true;
  }
}

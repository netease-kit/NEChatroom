// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.core;

import static com.netease.yunxin.app.listentogether.core.constant.ListenTogetherCmd.ASK_PLAYING_POSITION_CMD;
import static com.netease.yunxin.app.listentogether.core.constant.ListenTogetherCmd.NOTIFY_OTHER_MY_SONG_IS_READY_CMD;
import static com.netease.yunxin.app.listentogether.core.constant.ListenTogetherCmd.SYNC_PLAYING_POSITION_CMD;

import androidx.annotation.NonNull;
import com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant;
import com.netease.yunxin.app.listentogether.core.model.NERoomListenerEx;
import com.netease.yunxin.app.listentogether.model.ListenTogetherRoomModel;
import com.netease.yunxin.app.listentogether.utils.ListenTogetherUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.NEVoiceRoomRole;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.model.OrderSong;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.roomkit.api.NECallback;
import com.netease.yunxin.kit.roomkit.api.NERoomContext;
import com.netease.yunxin.kit.roomkit.api.NERoomKit;
import com.netease.yunxin.kit.roomkit.api.service.NECustomMessage;
import com.netease.yunxin.kit.roomkit.api.service.NEMessageChannelListener;
import com.netease.yunxin.kit.roomkit.api.service.NEMessageChannelService;
import java.util.ArrayList;
import java.util.List;
import kotlin.Unit;
import org.json.JSONException;
import org.json.JSONObject;

/** 一起听业务管理类 */
public class ListenTogetherService {
  private static final String TAG = "ListenTogetherService";
  private static final int TWO_COUNT = 2;
  private final List<NEListenTogetherListener> listeners = new ArrayList<>();
  private boolean hasAddRoomListen = false;
  private String roomUuid;
  private String anchorUserUuid;
  private Song currentPlayingSong;
  private long currentPlayingPosition;
  private final NEMessageChannelService messageChannelService =
      NERoomKit.instance.getService(NEMessageChannelService.class);
  private final NEMessageChannelListener messageChannelListener =
      message -> {
        if (message.getCommandId() == ASK_PLAYING_POSITION_CMD) {
          replyPlayingPosition(message);
        } else if (message.getCommandId() == SYNC_PLAYING_POSITION_CMD) {
          JSONObject jsonObject = null;
          try {
            jsonObject = new JSONObject(message.getData());
            long progress = jsonObject.optLong(ListenTogetherConstant.PROGRESS);
            int channel = jsonObject.optInt(ListenTogetherConstant.CHANNEL);
            String songId = jsonObject.optString(ListenTogetherConstant.SONG_ID);
            long songTime = jsonObject.optLong(ListenTogetherConstant.SONG_TIME);
            Song song = new Song();
            song.setSongId(songId);
            song.setChannel(channel);
            song.setSongTime(songTime);
            for (NEListenTogetherListener listener : listeners) {
              listener.onSongProgressNotifyChanged(song, progress);
            }
          } catch (JSONException e) {
            e.printStackTrace();
            ALog.e(TAG, "onReceiveCustomMessage JSONException e:" + e);
          }
        } else if (message.getCommandId() == NOTIFY_OTHER_MY_SONG_IS_READY_CMD) {
          JSONObject jsonObject = null;
          try {
            jsonObject = new JSONObject(message.getData());
            String songId = jsonObject.optString(ListenTogetherConstant.SONG_ID);
            boolean isDownloading = jsonObject.optBoolean(ListenTogetherConstant.IS_DOWNLOADING);
            Song song = new Song();
            song.setSongId(songId);
            for (NEListenTogetherListener listener : listeners) {
              listener.onSongOtherDownloadStateChanged(song, isDownloading);
            }
          } catch (JSONException e) {
            e.printStackTrace();
            ALog.e(TAG, "onReceiveCustomMessage JSONException e:" + e);
          }
        }
      };
  private final NERoomListenerEx neRoomListener =
      new NERoomListenerEx() {
        @Override
        public void onAudioEffectTimestampUpdate(@NonNull long effectId, long timeStampMS) {
          currentPlayingPosition = timeStampMS;
        }
      };

  private static class Inner {
    private static final ListenTogetherService sInstance = new ListenTogetherService();
  }

  public static ListenTogetherService getInstance() {
    return Inner.sInstance;
  }

  public void reportReady(long orderId, NetRequestCallback<Boolean> callback) {
    ALog.i(TAG, "reportReady,roomUuid:" + roomUuid + ",orderId:" + orderId);
    NEOrderSongService.INSTANCE.reportReady(orderId, callback);
  }

  public void reportResume(long orderId, NetRequestCallback<Boolean> callback) {
    ALog.i(TAG, "reportResume,roomUuid:" + roomUuid + ",orderId:" + orderId);
    NEOrderSongService.INSTANCE.reportResume(orderId, callback);
  }

  public void reportPause(long orderId, NetRequestCallback<Boolean> callback) {
    ALog.i(TAG, "reportPause,roomUuid:" + roomUuid + ",orderId:" + orderId);
    NEOrderSongService.INSTANCE.reportPause(orderId, callback);
  }

  public void queryCurrentPlayingSong(NetRequestCallback<OrderSong> callback) {
    NEOrderSongService.INSTANCE.queryPlayingSongInfo(callback);
  }

  public void setRoomInfo(ListenTogetherRoomModel voiceRoomInfo) {
    this.roomUuid = voiceRoomInfo.getRoomUuid();
    this.anchorUserUuid = voiceRoomInfo.getAnchorUserUuid();
  }

  public void addListener(NEListenTogetherListener listener) {
    listeners.add(listener);
    NERoomContext roomContext = NERoomKit.getInstance().getRoomService().getRoomContext(roomUuid);
    if (roomContext != null) {
      roomContext.addRoomListener(neRoomListener);
      messageChannelService.addMessageChannelListener(messageChannelListener);
      hasAddRoomListen = true;
    }
  }

  public void removeListener(NEListenTogetherListener listener) {
    listeners.remove(listener);
    if (listeners.isEmpty() && hasAddRoomListen) {
      NERoomContext roomContext = NERoomKit.getInstance().getRoomService().getRoomContext(roomUuid);
      if (roomContext != null) {
        roomContext.removeRoomListener(neRoomListener);
        messageChannelService.removeMessageChannelListener(messageChannelListener);
        hasAddRoomListen = false;
      }
    }
  }

  private void sendCustomMessage(
      String roomUuid,
      String targetUserUuid,
      int commandId,
      String data,
      NECallback<Unit> callback) {
    messageChannelService.sendCustomMessage(roomUuid, targetUserUuid, commandId, data, callback);
  }

  private void replyPlayingPosition(NECustomMessage customMessage) {
    JSONObject jsonObject = new JSONObject();
    try {
      Song song = getCurrentPlayingSong();
      if (song != null) {
        jsonObject.put(ListenTogetherConstant.SONG_ID, song.getSongId());
        jsonObject.put(ListenTogetherConstant.CHANNEL, song.getChannel());
        jsonObject.put(ListenTogetherConstant.SONG_TIME, song.getSongTime());
      }
      jsonObject.put(ListenTogetherConstant.PROGRESS, currentPlayingPosition);
      jsonObject.put(ListenTogetherConstant.TIMESTAMP, System.currentTimeMillis());
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendCustomMessage(
        customMessage.getRoomUuid(),
        customMessage.getSenderUuid(),
        SYNC_PLAYING_POSITION_CMD,
        jsonObject.toString(),
        (code, message, unit) -> {
          ALog.i(
              TAG, "sendCustomMessage SYNC_PLAYING_POSITION_CMD result: " + code + ", " + message);
        });
  }

  public void notifyOtherMySongIsDownloading(Song song, boolean isDownloading) {
    JSONObject jsonObject = new JSONObject();
    try {
      jsonObject.put(ListenTogetherConstant.SONG_ID, song.getSongId());
      jsonObject.put(ListenTogetherConstant.IS_DOWNLOADING, isDownloading);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendCustomMessage(
        roomUuid,
        getOtherUserUuid(),
        NOTIFY_OTHER_MY_SONG_IS_READY_CMD,
        jsonObject.toString(),
        (code, message, unit) -> {
          ALog.i(TAG, "sendCustomMessage SYNC_LOADING_SONG_CMD result: " + code + ", " + message);
        });
  }

  private String getOtherUserUuid() {
    if (NEListenTogetherKit.getInstance().getAllMemberList().size() == 2) {
      return NEListenTogetherKit.getInstance().getAllMemberList().get(1).getAccount();
    }
    return "";
  }

  public void notifyOtherSeekTo(long position) {
    if (NEListenTogetherKit.getInstance().getAllMemberList().size() == 2) {
      JSONObject jsonObject = new JSONObject();
      try {
        Song song = getCurrentPlayingSong();
        if (song != null) {
          jsonObject.put(ListenTogetherConstant.SONG_ID, song.getSongId());
          jsonObject.put(ListenTogetherConstant.CHANNEL, song.getChannel());
          jsonObject.put(ListenTogetherConstant.SONG_TIME, song.getSongTime());
        }
        jsonObject.put(ListenTogetherConstant.PROGRESS, position);
        jsonObject.put(ListenTogetherConstant.TIMESTAMP, System.currentTimeMillis());
      } catch (JSONException e) {
        e.printStackTrace();
      }
      sendCustomMessage(
          roomUuid,
          getOtherUserUuid(),
          SYNC_PLAYING_POSITION_CMD,
          jsonObject.toString(),
          (code, message, data) ->
              ALog.i(
                  TAG,
                  "sendCustomMessage SYNC_PLAYING_POSITION_CMD result: " + code + ", " + message));
    }
  }

  public void queryCurrentSongPlayPosition() {
    JSONObject jsonObject = new JSONObject();
    try {
      jsonObject.put("userUuid", NEListenTogetherKit.getInstance().getLocalMember().getAccount());
    } catch (JSONException e) {
      e.printStackTrace();
      ALog.e(TAG, "queryCurrentSongPlayPosition JSONException e:" + e);
    }
    sendCustomMessage(
        roomUuid,
        getAnotherUserUuid(),
        ASK_PLAYING_POSITION_CMD,
        jsonObject.toString(),
        (code, message, unit) -> {
          ALog.i(
              TAG, "sendCustomMessage ASK_PLAYING_POSITION_CMD result: " + code + ", " + message);
        });
  }

  private String getAnotherUserUuid() {
    if (ListenTogetherUtils.isCurrentHost()
        && NEListenTogetherKit.getInstance().getAllMemberList().size() == TWO_COUNT) {
      return NEListenTogetherKit.getInstance().getAllMemberList().get(1).getAccount();
    }
    return anchorUserUuid;
  }

  public boolean isAnchor() {
    return NEListenTogetherKit.getInstance().getLocalMember() != null
        && NEListenTogetherKit.getInstance()
            .getLocalMember()
            .getRole()
            .equals(NEVoiceRoomRole.HOST.getValue());
  }

  public void setCurrentPlayingSong(Song song) {
    this.currentPlayingSong = song;
  }

  public Song getCurrentPlayingSong() {
    return currentPlayingSong;
  }
}

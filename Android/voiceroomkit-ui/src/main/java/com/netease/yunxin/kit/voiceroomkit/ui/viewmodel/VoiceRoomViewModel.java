// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.kit.voiceroomkit.ui.viewmodel;

import android.net.NetworkInfo;
import android.text.TextUtils;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongListener;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.model.OrderSong;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomEndReason;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.api.model.*;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUI;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.chatroom.ChatRoomMsgCreator;
import com.netease.yunxin.kit.voiceroomkit.ui.helper.SeatHelper;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeat;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeatEvent;
import com.netease.yunxin.kit.voiceroomkit.ui.service.VoiceRoomService;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.SeatUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.SingleLiveEvent;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.VoiceRoomUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import kotlin.*;
import org.jetbrains.annotations.NotNull;

public class VoiceRoomViewModel extends ViewModel {
  public static final String TAG = "VoiceRoomViewModel";
  public static final int CURRENT_SEAT_STATE_IDLE = 0;
  public static final int CURRENT_SEAT_STATE_APPLYING = 1;
  public static final int CURRENT_SEAT_STATE_ON_SEAT = 2;

  public MutableLiveData<String> toastData = new MutableLiveData<>(); // toast
  public MutableLiveData<CharSequence> chatRoomMsgData = new MutableLiveData<>(); // 聊天列表数据
  public MutableLiveData<Integer> memberCountData = new MutableLiveData<>(); // 房间人数
  public MutableLiveData<NEVoiceRoomEndReason> errorData = new MutableLiveData<>(); // 错误信息
  public MutableLiveData<Integer> currentSeatState = new MutableLiveData<>(CURRENT_SEAT_STATE_IDLE);
  public MutableLiveData<List<VoiceRoomSeat>> onSeatListData =
      new MutableLiveData<>(VoiceRoomUtils.createSeats());
  public MutableLiveData<List<VoiceRoomSeat>> applySeatListData = new MutableLiveData<>(); // 申请麦位列表
  public MutableLiveData<VoiceRoomSeatEvent> currentSeatEvent = new SingleLiveEvent<>(); // 当前操作的麦位
  public MutableLiveData<Integer> netData = new MutableLiveData<>();
  public MutableLiveData<NEVoiceRoomGiftModel> rewardData = new MutableLiveData<>();
  public MutableLiveData<Boolean> hostLeaveSeatData = new MutableLiveData<>();
  public MutableLiveData<Song> currentSongChange = new MutableLiveData<>();
  public MutableLiveData<Song> songDeletedEvent = new MutableLiveData<>();
  // mute状态（观众主动操作的）
  private boolean isMute = false;
  protected String roomUuid;
  protected Song currentSong;
  private final NEVoiceRoomListenerAdapter listener =
      new NEVoiceRoomListenerAdapter() {

        @Override
        public void onReceiveGift(@NonNull NEVoiceRoomGiftModel rewardMsg) {
          super.onReceiveGift(rewardMsg);
          rewardData.postValue(rewardMsg);
        }

        @Override
        public void onReceiveTextMessage(@NonNull NEVoiceRoomChatTextMessage message) {
          String content = message.getText();
          ALog.i(TAG, "onReceiveTextMessage :${message.fromNick}");
          chatRoomMsgData.postValue(
              ChatRoomMsgCreator.createText(
                  NEVoiceRoomUI.getInstance().getApplication(),
                  VoiceRoomUtils.isHost(message.getFromUserUuid()),
                  message.getFromNick(),
                  content));
        }

        @Override
        public void onMemberAudioMuteChanged(
            @NotNull NEVoiceRoomMember member,
            boolean mute,
            @org.jetbrains.annotations.Nullable NEVoiceRoomMember operateBy) {}

        @Override
        public void onMemberJoinRoom(@NonNull List<NEVoiceRoomMember> members) {
          for (NEVoiceRoomMember member : members) {
            ALog.d(TAG, "onMemberJoinRoom :${member.name}");
            if (!VoiceRoomUtils.isMySelf(member.getAccount())) {
              chatRoomMsgData.postValue(ChatRoomMsgCreator.createRoomEnter(member.getName()));
            }
          }
          updateRoomMemberCount();
        }

        @Override
        public void onMemberLeaveRoom(@NonNull List<NEVoiceRoomMember> members) {
          for (NEVoiceRoomMember member : members) {
            ALog.d(TAG, "onMemberLeaveRoom :$member.name");
            chatRoomMsgData.postValue(ChatRoomMsgCreator.createRoomExit(member.getName()));
          }
          updateRoomMemberCount();
        }

        @Override
        public void onSeatRequestSubmitted(int seatIndex, @NonNull String account) {
          if (seatIndex < 1) {
            return;
          }
          buildSeatEventMessage(
              account,
              String.format(getString(R.string.voiceroom_apply_micro_has_arrow), seatIndex - 1));
        }

        @Override
        public void onSeatRequestApproved(
            int seatIndex,
            @NotNull String account,
            @NotNull String operateBy,
            boolean isAutoAgree) {
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(
                    account, seatIndex, VoiceRoomSeat.Reason.ANCHOR_APPROVE_APPLY));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_already_seat));
        }

        @Override
        public void onSeatInvitationAccepted(
            int seatIndex, @NonNull String account, boolean isAutoAgree) {
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, VoiceRoomSeat.Reason.ANCHOR_INVITE));
          }
        }

        @Override
        public void onSeatRequestCancelled(int seatIndex, @NonNull String account) {
          buildSeatEventMessage(account, getString(R.string.voiceroom_apply_canceled));
        }

        @Override
        public void onSeatRequestRejected(
            int seatIndex, @NonNull String account, @NonNull String operateBy) {
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, VoiceRoomSeat.Reason.ANCHOR_DENY_APPLY));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_request_rejected));
        }

        @Override
        public void onSeatLeave(int seatIndex, @NonNull String account) {
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatState.postValue(CURRENT_SEAT_STATE_IDLE);
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, VoiceRoomSeat.Reason.LEAVE));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_down_seat));
          if (VoiceRoomUtils.isHost(account)) {
            hostLeaveSeatData.postValue(true);
          }
        }

        @Override
        public void onSeatListChanged(@NonNull List<NEVoiceRoomSeatItem> seatItems) {
          ALog.i(TAG, "onSeatListChanged seatItems =" + seatItems);
          handleSeatItemListChanged(seatItems);
          if (VoiceRoomUtils.isCurrentHost()) {
            getSeatRequestList();
          }
        }

        @Override
        public void onSeatKicked(
            int seatIndex, @NonNull String account, @NonNull String operateBy) {
          if (isCurrentUserOnSeat() && TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatState.postValue(CURRENT_SEAT_STATE_IDLE);
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, VoiceRoomSeat.Reason.ANCHOR_KICK));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_kikout_seat_by_host));
        }

        @Override
        public void onRoomEnded(@NonNull NEVoiceRoomEndReason reason) {
          errorData.postValue(reason);
        }

        @Override
        public void onRtcChannelError(int code) {
          if (code == 30015) {
            errorData.postValue(NEVoiceRoomEndReason.valueOf("END_OF_RTC"));
          }
        }
      };

  NEOrderSongListener orderSongListener =
      new NEOrderSongListener() {

        @Override
        public void onSongOrdered(Song song) {
          handleSongOrdered(song);
        }

        @Override
        public void onSongDeleted(Song song) {
          handleSongDeleted(song);
        }

        @Override
        public void onOrderedSongListChanged() {}

        @Override
        public void onSongSwitched(Song song) {
          handleSongSwitchedEvent(song);
        }

        @Override
        public void onSongStarted(Song song) {
          currentSong = song;
          currentSongChange.postValue(song);
        }

        @Override
        public void onSongPaused(Song song) {}

        @Override
        public void onSongResumed(Song song) {}
      };

  protected void handleSongOrdered(Song song) {}

  protected void handleSongDeleted(Song song) {}

  protected void handleSongSwitchedEvent(Song song) {}

  void updateRoomMemberCount() {
    memberCountData.postValue(NEVoiceRoomKit.getInstance().getAllMemberList().size());
  }

  private final NetworkUtils.NetworkStateListener networkStateListener =
      new NetworkUtils.NetworkStateListener() {
        private boolean isFirst = true;

        @Override
        public void onAvailable(NetworkInfo networkInfo) {
          if (!isFirst) {
            ALog.i(TAG, "onNetworkAvailable");
            getSeatInfo();
            getSeatRequestList();
          }
          isFirst = false;
          netData.postValue(NEVoiceRoomUIConstants.NET_AVAILABLE);
        }

        @Override
        public void onLost(NetworkInfo networkInfo) {
          ALog.i(TAG, "onNetworkUnavailable");
          isFirst = false;
          netData.postValue(NEVoiceRoomUIConstants.NET_LOST);
        }
      };

  public void initDataOnJoinRoom(String roomUuid) {
    this.roomUuid = roomUuid;
    initListeners();
    updateRoomMemberCount();
    queryPlayingSongInfo(roomUuid);
  }

  private void initListeners() {
    NEOrderSongService.INSTANCE.addListener(orderSongListener);
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(listener);
    NetworkUtils.registerNetworkStatusChangedListener(networkStateListener);
  }

  @Override
  protected void onCleared() {
    NEOrderSongService.INSTANCE.removeListener(orderSongListener);
    NetworkUtils.unregisterNetworkStatusChangedListener(networkStateListener);
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(listener);
    super.onCleared();
  }

  public void getSeatRequestList() {
    NEVoiceRoomKit.getInstance()
        .getSeatRequestList(
            new NEVoiceRoomCallback<List<NEVoiceRoomSeatRequestItem>>() {

              @Override
              public void onFailure(int code, @Nullable String msg) {}

              @Override
              public void onSuccess(
                  @Nullable List<NEVoiceRoomSeatRequestItem> neVoiceRoomSeatRequestItems) {
                if (neVoiceRoomSeatRequestItems != null) {
                  List<VoiceRoomSeat> applySeatList = new ArrayList<>();
                  for (NEVoiceRoomSeatRequestItem requestItem : neVoiceRoomSeatRequestItems) {
                    applySeatList.add(
                        new VoiceRoomSeat(
                            requestItem.getIndex(),
                            VoiceRoomSeat.Status.APPLY,
                            VoiceRoomSeat.Reason.NONE,
                            SeatUtils.getMember(requestItem.getUser())));
                  }
                  SeatHelper.getInstance().setApplySeatList(applySeatList);
                  applySeatListData.postValue(applySeatList);
                }
              }
            });
  }

  public void getSeatInfo() {
    NEVoiceRoomKit.getInstance()
        .getSeatInfo(
            new NEVoiceRoomCallback<NEVoiceRoomSeatInfo>() {

              @Override
              public void onSuccess(@Nullable NEVoiceRoomSeatInfo seatInfo) {
                if (seatInfo != null) {
                  handleSeatItemListChanged(seatInfo.getSeatItems());
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "getSeatInfo failed code = " + code + " msg = " + msg);
              }
            });
  }

  public void queryPlayingSongInfo(String roomUuid) {
    VoiceRoomService.getInstance()
        .queryPlayingSongInfo(
            new NetRequestCallback<OrderSong>() {

              @Override
              public void success(@Nullable OrderSong info) {
                ALog.i(TAG, "queryPlayingSongInfo info = " + info);
                if (info != null) {
                  Song song = new Song();
                  song.setOrderId(info.orderId);
                  song.setSongId(info.songId);
                  song.setSongName(info.songName);
                  currentSongChange.postValue(song);
                }
              }

              @Override
              public void error(int code, @Nullable String msg) {
                ALog.e(TAG, "queryPlayingSongInfo failed code = " + code + " msg = " + msg);
              }
            });
  }

  private String getString(@StringRes int resId) {
    return NEVoiceRoomUI.getInstance().getApplication().getString(resId);
  }

  public boolean isCurrentUserOnSeat() {
    return (currentSeatState.getValue() != null
        && currentSeatState.getValue() == CURRENT_SEAT_STATE_ON_SEAT);
  }

  public boolean isUserOnSeat(String account) {
    VoiceRoomSeat seat = findSeatByAccount(onSeatListData.getValue(), account);
    return seat != null && seat.isOn();
  }

  private void handleSeatItemListChanged(List<NEVoiceRoomSeatItem> seatItems) {
    if (seatItems == null) seatItems = Collections.emptyList();
    List<VoiceRoomSeat> seats = SeatUtils.transNESeatItem2VoiceRoomSeat(seatItems);
    String currentUuid = SeatUtils.getCurrentUuid();
    VoiceRoomSeat myAfterSeat = findSeatByAccount(seats, currentUuid);
    if (myAfterSeat != null && myAfterSeat.isOn()) {
      currentSeatState.postValue(CURRENT_SEAT_STATE_ON_SEAT);
    } else if (myAfterSeat != null && myAfterSeat.getStatus() == VoiceRoomSeat.Status.APPLY) {
      currentSeatState.postValue(CURRENT_SEAT_STATE_APPLYING);
    } else {
      currentSeatState.postValue(CURRENT_SEAT_STATE_IDLE);
    }
    onSeatListData.postValue(seats);
  }

  private VoiceRoomSeat findSeatByAccount(List<VoiceRoomSeat> seats, String account) {
    if (seats == null || seats.isEmpty() || account == null) return null;
    for (VoiceRoomSeat seat : seats) {
      if (seat.getMember() != null && TextUtils.equals(seat.getMember().getAccount(), account)) {
        return seat;
      }
    }
    return null;
  }

  private void buildSeatEventMessage(String account, String content) {
    String nick = SeatUtils.getMemberNick(account);
    if (!TextUtils.isEmpty(nick)) {
      chatRoomMsgData.postValue(ChatRoomMsgCreator.createSeatMessage(nick, content));
    }
  }

  public void muteMyAudio(boolean muteBySelf) {
    NEVoiceRoomKit.getInstance()
        .muteMyAudio(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "muteMyAudio success");
                if (muteBySelf) {
                  toastData.postValue(getString(R.string.voiceroom_mic_off));
                  isMute = true;
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "muteMyAudio failed,code:" + code + ",msg:" + msg);
              }
            });
  }

  public void unmuteMyAudio(boolean unmuteBySelf) {
    NEVoiceRoomKit.getInstance()
        .unmuteMyAudio(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "unmuteMyAudio success");
                if (unmuteBySelf) {
                  toastData.postValue(getString(R.string.voiceroom_mic_on));
                  isMute = false;
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "unmuteMyAudio failed,code:" + code + ",msg:" + msg);
              }
            });
  }

  public boolean isMute() {
    return isMute;
  }
}

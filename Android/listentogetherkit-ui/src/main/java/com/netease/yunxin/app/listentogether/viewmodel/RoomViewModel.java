// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.app.listentogether.viewmodel;

import android.net.*;
import android.text.*;
import androidx.annotation.*;
import androidx.annotation.Nullable;
import androidx.lifecycle.*;
import com.netease.yunxin.app.listentogether.chatroom.*;
import com.netease.yunxin.app.listentogether.model.*;
import com.netease.yunxin.app.listentogether.utils.*;
import com.netease.yunxin.kit.alog.*;
import com.netease.yunxin.kit.common.utils.*;
import com.netease.yunxin.kit.listentogether.R;
import com.netease.yunxin.kit.listentogetherkit.api.*;
import com.netease.yunxin.kit.listentogetherkit.api.model.*;
import java.util.*;
import org.jetbrains.annotations.*;

/** 房间、麦位业务逻辑 */
public class RoomViewModel extends ViewModel {
  public static final String TAG = "RoomViewModel";
  public static final int CURRENT_SEAT_STATE_IDLE = 0;
  public static final int CURRENT_SEAT_STATE_APPLYING = 1;
  public static final int CURRENT_SEAT_STATE_ON_SEAT = 2;
  public static final int NET_AVAILABLE = 0; // 网络 可用
  public static final int NET_LOST = 1; // 网络不可用
  private static final int AUDIENCE_SEAT_INDEX = 2;
  MutableLiveData<CharSequence> chatRoomMsgData = new MutableLiveData<>(); // 聊天列表数据
  MutableLiveData<Integer> memberCountData = new MutableLiveData<>(); // 房间人数
  MutableLiveData<NEVoiceRoomEndReason> errorData = new MutableLiveData<>(); // 错误信息
  MutableLiveData<Integer> currentSeatState = new MutableLiveData<>(CURRENT_SEAT_STATE_IDLE);
  MutableLiveData<List<VoiceRoomSeat>> onSeatListData =
      new MutableLiveData<>(ListenTogetherUtils.createSeats());
  MutableLiveData<SeatEvent> currentSeatEvent = new SingleLiveEvent<>(); // 当前操作的麦位
  MutableLiveData<Integer> netData = new MutableLiveData<>();
  public MutableLiveData<NEListenTogetherRoomGiftModel> rewardData = new MutableLiveData<>();
  private final NEListenTogetherRoomListenerAdapter listener =
      new NEListenTogetherRoomListenerAdapter() {

        @Override
        public void onReceiveGift(@NonNull NEListenTogetherRoomGiftModel rewardMsg) {
          super.onReceiveGift(rewardMsg);
          rewardData.postValue(rewardMsg);
        }

        @Override
        public void onReceiveTextMessage(@NonNull NEListenTogetherRoomChatTextMessage message) {
          String content = message.getText();
          ALog.i(TAG, "onReceiveTextMessage :${message.fromNick}");
          chatRoomMsgData.postValue(
              ChatRoomMsgCreator.createText(
                  Utils.getApp(),
                  ListenTogetherUtils.isHost(message.getFromUserUuid()),
                  message.getFromNick(),
                  content));
        }

        @Override
        public void onMemberAudioMuteChanged(
            @NotNull NEListenTogetherRoomMember member,
            boolean mute,
            @org.jetbrains.annotations.Nullable NEListenTogetherRoomMember operateBy) {}

        @Override
        public void onMemberJoinRoom(@NonNull List<NEListenTogetherRoomMember> members) {
          for (NEListenTogetherRoomMember member : members) {
            ALog.d(TAG, "onMemberJoinRoom :" + member.getName());
            if (!ListenTogetherUtils.isMySelf(member.getAccount())) {
              chatRoomMsgData.postValue(ChatRoomMsgCreator.createRoomEnter(member.getName()));
            }
          }
          updateRoomMemberCount();
        }

        @Override
        public void onMemberLeaveRoom(@NonNull List<NEListenTogetherRoomMember> members) {
          for (NEListenTogetherRoomMember member : members) {
            ALog.d(TAG, "onMemberLeaveRoom :" + member.getName());
            chatRoomMsgData.postValue(ChatRoomMsgCreator.createRoomExit(member.getName()));
          }
          updateRoomMemberCount();
        }

        @Override
        public void onMemberJoinChatroom(@NonNull List<NEListenTogetherRoomMember> members) {
          if (ListenTogetherUtils.isCurrentHost() && !members.isEmpty()) {
            NEListenTogetherKit.getInstance()
                .sendSeatInvitation(AUDIENCE_SEAT_INDEX, members.get(0).getAccount(), null);
          }
        }

        @Override
        public void onMemberLeaveChatroom(@NonNull List<NEListenTogetherRoomMember> members) {}

        @Override
        public void onSeatLeave(int seatIndex, @NonNull String account) {
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatState.postValue(CURRENT_SEAT_STATE_IDLE);
            currentSeatEvent.postValue(
                new SeatEvent(account, seatIndex, VoiceRoomSeat.Reason.LEAVE));
          }
          buildSeatEventMessage(account, getString(R.string.listen_down_seat));
        }

        @Override
        public void onSeatListChanged(@NonNull List<NEListenTogetherRoomSeatItem> seatItems) {
          ALog.i(TAG, "onSeatListChanged seatItems" + seatItems);
          handleSeatItemListChanged(seatItems);
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

  public MutableLiveData<Integer> getNetData() {
    return netData;
  }

  public MutableLiveData<CharSequence> getChatRoomMsgData() {
    return chatRoomMsgData;
  }

  public MutableLiveData<Integer> getMemberCountData() {
    return memberCountData;
  }

  public MutableLiveData<NEVoiceRoomEndReason> getErrorData() {
    return errorData;
  }

  public MutableLiveData<Integer> getCurrentSeatState() {
    return currentSeatState;
  }

  public MutableLiveData<List<VoiceRoomSeat>> getOnSeatListData() {
    return onSeatListData;
  }

  public LiveData<SeatEvent> getCurrentSeatEvent() {
    return currentSeatEvent;
  }

  void updateRoomMemberCount() {
    memberCountData.postValue(NEListenTogetherKit.getInstance().getAllMemberList().size());
  }

  private NetworkUtils.NetworkStateListener networkStateListener =
      new NetworkUtils.NetworkStateListener() {
        private boolean isFirst = true;

        @Override
        public void onAvailable(NetworkInfo networkInfo) {
          if (!isFirst) {
            ALog.i(TAG, "onNetworkAvailable");
            getSeatInfo();
          }
          isFirst = false;
          netData.postValue(NET_AVAILABLE);
        }

        @Override
        public void onLost(NetworkInfo networkInfo) {
          ALog.i(TAG, "onNetworkUnavailable");
          isFirst = false;
          netData.postValue(NET_LOST);
        }
      };

  public void initDataOnJoinRoom() {
    NEListenTogetherKit.getInstance().addRoomListener(listener);
    updateRoomMemberCount();
    NetworkUtils.registerNetworkStatusChangedListener(networkStateListener);
  }

  @Override
  protected void onCleared() {
    super.onCleared();
    NetworkUtils.unregisterNetworkStatusChangedListener(networkStateListener);
    NEListenTogetherKit.getInstance().removeRoomListener(listener);
  }

  public void getSeatInfo() {
    NEListenTogetherKit.getInstance()
        .getSeatInfo(
            new NEListenTogetherCallback<NEListenTogetherRoomSeatInfo>() {

              @Override
              public void onSuccess(@Nullable NEListenTogetherRoomSeatInfo seatInfo) {
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

  private String getString(@StringRes int resId) {
    return Utils.getApp().getString(resId);
  }

  public boolean isCurrentUserOnSeat() {
    return currentSeatState.getValue() == CURRENT_SEAT_STATE_ON_SEAT;
  }

  private void handleSeatItemListChanged(List<NEListenTogetherRoomSeatItem> seatItems) {
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
    if (!shouldShowSeatEventMessage(account)) return;
    String nick = SeatUtils.getMemberNick(account);
    if (!TextUtils.isEmpty(nick)) {
      chatRoomMsgData.postValue(ChatRoomMsgCreator.createSeatMessage(nick, content));
    }
  }

  private boolean shouldShowSeatEventMessage(String account) {
    return ListenTogetherUtils.isMySelf(account) || ListenTogetherUtils.isCurrentHost();
  }
}

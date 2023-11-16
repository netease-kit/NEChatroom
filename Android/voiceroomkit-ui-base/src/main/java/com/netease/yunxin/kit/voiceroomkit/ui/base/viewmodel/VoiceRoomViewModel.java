// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel;

import android.annotation.SuppressLint;
import android.text.TextUtils;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.network.NetRequestCallback;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.copyrightedmedia.api.SongScene;
import com.netease.yunxin.kit.entertainment.common.livedata.SingleLiveEvent;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.utils.NetUtils;
import com.netease.yunxin.kit.entertainment.common.utils.SeatUtils;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongListener;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.model.OrderSong;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomOptions;
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomParams;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAudioOutputDevice;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomEndReason;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomRole;
import com.netease.yunxin.kit.voiceroomkit.api.model.*;
import com.netease.yunxin.kit.voiceroomkit.ui.base.NEVoiceRoomUI;
import com.netease.yunxin.kit.voiceroomkit.ui.base.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.chatroom.ChatRoomMsgCreator;
import com.netease.yunxin.kit.voiceroomkit.ui.base.helper.SeatHelper;
import com.netease.yunxin.kit.voiceroomkit.ui.base.model.MemberAudioBannedModel;
import com.netease.yunxin.kit.voiceroomkit.ui.base.model.MemberAudioMuteChangedModel;
import com.netease.yunxin.kit.voiceroomkit.ui.base.model.VoiceRoomSeatEvent;
import com.netease.yunxin.kit.voiceroomkit.ui.base.service.VoiceRoomService;
import com.netease.yunxin.kit.voiceroomkit.ui.base.utils.VoiceRoomUILog;
import java.util.ArrayList;
import java.util.List;
import kotlin.*;
import org.jetbrains.annotations.NotNull;

public class VoiceRoomViewModel extends ViewModel {
  public static final String TAG = "VoiceRoomViewModel";

  public static final int VOLUME_INDICATION_INTERVAL = 1000;

  public static final int ANCHOR_SEAT_INDEX = 1;
  public static final int CURRENT_SEAT_STATE_IDLE = 0;
  public static final int CURRENT_SEAT_STATE_APPLYING = 1;
  public static final int CURRENT_SEAT_STATE_ON_SEAT = 2;

  public MutableLiveData<String> toastData = new MutableLiveData<>(); // toast
  public MutableLiveData<CharSequence> chatRoomMsgData = new MutableLiveData<>(); // 聊天列表数据
  public MutableLiveData<Integer> memberCountData = new MutableLiveData<>(); // 房间人数

  public MutableLiveData<Integer> anchorReward = new MutableLiveData<>(); // 主播金币数量
  public MutableLiveData<NEVoiceRoomEndReason> roomEndData = new MutableLiveData<>();
  public MutableLiveData<Integer> roomRtcErrorData = new MutableLiveData<>();
  public MutableLiveData<Integer> currentSeatState = new MutableLiveData<>(CURRENT_SEAT_STATE_IDLE);
  public MutableLiveData<List<RoomSeat>> onSeatListData =
      new MutableLiveData<>(VoiceRoomUtils.createSeats());
  public MutableLiveData<List<RoomSeat>> applySeatListData = new MutableLiveData<>(); // 申请麦位列表
  public MutableLiveData<VoiceRoomSeatEvent> currentSeatEvent = new SingleLiveEvent<>(); // 当前操作的麦位
  public MutableLiveData<Integer> netData = new MutableLiveData<>();

  public MutableLiveData<NEVoiceRoomBatchGiftModel> bachRewardData = new MutableLiveData<>();
  public MutableLiveData<Boolean> hostLeaveSeatData = new MutableLiveData<>();
  public MutableLiveData<Song> currentSongChange = new MutableLiveData<>();
  public MutableLiveData<Song> songDeletedEvent = new MutableLiveData<>();

  public MutableLiveData<List<? extends NEVoiceRoomMemberVolumeInfo>>
      rtcRemoteAudioVolumeIndicationData = new MutableLiveData<>();
  public MutableLiveData<Integer> rtcLocalAudioVolumeIndicationData = new MutableLiveData<>();

  public MutableLiveData<MemberAudioBannedModel> memberAudioBannedData = new MutableLiveData<>();

  public MutableLiveData<MemberAudioMuteChangedModel> memberAudioMuteChangedData =
      new MutableLiveData<>();

  public MutableLiveData<NEVoiceRoomMember> localMemberData = new MutableLiveData<>();

  public MutableLiveData<Boolean> earBackData = new MutableLiveData<>();
  public MutableLiveData<Boolean> selfJoinChatroomLiveData = new MutableLiveData<>();
  public MutableLiveData<NEVoiceRoomInfo> roomInfoLiveData = new MutableLiveData<>();

  // mute状态（观众主动操作的）
  private boolean isMute = false;
  protected String roomUuid;
  protected Song currentSong;

  private Long liveRecordId;
  private NEVoiceRoomInfo roomInfo;

  private List<RoomSeat> roomSeats;
  private final NEVoiceRoomListenerAdapter listener =
      new NEVoiceRoomListenerAdapter() {
        @Override
        public void onReceiveBatchGift(@NonNull NEVoiceRoomBatchGiftModel giftModel) {
          ALog.i(TAG, "onReceiveBatchGift giftModel:" + giftModel);
          bachRewardData.setValue(giftModel);
          updateRoomInfoReward(giftModel.getSeatUserReward());
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
            @org.jetbrains.annotations.Nullable NEVoiceRoomMember operateBy) {
          memberAudioMuteChangedData.postValue(new MemberAudioMuteChangedModel(member, mute));
          onSeatListData.postValue(roomSeats);
        }

        @Override
        public void onMemberJoinRoom(@NonNull List<NEVoiceRoomMember> members) {
          for (NEVoiceRoomMember member : members) {
            ALog.d(TAG, "onMemberJoinRoom :${member.name}");
            if (!VoiceRoomUtils.isLocal(member.getAccount())) {
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
        public void onMemberJoinChatroom(@NonNull List<NEVoiceRoomMember> members) {
          super.onMemberJoinChatroom(members);
          for (NEVoiceRoomMember member : members) {
            if (NEVoiceRoomKit.getInstance().getLocalMember() != null
                && NEVoiceRoomKit.getInstance()
                    .getLocalMember()
                    .getAccount()
                    .equals(member.getAccount())) {
              selfJoinChatroomLiveData.postValue(true);
              break;
            }
          }
        }

        @Override
        public void onSeatRequestSubmitted(int seatIndex, @NonNull String account) {
          if (seatIndex < 1) {
            buildSeatEventMessage(account, getString(R.string.voiceroom_apply_micro_has_arrow));
          } else {
            buildSeatEventMessage(
                account,
                String.format(getString(R.string.voiceroom_apply_micro_has_arrow), seatIndex - 1));
          }
          getSeatRequestList();
        }

        @Override
        public void onSeatRequestApproved(
            int seatIndex,
            @NotNull String account,
            @NotNull String operateBy,
            boolean isAutoAgree) {
          updateAllInfo();
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, RoomSeat.Reason.ANCHOR_APPROVE_APPLY));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_already_seat));
        }

        @Override
        public void onSeatInvitationAccepted(
            int seatIndex, @NonNull String account, boolean isAutoAgree) {
          updateAllInfo();
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, RoomSeat.Reason.ANCHOR_INVITE));
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
                new VoiceRoomSeatEvent(account, seatIndex, RoomSeat.Reason.ANCHOR_DENY_APPLY));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_request_rejected));
        }

        @Override
        public void onSeatLeave(int seatIndex, @NonNull String account) {
          if (TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatState.postValue(CURRENT_SEAT_STATE_IDLE);
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, RoomSeat.Reason.LEAVE));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_down_seat));
          if (VoiceRoomUtils.isHost(account)) {
            hostLeaveSeatData.postValue(true);
          }
        }

        @Override
        public void onSeatListChanged(@NonNull List<NEVoiceRoomSeatItem> seatItems) {
          ALog.i(TAG, "onSeatListChanged seatItems =" + seatItems);
          roomSeats = SeatUtils.transNESeatItem2VoiceRoomSeat(seatItems);
          handleSeatItemListChanged();
          if (VoiceRoomUtils.isLocalAnchor()) {
            getSeatRequestList();
          }
        }

        @Override
        public void onSeatKicked(
            int seatIndex, @NonNull String account, @NonNull String operateBy) {
          if (isCurrentUserOnSeat() && TextUtils.equals(account, SeatUtils.getCurrentUuid())) {
            currentSeatState.postValue(CURRENT_SEAT_STATE_IDLE);
            currentSeatEvent.postValue(
                new VoiceRoomSeatEvent(account, seatIndex, RoomSeat.Reason.ANCHOR_KICK));
          }
          buildSeatEventMessage(account, getString(R.string.voiceroom_kikout_seat_by_host));
        }

        @Override
        public void onRoomEnded(@NonNull NEVoiceRoomEndReason reason) {
          roomEndData.postValue(reason);
        }

        @Override
        public void onRtcChannelError(int code) {
          roomRtcErrorData.postValue(code);
        }

        @Override
        public void onRtcLocalAudioVolumeIndication(int volume, boolean vadFlag) {
          rtcLocalAudioVolumeIndicationData.postValue(volume);
        }

        @Override
        public void onRtcRemoteAudioVolumeIndication(
            @NonNull List<? extends NEVoiceRoomMemberVolumeInfo> volumes, int totalVolume) {
          rtcRemoteAudioVolumeIndicationData.postValue(volumes);
        }

        @SuppressLint("NotifyDataSetChanged")
        @Override
        public void onMemberAudioBanned(@NonNull NEVoiceRoomMember member, boolean banned) {
          memberAudioBannedData.postValue(new MemberAudioBannedModel(member, banned));
          onSeatListData.postValue(roomSeats);
        }

        @Override
        public void onAudioOutputDeviceChanged(@NonNull NEVoiceRoomAudioOutputDevice device) {
          VoiceRoomUILog.i(TAG, "onAudioOutputDeviceChanged device = " + device);
          if (device != NEVoiceRoomAudioOutputDevice.BLUETOOTH_HEADSET
              && device != NEVoiceRoomAudioOutputDevice.WIRED_HEADSET) {
            earBackData.postValue(false);
          }
        }
      };

  private void updateRoomInfoReward(List<NEVoiceRoomBatchSeatUserReward> seatUserRewards) {
    roomInfo.getLiveModel().setSeatUserReward(seatUserRewards);
    updateAnchorRewardInfo();
    updateSeatWithRewardInfo();
  }

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

        @Override
        public void onConnected(NetworkUtils.NetworkType networkType) {
          if (!isFirst) {
            ALog.i(TAG, "onNetworkAvailable");
            updateAllInfo();
          }
          isFirst = false;
          netData.postValue(NEVoiceRoomUIConstants.NET_AVAILABLE);
        }

        @Override
        public void onDisconnected() {
          ALog.i(TAG, "onNetworkUnavailable");
          isFirst = false;
          netData.postValue(NEVoiceRoomUIConstants.NET_LOST);
        }

        private boolean isFirst = true;
      };

  public void initDataOnJoinRoom() {
    initListeners();
    updateRoomMemberCount();
    queryPlayingSongInfo();
    getSeatRequestList();
    NEVoiceRoomKit.getInstance().enableAudioVolumeIndication(true, VOLUME_INDICATION_INTERVAL);

    if (VoiceRoomUtils.isLocalAnchor()) {
      NEVoiceRoomKit.getInstance().submitSeatRequest(ANCHOR_SEAT_INDEX, true, null);
    }
    localMemberData.postValue(VoiceRoomUtils.getLocalMember());
    updateAllInfo();
  }

  private void initListeners() {
    NEOrderSongService.INSTANCE.addListener(orderSongListener);
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(listener);
    NetUtils.registerStateListener(networkStateListener);
  }

  @Override
  protected void onCleared() {
    NEOrderSongService.INSTANCE.removeListener(orderSongListener);
    NetUtils.unregisterStateListener(networkStateListener);
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(listener);
    NEVoiceRoomKit.getInstance().enableAudioVolumeIndication(false, VOLUME_INDICATION_INTERVAL);
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
                  List<RoomSeat> applySeatList = new ArrayList<>();
                  for (NEVoiceRoomSeatRequestItem requestItem : neVoiceRoomSeatRequestItems) {
                    if (VoiceRoomUtils.isHost(requestItem.getUser())) {
                      continue;
                    }
                    applySeatList.add(
                        new RoomSeat(
                            requestItem.getIndex(),
                            RoomSeat.Status.APPLY,
                            RoomSeat.Reason.NONE,
                            SeatUtils.getMember(requestItem.getUser()),
                            VoiceRoomUtils.getRewardFromRoomInfo(requestItem.getUser(), roomInfo)));
                  }
                  SeatHelper.getInstance().setApplySeatList(applySeatList);
                  applySeatListData.postValue(applySeatList);
                }
              }
            });
  }

  public void init(long liveRecordId, String roomUuid) {
    this.liveRecordId = liveRecordId;
    this.roomUuid = roomUuid;
    updateRoomInfo(null);
  }

  public void joinRoom(
      String roomUuid,
      String nick,
      String avatar,
      String role,
      NEVoiceRoomCallback<NEVoiceRoomInfo> callback) {
    NEJoinVoiceRoomParams params =
        new NEJoinVoiceRoomParams(
            roomUuid, nick, avatar, NEVoiceRoomRole.Companion.fromValue(role), liveRecordId, null);
    NEJoinVoiceRoomOptions options = new NEJoinVoiceRoomOptions();
    NEVoiceRoomKit.getInstance()
        .joinRoom(
            params,
            options,
            new NEVoiceRoomCallback<NEVoiceRoomInfo>() {

              @Override
              public void onSuccess(@Nullable NEVoiceRoomInfo roomInfo) {
                ALog.i(TAG, "joinRoom success");
                NEOrderSongService.INSTANCE.setSongScene(SongScene.TYPE_LISTENING_TO_MUSIC);
                VoiceRoomViewModel.this.roomInfo = roomInfo;
                initDataOnJoinRoom();
                if (callback != null) {
                  callback.onSuccess(roomInfo);
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "joinRoom failed code = " + code + " msg = " + msg);
                if (callback != null) {
                  callback.onFailure(code, msg);
                }
              }
            });
  }

  /** 更新场景：1、断网重连；2、上麦的时候（礼物值的信息需要在房间信息中获取） */
  private void updateAllInfo() {
    updateRoomInfo(
        new NEVoiceRoomCallback<NEVoiceRoomInfo>() {

          @Override
          public void onSuccess(@Nullable NEVoiceRoomInfo roomInfo) {
            VoiceRoomViewModel.this.roomInfo = roomInfo;
            updateAnchorRewardInfo();
            getSeatInfo();
            getSeatRequestList();
          }

          @Override
          public void onFailure(int code, @Nullable String msg) {}
        });
  }

  private void updateRoomInfo(NEVoiceRoomCallback<NEVoiceRoomInfo> callback) {
    NEVoiceRoomKit.getInstance()
        .getRoomInfo(
            liveRecordId,
            new NEVoiceRoomCallback<NEVoiceRoomInfo>() {

              @Override
              public void onSuccess(@Nullable NEVoiceRoomInfo roomInfo) {
                ALog.i(TAG, "getRoomInfo success");
                if (callback != null) {
                  callback.onSuccess(roomInfo);
                }
                roomInfoLiveData.setValue(roomInfo);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.i(TAG, "getRoomInfo error code = " + code + ", msg = " + msg);
                if (callback != null) {
                  callback.onFailure(code, msg);
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
                  roomSeats = SeatUtils.transNESeatItem2VoiceRoomSeat(seatInfo.getSeatItems());
                  handleSeatItemListChanged();
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "getSeatInfo failed code = " + code + " msg = " + msg);
              }
            });
  }

  public void queryPlayingSongInfo() {
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
                  song.setChannel(info.channel);
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
    RoomSeat seat = findSeatByAccount(onSeatListData.getValue(), account);
    return seat != null && seat.isOn();
  }

  private void handleSeatItemListChanged() {
    String currentUuid = SeatUtils.getCurrentUuid();
    RoomSeat myAfterSeat = findSeatByAccount(roomSeats, currentUuid);
    if (myAfterSeat != null && myAfterSeat.isOn()) {
      currentSeatState.postValue(CURRENT_SEAT_STATE_ON_SEAT);
    } else if (myAfterSeat != null && myAfterSeat.getStatus() == RoomSeat.Status.APPLY) {
      currentSeatState.postValue(CURRENT_SEAT_STATE_APPLYING);
    } else {
      currentSeatState.postValue(CURRENT_SEAT_STATE_IDLE);
    }
    updateSeatWithRewardInfo();
  }

  private void updateAnchorRewardInfo() {
    anchorReward.postValue(VoiceRoomUtils.getAnchorReward(roomInfo));
  }

  private void updateSeatWithRewardInfo() {
    for (RoomSeat seat : roomSeats) {
      seat.setRewardTotal(VoiceRoomUtils.getRewardFromRoomInfo(seat.getAccount(), roomInfo));
    }
    onSeatListData.postValue(roomSeats);
  }

  private RoomSeat findSeatByAccount(List<RoomSeat> seats, String account) {
    if (seats == null || seats.isEmpty() || account == null) return null;
    for (RoomSeat seat : seats) {
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

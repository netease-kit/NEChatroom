// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.base.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.base.activity.VoiceRoomBaseActivity;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.utils.FloatPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.AudienceVoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.VoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.constant.VoiceRoomUIConstant;
import java.util.Arrays;
import java.util.List;

/** 观众页 */
public class VoiceRoomAudienceActivity extends VoiceRoomBaseActivity {

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ivGift.setVisibility(View.VISIBLE);
    ivOrderSong.setVisibility(View.GONE);
  }

  @Override
  protected VoiceRoomViewModel getRoomViewModel() {
    return new ViewModelProvider(this).get(AudienceVoiceRoomViewModel.class);
  }

  @Override
  protected void setupBaseView() {
    updateAudioSwitchVisible(false);
  }

  @Override
  protected void initDataObserver() {
    super.initDataObserver();
    roomViewModel.applySeatListData.observe(this, this::onApplySeats);
    roomViewModel.currentSeatEvent.observe(
        this,
        event -> {
          ALog.d(TAG, "initDataObserver currentSeatEvent,event:" + event);
          switch (event.getReason()) {
            case RoomSeat.Reason.ANCHOR_INVITE:
            case RoomSeat.Reason.ANCHOR_APPROVE_APPLY:
              onEnterSeat(event, false);
              break;
            case RoomSeat.Reason.ANCHOR_DENY_APPLY:
              onSeatApplyDenied(false);
              break;
            case RoomSeat.Reason.LEAVE:
              onLeaveSeat(event, true);
              break;
            case RoomSeat.Reason.ANCHOR_KICK:
              onLeaveSeat(event, false);
              break;
          }
        });

    roomViewModel.hostLeaveSeatData.observe(
        this,
        new Observer<Boolean>() {
          @Override
          public void onChanged(Boolean aBoolean) {
            if (aBoolean) {
              leaveRoom();
            }
          }
        });

    roomViewModel.currentSongChange.observe(
        this,
        song -> {
          tvBackgroundMusic.startPlay(song, false);
        });

    roomViewModel.songDeletedEvent.observe(
        this,
        song -> {
          tvBackgroundMusic.deleteSong(song);
        });
  }

  @Override
  public void onApplySeats(List<RoomSeat> roomSeats) {
    if (isContainLocalAccount(roomSeats)) {
      showApplySeatDialog();
    }
  }

  private boolean isContainLocalAccount(List<RoomSeat> roomSeats) {
    for (RoomSeat roomSeat : roomSeats) {
      if (roomSeat != null
          && TextUtils.equals(roomSeat.getAccount(), VoiceRoomUtils.getLocalAccount())) {
        return true;
      }
    }
    return false;
  }

  @Override
  public void onClickSmallWindow() {
    Intent intent = new Intent();
    intent.setClass(VoiceRoomAudienceActivity.this, VoiceRoomAudienceActivity.class);
    intent.putExtra(NEVoiceRoomUIConstants.ENV_KEY, isOverSeaEnv);
    intent.putExtra(NEVoiceRoomUIConstants.NEED_JOIN_ROOM__KEY, false);
    intent.putExtra(RoomConstants.INTENT_ROOM_MODEL, voiceRoomInfo);
    FloatPlayManager.getInstance()
        .startFloatPlay(VoiceRoomAudienceActivity.this, voiceRoomInfo, intent);
  }

  protected void createMoreItems() {
    moreItems =
        Arrays.asList(
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_MICRO_PHONE,
                com.netease
                    .yunxin
                    .kit
                    .voiceroomkit
                    .ui
                    .base
                    .R
                    .drawable
                    .selector_more_micro_phone_status,
                getString(com.netease.yunxin.kit.voiceroomkit.ui.base.R.string.voiceroom_mic)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_EAR_BACK,
                com.netease
                    .yunxin
                    .kit
                    .voiceroomkit
                    .ui
                    .base
                    .R
                    .drawable
                    .selector_more_ear_back_status,
                getString(com.netease.yunxin.kit.voiceroomkit.ui.base.R.string.voiceroom_earback)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_MIXER,
                com.netease.yunxin.kit.voiceroomkit.ui.base.R.drawable.icon_room_more_mixer,
                getString(com.netease.yunxin.kit.voiceroomkit.ui.base.R.string.voiceroom_mixer)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_REPORT,
                com.netease.yunxin.kit.voiceroomkit.ui.base.R.drawable.icon_room_more_report,
                getString(com.netease.yunxin.kit.voiceroomkit.ui.base.R.string.voiceroom_report)));
  }

  @Override
  protected boolean isAnchor() {
    return false;
  }

  @Override
  protected String getPageName() {
    return VoiceRoomUIConstant.TAG_REPORT_PAGE_VOICE_ROOM;
  }
}

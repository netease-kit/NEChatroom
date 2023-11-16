// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.activity;

import android.content.Intent;
import androidx.lifecycle.ViewModelProvider;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.base.activity.VoiceRoomBaseActivity;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.ChoiceDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.utils.FloatPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.AnchorVoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.VoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.constant.VoiceRoomUIConstant;
import java.util.Arrays;

/** 主播页 */
public class VoiceRoomAnchorActivity extends VoiceRoomBaseActivity {

  @Override
  protected VoiceRoomViewModel getRoomViewModel() {
    return new ViewModelProvider(this).get(AnchorVoiceRoomViewModel.class);
  }

  @Override
  protected void initDataObserver() {
    super.initDataObserver();
    roomViewModel.applySeatListData.observe(this, this::onApplySeats);
    roomViewModel.currentSongChange.observe(
        this,
        song -> {
          tvBackgroundMusic.startPlay(song, true);
        });
    roomViewModel.songDeletedEvent.observe(
        this,
        song -> {
          tvBackgroundMusic.deleteSong(song);
        });
  }

  protected void createMoreItems() {
    moreItems =
        Arrays.asList(
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_MICRO_PHONE,
                R.drawable.selector_more_micro_phone_status,
                getString(R.string.voiceroom_mic)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_EAR_BACK,
                R.drawable.selector_more_ear_back_status,
                getString(R.string.voiceroom_earback)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_MIXER,
                R.drawable.icon_room_more_mixer,
                getString(R.string.voiceroom_mixer)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_AUDIO,
                R.drawable.icon_room_more_audio,
                getString(R.string.voiceroom_audio_effect)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_REPORT,
                R.drawable.icon_room_more_report,
                getString(R.string.voiceroom_report)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_FINISH,
                R.drawable.icon_room_more_finish,
                getString(R.string.voiceroom_end)));
  }

  @Override
  protected boolean isAnchor() {
    return true;
  }

  @Override
  protected String getPageName() {
    return VoiceRoomUIConstant.TAG_REPORT_PAGE_VOICE_ROOM;
  }

  @Override
  public void onClickSmallWindow() {
    Intent intent = new Intent();
    intent.setClass(VoiceRoomAnchorActivity.this, VoiceRoomAnchorActivity.class);
    intent.putExtra(NEVoiceRoomUIConstants.ENV_KEY, isOverSeaEnv);
    intent.putExtra(NEVoiceRoomUIConstants.NEED_JOIN_ROOM__KEY, false);
    intent.putExtra(RoomConstants.INTENT_ROOM_MODEL, voiceRoomInfo);
    FloatPlayManager.getInstance()
        .startFloatPlay(VoiceRoomAnchorActivity.this, voiceRoomInfo, intent);
  }

  @Override
  protected void doLeaveRoom() {
    new ChoiceDialog(VoiceRoomAnchorActivity.this)
        .setTitle(getString(R.string.voiceroom_end_live_title))
        .setContent(getString(R.string.voiceroom_end_live_tips))
        .setNegative(getString(R.string.voiceroom_cancel), null)
        .setPositive(
            getString(R.string.voiceroom_sure),
            v -> onSeatAction(null, getString(R.string.voiceroom_leave_room)))
        .show();
  }

  @Override
  protected void setupBaseView() {}
}

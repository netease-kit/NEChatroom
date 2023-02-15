// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.activity;

import android.os.Bundle;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import com.netease.yunxin.app.listentogether.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.app.listentogether.model.SeatEvent;
import com.netease.yunxin.app.listentogether.model.VoiceRoomSeat;
import com.netease.yunxin.app.listentogether.viewmodel.RoomViewModel;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.listentogether.R;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import java.util.Arrays;
import java.util.List;

/** 观众页 */
public class ListenTogetherAudienceActivity extends ListenTogetherBaseActivity {
  private List<ChatRoomMoreDialog.MoreItem> moreItems;

  @Override
  protected int getContentViewID() {
    return R.layout.listen_activity_audience;
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    createMoreItems();
    super.onCreate(savedInstanceState);
    netErrorView = findViewById(R.id.view_net_error);
    watchNetWork();
    initDataObserver();
    isAnchor = false;
  }

  private void createMoreItems() {
    moreItems =
        Arrays.asList(
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_MICRO_PHONE,
                R.drawable.listen_selector_more_micro_phone_status,
                getString(R.string.listen_mic)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_EAR_BACK,
                R.drawable.listen_selector_more_ear_back_status,
                getString(R.string.listen_earback)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_MIXER,
                R.drawable.listen_icon_room_more_mixer,
                getString(R.string.listen_mixer)));
  }

  private void initDataObserver() {
    roomViewModel
        .getCurrentSeatEvent()
        .observe(
            this,
            event -> {
              ALog.d(TAG, "initDataObserver currentSeatEvent,event:" + event);
              switch (event.getReason()) {
                case VoiceRoomSeat.Reason.ANCHOR_INVITE:
                case VoiceRoomSeat.Reason.ANCHOR_APPROVE_APPLY:
                  onEnterSeat(event, false);
                  break;
              }
            });
    roomViewModel
        .getCurrentSeatState()
        .observe(
            this,
            new Observer<Integer>() {
              @Override
              public void onChanged(Integer integer) {
                ALog.d(TAG, "initDataObserver currentSeatState,integer:" + integer);
                updateAudioSwitchVisible(integer == RoomViewModel.CURRENT_SEAT_STATE_ON_SEAT);
                if (roomViewModel.isCurrentUserOnSeat()) {
                  //                  NEVoiceRoomKit.getInstance().unmuteMyAudio(null);
                  unmuteMyAudio(null);
                }
              }
            });
  }

  private void watchNetWork() {
    roomViewModel
        .getNetData()
        .observe(
            this,
            state -> {
              if (state == RoomViewModel.NET_AVAILABLE) { // 网可用
                onNetAvailable();
              } else { // 不可用
                onNetLost();
              }
            });
  }

  @Override
  protected void setupBaseView() {
    more.setVisibility(View.GONE);
    updateAudioSwitchVisible(false);
  }

  private void updateAudioSwitchVisible(boolean visible) {
    ivLocalAudioSwitch.setVisibility(visible ? View.VISIBLE : View.GONE);
    more.setVisibility(visible ? View.VISIBLE : View.GONE);
    moreItems.get(MORE_ITEM_MICRO_PHONE).setVisible(visible);
    moreItems.get(MORE_ITEM_EAR_BACK).setVisible(visible);
    moreItems.get(MORE_ITEM_MIXER).setVisible(visible);
  }

  @NonNull
  @Override
  protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
    boolean isAudioOn = NEListenTogetherKit.getInstance().getLocalMember().isAudioOn();
    moreItems.get(MORE_ITEM_MICRO_PHONE).setEnable(isAudioOn);
    moreItems
        .get(MORE_ITEM_EAR_BACK)
        .setEnable(NEListenTogetherKit.getInstance().isEarbackEnable());
    return moreItems;
  }

  @Override
  protected ChatRoomMoreDialog.OnItemClickListener getMoreItemClickListener() {
    return onMoreItemClickListener;
  }

  public void onEnterSeat(SeatEvent event, boolean last) {
    updateAudioSwitchVisible(true);
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.activity;

import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.listentogether.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.app.listentogether.dialog.ChoiceDialog;
import com.netease.yunxin.app.listentogether.dialog.TopTipsDialog;
import com.netease.yunxin.app.listentogether.viewmodel.RoomViewModel;
import com.netease.yunxin.kit.listentogether.R;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import java.util.Arrays;
import java.util.List;

/** 主播页 */
public class ListenTogetherAnchorActivity extends ListenTogetherBaseActivity {

  private List<ChatRoomMoreDialog.MoreItem> moreItems;

  @Override
  protected int getContentViewID() {
    return R.layout.listen_activity_live;
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    netErrorView = findViewById(R.id.view_net_error);
    createMoreItems();
    audioPlay.checkMusicFiles();
    watchNetWork();
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
                getString(R.string.listen_mixer)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_AUDIO,
                R.drawable.listen_icon_room_more_audio,
                getString(R.string.listen_mixing)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_FINISH,
                R.drawable.listen_icon_room_more_finish,
                getString(R.string.listen_end)));
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
    topTipsDialog = new TopTipsDialog();
  }

  @Override
  protected void doLeaveRoom() {
    new ChoiceDialog(ListenTogetherAnchorActivity.this)
        .setTitle(getString(R.string.listen_end_live_title))
        .setContent(getString(R.string.listen_end_live_tips))
        .setNegative(getString(R.string.listen_cancel), null)
        .setPositive(getString(R.string.listen_sure), v -> leaveRoom())
        .show();
  }

  @Override
  public void onBackPressed() {
    new ChoiceDialog(ListenTogetherAnchorActivity.this)
        .setTitle(getString(R.string.listen_end_live_title))
        .setContent(getString(R.string.listen_end_live_tips))
        .setNegative(getString(R.string.listen_cancel), null)
        .setPositive(getString(R.string.listen_sure), v -> super.onBackPressed())
        .show();
  }

  @NonNull
  @Override
  protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
    moreItems
        .get(MORE_ITEM_MICRO_PHONE)
        .setEnable(NEListenTogetherKit.getInstance().getLocalMember().isAudioOn());
    moreItems
        .get(MORE_ITEM_EAR_BACK)
        .setEnable(NEListenTogetherKit.getInstance().isEarbackEnable());
    return moreItems;
  }
}

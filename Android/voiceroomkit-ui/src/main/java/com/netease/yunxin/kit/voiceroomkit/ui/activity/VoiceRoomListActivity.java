// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.activity.RoomListActivity;
import com.netease.yunxin.kit.entertainment.common.adapter.RoomListAdapter;
import com.netease.yunxin.kit.entertainment.common.model.RoomModel;
import com.netease.yunxin.kit.entertainment.common.utils.ClickUtils;
import com.netease.yunxin.kit.entertainment.common.utils.ReportUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NELiveType;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomLiveState;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomList;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.adapter.VoiceRoomListAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.FloatPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.NavUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.VoiceRoomUtils;
import kotlin.Unit;

public class VoiceRoomListActivity extends RoomListActivity {
  private static final String TAG_REPORT_PAGE_VOICE_ROOM = "page_chatroom_list";

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding.tvTitle.setText(getString(R.string.voiceroom_chat_room));
    binding.tvStart.setText(getString(R.string.voiceroom_start_voiceroom));
    ReportUtils.report(VoiceRoomListActivity.this, TAG_REPORT_PAGE_VOICE_ROOM, "chatroom_enter");
  }

  @Override
  protected void setEvent() {
    super.setEvent();
    binding.ivCreateRoom.setOnClickListener(
        v -> {
          ReportUtils.report(
              VoiceRoomListActivity.this, TAG_REPORT_PAGE_VOICE_ROOM, "chatroom_start_live");
          Intent intent = new Intent(this, VoiceRoomCreateActivity.class);
          intent.putExtra(RoomConstants.INTENT_IS_OVERSEA, isOversea);
          intent.putExtra(RoomConstants.INTENT_KEY_CONFIG_ID, configId);
          intent.putExtra(RoomConstants.INTENT_USER_NAME, userName);
          intent.putExtra(RoomConstants.INTENT_AVATAR, avatar);
          startActivity(intent);
        });
    adapter.setItemOnClickListener(
        info -> {
          if (ClickUtils.isFastClick()) {
            return;
          }
          if (NetworkUtils.isConnected()) {
            handleJoinVoiceRoom(info);
          } else {
            ToastUtils.INSTANCE.showShortToast(
                VoiceRoomListActivity.this,
                getString(
                    com.netease.yunxin.kit.entertainment.common.R.string.common_network_error));
          }
        });
  }

  @Override
  protected RoomListAdapter getRoomListAdapter() {
    return new VoiceRoomListAdapter(VoiceRoomListActivity.this);
  }

  @Override
  protected void refresh() {
    super.refresh();
    NEVoiceRoomKit.getInstance()
        .getRoomList(
            NEVoiceRoomLiveState.Live,
            NELiveType.LIVE_TYPE_VOICE,
            tempPageNum,
            PAGE_SIZE,
            new NEVoiceRoomCallback<NEVoiceRoomList>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomList neVoiceRoomList) {
                pageNum = tempPageNum;
                if (neVoiceRoomList == null
                    || neVoiceRoomList.getList() == null
                    || neVoiceRoomList.getList().isEmpty()) {
                  binding.emptyView.setVisibility(View.VISIBLE);
                  binding.rvRoomList.setVisibility(View.GONE);
                } else {
                  binding.emptyView.setVisibility(View.GONE);
                  binding.rvRoomList.setVisibility(View.VISIBLE);
                  adapter.refreshList(
                      VoiceRoomUtils.neVoiceRoomInfos2RoomInfos(neVoiceRoomList.getList()));
                }
                binding.refreshLayout.finishRefresh(true);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                tempPageNum = pageNum;
                binding.refreshLayout.finishRefresh(false);
                ToastUtils.INSTANCE.showShortToast(
                    VoiceRoomListActivity.this,
                    getString(
                        com.netease.yunxin.kit.entertainment.common.R.string.voiceroom_net_error));
              }
            });
  }

  @Override
  protected void loadMore() {
    super.loadMore();
    NEVoiceRoomKit.getInstance()
        .getRoomList(
            NEVoiceRoomLiveState.Live,
            NELiveType.LIVE_TYPE_VOICE,
            tempPageNum,
            PAGE_SIZE,
            new NEVoiceRoomCallback<NEVoiceRoomList>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomList neVoiceRoomList) {
                pageNum = tempPageNum;
                if (neVoiceRoomList != null && neVoiceRoomList.getList() != null) {
                  adapter.loadMore(
                      VoiceRoomUtils.neVoiceRoomInfos2RoomInfos(neVoiceRoomList.getList()));
                }
                binding.refreshLayout.finishLoadMore(true);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                tempPageNum = pageNum;
                binding.refreshLayout.finishLoadMore(false);
              }
            });
  }

  private void handleJoinVoiceRoom(RoomModel info) {
    if (FloatPlayManager.getInstance().isShowFloatView()) {
      if (FloatPlayManager.getInstance().getVoiceRoomInfo() != null
          && FloatPlayManager.getInstance()
              .getVoiceRoomInfo()
              .getRoomUuid()
              .equals(info.getRoomUuid())) {
        FloatPlayManager.getInstance().stopFloatPlay();
        NavUtils.toVoiceRoomAudiencePage(VoiceRoomListActivity.this, userName, avatar, info, false);
      } else {
        AlertDialog.Builder builder = new AlertDialog.Builder(VoiceRoomListActivity.this);
        builder.setTitle(getString(R.string.voiceroom_tip));
        builder.setMessage(getString(R.string.voiceroom_click_roomlist_tips));
        builder.setCancelable(true);
        builder.setPositiveButton(
            getString(R.string.voiceroom_sure),
            (dialog, which) -> {
              NEVoiceRoomKit.getInstance()
                  .leaveRoom(
                      new NEVoiceRoomCallback<Unit>() {
                        @Override
                        public void onSuccess(@Nullable Unit unit) {
                          NavUtils.toVoiceRoomAudiencePage(
                              VoiceRoomListActivity.this, userName, avatar, info, true);
                        }

                        @Override
                        public void onFailure(int code, @Nullable String msg) {}
                      });
              dialog.dismiss();
            });
        builder.setNegativeButton(
            getString(R.string.voiceroom_cancel), (dialog, which) -> dialog.dismiss());
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
      }
    } else {
      NavUtils.toVoiceRoomAudiencePage(VoiceRoomListActivity.this, userName, avatar, info, true);
    }
  }
}

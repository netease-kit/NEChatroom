// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.kit.voiceroomkit.ui.base.activity;

import android.os.Bundle;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.activity.BaseActivity;
import com.netease.yunxin.kit.entertainment.common.databinding.ActivityCreatRoomBinding;
import com.netease.yunxin.kit.entertainment.common.utils.ClickUtils;
import com.netease.yunxin.kit.entertainment.common.utils.Utils;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomOptions;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomParams;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceCreateRoomDefaultInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.utils.FloatPlayManager;
import java.util.List;
import kotlin.Unit;

public abstract class MultiCreateRoomActivity extends BaseActivity {

  private static final String TAG = "MultiCreateRoomActivity";
  protected ActivityCreatRoomBinding binding;
  protected static final int COUNT_SEAT = 9;
  protected boolean isOversea = false;
  protected String cover = "";
  protected int configId;
  protected String username;
  protected String avatar;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityCreatRoomBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    paddingStatusBarHeight(binding.clRoot);
    isOversea = getIntent().getBooleanExtra(RoomConstants.INTENT_IS_OVERSEA, false);
    configId = getIntent().getIntExtra(RoomConstants.INTENT_KEY_CONFIG_ID, 0);
    username = getIntent().getStringExtra(RoomConstants.INTENT_USER_NAME);
    avatar = getIntent().getStringExtra(RoomConstants.INTENT_AVATAR);
    getRoomDefault();
    setEvent();
  }

  protected void getRoomDefault() {
    NEVoiceRoomKit.getInstance()
        .getCreateRoomDefaultInfo(
            new NEVoiceRoomCallback<NEVoiceCreateRoomDefaultInfo>() {
              @Override
              public void onSuccess(
                  @Nullable NEVoiceCreateRoomDefaultInfo neVoiceCreateRoomDefaultInfo) {
                if (neVoiceCreateRoomDefaultInfo != null) {
                  binding.etRoomName.setText(neVoiceCreateRoomDefaultInfo.getTopic());
                  List<String> defaultPictures = neVoiceCreateRoomDefaultInfo.getDefaultPictures();
                  if (defaultPictures != null && !defaultPictures.isEmpty()) {
                    if (TextUtils.isEmpty(cover)) {
                      String firstCover = defaultPictures.get(0);
                      setRoomBg(firstCover);
                      cover = firstCover;
                    }
                    refreshRoomBgList(defaultPictures);
                  }
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {}
            });
  }

  protected void setEvent() {
    binding.ivBack.setOnClickListener(v -> finish());
    binding.ivRandom.setOnClickListener(v -> getRoomDefault());
    binding.selectRoomBgView.setOnSelectBgListener(
        cover -> {
          this.cover = cover;
          setRoomBg(cover);
        });
    binding.tvCreateRoom.setOnClickListener(
        v -> {
          if (ClickUtils.isFastClick()) {
            return;
          }

          if (TextUtils.isEmpty(binding.etRoomName.getText().toString())) {
            ToastUtils.INSTANCE.showShortToast(
                MultiCreateRoomActivity.this, getString(R.string.voiceroom_empty_roomname_tips));
            return;
          }

          if (TextUtils.isEmpty(cover)) {
            ToastUtils.INSTANCE.showShortToast(
                MultiCreateRoomActivity.this, getString(R.string.voiceroom_empty_roomcover_tips));
            return;
          }

          if (FloatPlayManager.getInstance().isShowFloatView()) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle(getString(R.string.voiceroom_tip));
            builder.setMessage(getString(R.string.click_create_room_tips));
            builder.setCancelable(true);
            builder.setPositiveButton(
                getString(R.string.voiceroom_sure),
                (dialog, which) -> {
                  if (VoiceRoomUtils.isLocalAnchor()) {
                    NEVoiceRoomKit.getInstance()
                        .endRoom(
                            new NEVoiceRoomCallback<Unit>() {
                              @Override
                              public void onSuccess(@Nullable Unit unit) {
                                if (Utils.getApp() != null) {
                                  ToastUtils.INSTANCE.showShortToast(
                                      Utils.getApp(),
                                      Utils.getApp()
                                          .getString(R.string.voiceroom_host_close_room_success));
                                }
                                createRoomInner();
                              }

                              @Override
                              public void onFailure(int code, @Nullable String msg) {
                                ALog.e(TAG, "endRoom failed code:" + code + ",msg:" + msg);
                              }
                            });
                  } else {
                    NEVoiceRoomKit.getInstance()
                        .leaveRoom(
                            new NEVoiceRoomCallback<Unit>() {
                              @Override
                              public void onSuccess(@Nullable Unit unit) {
                                createRoomInner();
                              }

                              @Override
                              public void onFailure(int code, @Nullable String msg) {
                                ALog.e(TAG, "leaveRoom failed code:" + code + ",msg:" + msg);
                              }
                            });
                  }
                  FloatPlayManager.getInstance().stopFloatPlay();
                  dialog.dismiss();
                });
            builder.setNegativeButton(
                getString(R.string.voiceroom_cancel), (dialog, which) -> dialog.dismiss());
            AlertDialog alertDialog = builder.create();
            alertDialog.show();
          } else {
            createRoomInner();
          }
        });
  }

  protected void createRoomInner() {
    NECreateVoiceRoomParams createVoiceRoomParams =
        new NECreateVoiceRoomParams(
            binding.etRoomName.getText().toString(),
            username,
            COUNT_SEAT,
            getSeatMode(),
            configId,
            cover,
            getLiveType(),
            null);
    NEVoiceRoomKit.getInstance()
        .createRoom(
            createVoiceRoomParams,
            new NECreateVoiceRoomOptions(),
            new NEVoiceRoomCallback<NEVoiceRoomInfo>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomInfo roomInfo) {
                onCreateSuccess(roomInfo);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "createRoom failed code:" + code + ",msg:" + msg);
                onCreateFailed(code, msg);
              }
            });
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }

  public void setRoomBg(String coverUrl) {
    Glide.with(getApplicationContext())
        .load(coverUrl)
        .centerInside()
        .placeholder(binding.ivBg.getDrawable())
        .diskCacheStrategy(DiskCacheStrategy.NONE)
        .into(binding.ivBg);
  }

  public void refreshRoomBgList(List<String> bgList) {
    binding.selectRoomBgView.setData(bgList);
  }

  public static class Room {
    public String name;
    public boolean selected;

    public Room(String name, boolean selected) {
      this.name = name;
      this.selected = selected;
    }
  }

  protected abstract void onCreateSuccess(NEVoiceRoomInfo roomInfo);

  protected abstract void onCreateFailed(int code, String msg);

  protected abstract int getLiveType();

  protected abstract int getSeatMode();
}

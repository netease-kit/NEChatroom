// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.kit.entertainment.common.activity;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.databinding.ActivityCreatRoomBinding;

public class CreateRoomActivity extends BaseActivity {

  private static final String TAG = "CreateRoomActivity";
  protected ActivityCreatRoomBinding binding;
  protected static final int COUNT_SEAT = 9;
  protected static final int LISTEN_TOGETHER_COUNT_SEAT = 2;
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
    paddingStatusBarHeight(binding.getRoot());
    isOversea = getIntent().getBooleanExtra(RoomConstants.INTENT_IS_OVERSEA, false);
    configId = getIntent().getIntExtra(RoomConstants.INTENT_KEY_CONFIG_ID, 0);
    username = getIntent().getStringExtra(RoomConstants.INTENT_USER_NAME);
    avatar = getIntent().getStringExtra(RoomConstants.INTENT_AVATAR);
    getRoomDefault();
    setEvent();
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }

  protected void getRoomDefault() {}

  protected void setEvent() {
    binding.ivBack.setOnClickListener(v -> finish());
    binding.ivRandom.setOnClickListener(v -> getRoomDefault());
  }

  public static class Room {
    public String name;
    public boolean selected;

    public Room(String name, boolean selected) {
      this.name = name;
      this.selected = selected;
    }
  }
}

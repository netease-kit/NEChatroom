// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.activity;

import android.text.TextUtils;
import android.view.View;
import androidx.annotation.Nullable;
import com.google.android.material.tabs.TabLayout;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.adapter.MainPagerAdapter;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.app.chatroom.databinding.ActivityHomeBinding;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.copyrightedmedia.api.SongScene;
import com.netease.yunxin.kit.entertainment.common.activity.BasePartyActivity;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import java.util.Objects;
import kotlin.Unit;

public class HomeActivity extends BasePartyActivity {
  private static final String TAG = "HomeActivity";
  private ActivityHomeBinding binding;
  public int curTabIndex = -1;

  @Override
  protected View getRootView() {
    binding = ActivityHomeBinding.inflate(getLayoutInflater());
    return binding.getRoot();
  }

  @Override
  protected void init() {
    curTabIndex = -1;
    login(AppConfig.ACCOUNT, AppConfig.TOKEN);
    initViews();
  }

  private void initViews() {
    binding.vpFragment.setAdapter(new MainPagerAdapter(getSupportFragmentManager()));
    binding.vpFragment.setOffscreenPageLimit(2);
    binding.tlTab.setupWithViewPager(binding.vpFragment);
    binding.tlTab.removeAllTabs();
    binding.tlTab.setTabGravity(TabLayout.GRAVITY_CENTER);
    binding.tlTab.setSelectedTabIndicator(null);
    binding.tlTab.addTab(
        binding.tlTab.newTab().setCustomView(R.layout.view_item_home_tab_app), 0, true);
    binding.tlTab.addTab(
        binding.tlTab.newTab().setCustomView(R.layout.view_item_home_tab_user), 1, false);
    binding.vpFragment.addOnPageChangeListener(
        new TabLayout.TabLayoutOnPageChangeListener(binding.tlTab) {

          @Override
          public void onPageSelected(int position) {
            TabLayout.Tab item = binding.tlTab.getTabAt(position);
            if (item != null) {
              item.select();
            }
            super.onPageSelected(position);
          }
        });
  }

  @Override
  public void onBackPressed() {
    moveTaskToBack(true);
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    curTabIndex = -1;
    ALog.flush(true);
  }

  private void login(String account, String token) {
    if (TextUtils.isEmpty(account)) {
      ALog.d(TAG, "login but account is empty");
      ToastX.showShortToast(R.string.app_account);
      return;
    }
    if (TextUtils.isEmpty(token)) {
      ALog.d(TAG, "login but token is empty");
      ToastX.showShortToast(R.string.app_token);
      return;
    }
    NEVoiceRoomKit.getInstance()
        .login(
            Objects.requireNonNull(account),
            Objects.requireNonNull(token),
            new NEVoiceRoomCallback<Unit>() {

              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "NEVoiceRoomKit login success");
                NEOrderSongService.INSTANCE.initialize(
                    HomeActivity.this.getApplicationContext(),
                    AppConfig.getAppKey(),
                    AppConfig.getBaseUrl(),
                    AppConfig.getNERoomServerUrl(),
                    account);
                NEOrderSongService.INSTANCE.setSongScene(SongScene.TYPE_LISTENING_TO_MUSIC);
                NEOrderSongService.INSTANCE.addHeader("user", account);
                NEOrderSongService.INSTANCE.addHeader("token", token);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "NEVoiceRoomKit login failed code = " + code + ", msg = " + msg);
                ToastX.showShortToast(msg);
              }
            });
  }
}

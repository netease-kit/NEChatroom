// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.activity;

import android.view.View;
import com.google.android.material.tabs.TabLayout;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.adapter.MainPagerAdapter;
import com.netease.yunxin.app.chatroom.databinding.ActivityHomeBinding;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.entertainment.common.activity.BasePartyActivity;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAuthEvent;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;

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
    initViews();
    NEVoiceRoomKit.getInstance()
        .addAuthListener(
            evt -> {
              ALog.i(TAG, "onVoiceRoomAuthEvent evt = " + evt);
              if (evt == NEVoiceRoomAuthEvent.KICK_OUT) {
                ToastX.showShortToast(R.string.app_kick_out);
                SampleLoginActivity.startLoginActivity(HomeActivity.this);
              }
              if (evt != NEVoiceRoomAuthEvent.LOGGED_IN) {}
            });
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
}

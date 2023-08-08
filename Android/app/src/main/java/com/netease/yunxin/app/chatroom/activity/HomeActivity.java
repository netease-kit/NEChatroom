// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.activity;

import android.text.TextUtils;
import android.view.View;
import androidx.annotation.Nullable;
import com.google.android.material.tabs.TabLayout;
import com.netease.yunxin.app.chatroom.BuildConfig;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.adapter.MainPagerAdapter;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.app.chatroom.databinding.ActivityHomeBinding;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.copyrightedmedia.api.SongScene;
import com.netease.yunxin.kit.entertainment.common.activity.BasePartyActivity;
import com.netease.yunxin.kit.entertainment.common.http.ECHttpService;
import com.netease.yunxin.kit.entertainment.common.model.ECModelResponse;
import com.netease.yunxin.kit.entertainment.common.model.NemoAccount;
import com.netease.yunxin.kit.entertainment.common.utils.UserInfoManager;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import kotlin.Unit;
import retrofit2.Call;
import retrofit2.Callback;

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
    // 通过调用Http请求从业务服务器获取新账号，然后再调用登录方法。 注意：在实际项目中时，开发者需要根据实际的业务逻辑调用登录方法。
    createAccountThenLogin(
              AppConfig.getAppKey(),
              AppConfig.APP_SECRET,
              2,
              BuildConfig.VERSION_NAME,
              new Callback<ECModelResponse<NemoAccount>>() {
                @Override
                public void onResponse(
                        Call<ECModelResponse<NemoAccount>> call,
                        retrofit2.Response<ECModelResponse<NemoAccount>> response) {
                  if (response.body() != null) {
                    NemoAccount account = response.body().data;
                    if (account != null) {
                      login(account);
                    } else {
                      ToastX.showShortToast("createAccountThenLogin failed,account is null");
                      ALog.e(TAG, "createAccountThenLogin failed,account is null");
                    }
                  }
                }

                @Override
                public void onFailure(Call<ECModelResponse<NemoAccount>> call, Throwable t) {
                  ToastX.showShortToast("createAccountThenLogin failed,t:" + t);
                  ALog.e(TAG, "createAccountThenLogin failed,exception:" + t);
                }
              });
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

  private void login(NemoAccount nemoAccount) {
    if (TextUtils.isEmpty(nemoAccount.userUuid)) {
      ALog.d(TAG, "login but account is empty");
      ToastX.showShortToast(R.string.app_account);
      return;
    }
    if (TextUtils.isEmpty(nemoAccount.userToken)) {
      ALog.d(TAG, "login but token is empty");
      ToastX.showShortToast(R.string.app_token);
      return;
    }
    UserInfoManager.setIMUserInfo(
        nemoAccount.userUuid, nemoAccount.imToken, nemoAccount.userName, nemoAccount.icon, "");
    NEVoiceRoomKit.getInstance()
        .login(
            nemoAccount.userUuid,
            nemoAccount.userToken,
            new NEVoiceRoomCallback<Unit>() {

              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "NEVoiceRoomKit login success");
                NEOrderSongService.INSTANCE.initialize(
                    HomeActivity.this.getApplicationContext(),
                    AppConfig.getAppKey(),
                    AppConfig.getBaseUrl(),
                    AppConfig.getNERoomServerUrl(),
                    nemoAccount.userUuid);
                NEOrderSongService.INSTANCE.setSongScene(SongScene.TYPE_LISTENING_TO_MUSIC);
                NEOrderSongService.INSTANCE.addHeader("user", nemoAccount.userUuid);
                NEOrderSongService.INSTANCE.addHeader("token", nemoAccount.userToken);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "NEVoiceRoomKit login failed code = " + code + ", msg = " + msg);
                ToastX.showShortToast(msg);
              }
            });
  }

  private void createAccountThenLogin(
      String appKey,
      String appSecret,
      int sceneType,
      String versionCode,
      Callback<ECModelResponse<NemoAccount>> callback) {
    ECHttpService.getInstance().initialize(this, AppConfig.BASE_URL);
    ECHttpService.getInstance().addHeader("appkey", appKey);
    ECHttpService.getInstance().addHeader("AppSecret", appSecret);
    ECHttpService.getInstance().addHeader("versionCode", versionCode);
    ECHttpService.getInstance().createAccount(sceneType, callback);
  }
}

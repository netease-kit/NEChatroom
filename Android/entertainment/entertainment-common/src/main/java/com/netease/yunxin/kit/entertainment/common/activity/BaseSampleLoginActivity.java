// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.view.View;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.dialog.LoadingDialog;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.databinding.ActivitySampleLoginBinding;
import com.netease.yunxin.kit.entertainment.common.http.ECHttpService;
import com.netease.yunxin.kit.entertainment.common.model.ECModelResponse;
import com.netease.yunxin.kit.entertainment.common.model.NemoAccount;
import retrofit2.Call;
import retrofit2.Callback;

/** 登录页面 */
public abstract class BaseSampleLoginActivity extends BasePartyActivity {
  private static final String TAG = "BaseSampleLoginActivity";
  private ActivitySampleLoginBinding binding;
  protected static Boolean hasStart = false;
  protected LoadingDialog loadingDialog;

  @Override
  protected View getRootView() {
    hasStart = true;
    binding = ActivitySampleLoginBinding.inflate(getLayoutInflater());
    binding.login.setOnClickListener(v -> createAccountThenLogin());
    return binding.getRoot();
  }

  @Override
  protected void init() {
    binding.iv.setImageResource(getIconResId());
    binding.tv.setText(getString(getContentResId()));
  }

  private void createAccountThenLogin() {
    loadingDialog = new LoadingDialog(this);
    loadingDialog.setLoadingText(getString(R.string.logining));
    loadingDialog.show();
    // 先创建账号再登录1v1再登录云信IM
    createAccount(
        new Callback<ECModelResponse<NemoAccount>>() {
          @Override
          public void onResponse(
              @NonNull Call<ECModelResponse<NemoAccount>> call,
              @NonNull retrofit2.Response<ECModelResponse<NemoAccount>> response) {
            if (response.body() != null) {
              NemoAccount nemoAccount = response.body().data;
              if (nemoAccount != null) {
                login(nemoAccount);
              } else {
                ToastX.showShortToast("createAccountThenLogin failed,account is null");
                ALog.e(TAG, "createAccountThenLogin failed,account is null");
              }
            }
          }

          @Override
          public void onFailure(
              @NonNull Call<ECModelResponse<NemoAccount>> call, @NonNull Throwable t) {
            ToastX.showShortToast("createAccountThenLogin failed,t:" + t);
            ALog.e(TAG, "createAccountThenLogin failed,exception:" + t);
          }
        });
  }

  private void createAccount(Callback<ECModelResponse<NemoAccount>> callback) {
    ECHttpService.getInstance().initialize(this, getBaseUrl());
    ECHttpService.getInstance().addHeader("appkey", getAppKey());
    ECHttpService.getInstance().addHeader("AppSecret", getAppSecret());
    ECHttpService.getInstance().createAccount(callback);
  }

  public abstract void login(NemoAccount nemoAccount);

  public abstract String getBaseUrl();

  public abstract String getAppKey();

  public abstract String getAppSecret();

  public abstract int getIconResId();

  public abstract int getContentResId();

  @Override
  protected void onDestroy() {
    super.onDestroy();
    hasStart = false;
  }
}

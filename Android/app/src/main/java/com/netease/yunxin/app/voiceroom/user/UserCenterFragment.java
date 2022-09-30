// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.voiceroom.user;

import static com.netease.yunxin.app.voiceroom.utils.NavUtils.toAppAboutPage;
import static com.netease.yunxin.app.voiceroom.utils.NavUtils.toBrowsePage;
import static com.netease.yunxin.app.voiceroom.utils.NavUtils.toUserInfoPage;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.voiceroom.AppStates;
import com.netease.yunxin.app.voiceroom.Constants;
import com.netease.yunxin.app.voiceroom.R;
import com.netease.yunxin.app.voiceroom.config.AppConfig;
import com.netease.yunxin.app.voiceroom.databinding.FragmentUserCenterBinding;
import com.netease.yunxin.app.voiceroom.utils.AppUtils;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.common.ui.dialog.LoadingDialog;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.LoginCallback;
import com.netease.yunxin.kit.login.model.LoginEvent;
import com.netease.yunxin.kit.login.model.LoginObserver;
import com.netease.yunxin.kit.login.model.UserInfo;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.ui.fragment.BaseFragment;

public final class UserCenterFragment extends BaseFragment {

  private UserInfo userInfo = AuthorManager.INSTANCE.getUserInfo();
  private final LoginObserver<LoginEvent> loginObserver =
      loginEvent -> {
        userInfo = loginEvent.getUserInfo();
        initUser();
      };
  private FragmentUserCenterBinding binding;

  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    AuthorManager.INSTANCE.registerLoginObserver(loginObserver);
  }

  public void onDestroy() {
    super.onDestroy();
    AuthorManager.INSTANCE.unregisterLoginObserver(loginObserver);
  }

  public View onCreateView(
      @NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    binding = FragmentUserCenterBinding.inflate(inflater);
    initViews();
    initDataCenter();
    paddingStatusBarHeight(binding.getRoot());
    return binding.getRoot();
  }

  private void initViews() {
    initUser();
    binding.rlUserGroup.setOnClickListener(v -> toUserInfoPage(getActivity()));
    binding.tvAppAbout.setOnClickListener(v -> toAppAboutPage(getActivity()));
    binding.tvFreeTrail.setOnClickListener(
        v ->
            toBrowsePage(
                getActivity(),
                getString(R.string.app_free_trial),
                AppUtils.isMainLand() ? Constants.URL_FREE_TRAIL : Constants.URL_FREE_TRAIL_EN));
  }

  private void initUser() {
    if (userInfo != null) {
      ImageLoader.with(getActivity()).circleLoad(userInfo.getAvatar(), binding.ivUserPortrait);
      binding.tvUserName.setText(userInfo.getNickname());
    }
  }

  private View.OnClickListener dataCenterChangeListener;

  private void initDataCenter() {
    if (AppConfig.getDataCenter() == AppConfig.DataCenter.MainLand) {
      binding.dataCenterMainland.setChecked(true);
    } else {
      binding.dataCenterOversea.setChecked(true);
    }
    if (dataCenterChangeListener == null) {
      dataCenterChangeListener =
          (buttonView) -> {
            final AppConfig.DataCenter dataCenter =
                buttonView == binding.dataCenterMainland
                    ? AppConfig.DataCenter.MainLand
                    : AppConfig.DataCenter.Oversea;
            if (dataCenter != AppConfig.getDataCenter()) {
              new AlertDialog.Builder(requireActivity())
                  .setMessage(R.string.app_data_center_switch_confirm_message)
                  .setPositiveButton(
                      R.string.app_yes,
                      (dialog, which) -> {
                        AppConfig.setDataCenter(dataCenter);
                        logoutThenQuitApp(this::initDataCenter);
                      })
                  .setNegativeButton(R.string.app_no, (dialog, which) -> initDataCenter())
                  .setCancelable(false)
                  .show();
            }
          };
      binding.dataCenterMainland.setOnClickListener(dataCenterChangeListener);
      binding.dataCenterOversea.setOnClickListener(dataCenterChangeListener);
    }
  }

  private void logoutThenQuitApp(final Runnable onFailure) {
    AppStates.get().setAppRestartInFlight(true);
    toggleLoading(true);
    AuthorManager.INSTANCE.logout(
        new LoginCallback<Void>() {
          @Override
          public void onSuccess(@Nullable Void unused) {
            // ensure AuthManager clear user info cache
            new Handler()
                .postDelayed(
                    () -> {
                      NEVoiceRoomKit.getInstance().logout(null);
                      toggleLoading(false);
                      if (getActivity() != null) {
                        Intent intent =
                            getActivity()
                                .getPackageManager()
                                .getLaunchIntentForPackage(getActivity().getPackageName());
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        startActivity(intent);
                      }
                      android.os.Process.killProcess(android.os.Process.myPid());
                      System.exit(0);
                    },
                    1500);
          }

          @Override
          public void onError(int i, @NonNull String s) {
            AppStates.get().setAppRestartInFlight(false);
            toggleLoading(false);
            onFailure.run();
          }
        });
  }

  private Dialog loadingDialog;

  private void toggleLoading(boolean show) {
    if (loadingDialog == null) {
      loadingDialog = new LoadingDialog(requireActivity());
    }
    if (show && !loadingDialog.isShowing()) {
      loadingDialog.show();
    } else if (!show) {
      loadingDialog.dismiss();
      loadingDialog = null;
    }
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.fragment;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.app.chatroom.databinding.FragmentUserCenterBinding;
import com.netease.yunxin.app.chatroom.utils.AppUtils;
import com.netease.yunxin.app.chatroom.utils.NavUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.dialog.LoadingDialog;
import com.netease.yunxin.kit.entertainment.common.Constants;
import com.netease.yunxin.kit.entertainment.common.dialog.NetworkInfoDialog;
import com.netease.yunxin.kit.entertainment.common.dialog.PhoneConsultBottomDialog;
import com.netease.yunxin.kit.entertainment.common.fragment.BaseFragment;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import static android.app.Activity.RESULT_OK;

public class UserCenterFragment extends BaseFragment {
  private static final String TAG = "UserCenterFragment";
  private FragmentUserCenterBinding binding;
  private Dialog loadingDialog;
  private int count = 0;
  private int quality = -1;
  private static final int CALLBACK_TOTAL_COUNT = 2;

  @Override
  public void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }

  @Nullable
  @Override
  public View onCreateView(
      @NonNull LayoutInflater inflater,
      @Nullable ViewGroup container,
      @Nullable Bundle savedInstanceState) {

    binding = FragmentUserCenterBinding.inflate(inflater, container, false);
    View rootView = binding.getRoot();
    initViews();
    initDataCenter();
    return rootView;
  }

  private void initViews() {
    initUser();
    binding.commonSetting.setOnClickListener(v -> NavUtils.toCommonSettingPage(requireActivity()));
    binding.phoneConsult.setOnClickListener(
        v -> {
          PhoneConsultBottomDialog dialog = new PhoneConsultBottomDialog(requireActivity());
          dialog.show();
        });
  }

  private void initUser() {
    binding.ivUserPortrait.loadAvatar(AppUtils.getAvatar());
    binding.tvUserName.setText(AppUtils.getUserName());
  }

  private void initDataCenter() {
    ActivityResultLauncher<Intent> launcher =
        registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            result -> {
              if (result.getResultCode() == RESULT_OK) {
                if (result.getData() != null) {
                  String nick = result.getData().getStringExtra(Constants.INTENT_KEY_NICK);
                  binding.tvUserName.setText(nick);
                }
              }
            });
  }

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

  @Override
  public void onDestroy() {
    super.onDestroy();
  }
}

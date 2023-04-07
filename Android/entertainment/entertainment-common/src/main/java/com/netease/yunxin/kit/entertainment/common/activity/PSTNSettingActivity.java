// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.view.View;
import androidx.appcompat.app.AlertDialog;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.lava.nertc.foreground.ForegroundKit;
import com.netease.yunxin.kit.entertainment.common.Constants;
import com.netease.yunxin.kit.entertainment.common.ErrorCode;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.databinding.ActivityPstnSettingBinding;
import com.netease.yunxin.kit.entertainment.common.statusbar.StatusBarConfig;
import com.netease.yunxin.kit.entertainment.common.utils.HighKeepAliveUtil;

public class PSTNSettingActivity extends BasePartyActivity {
  private ActivityPstnSettingBinding binding;
  private String appKey;

  @Override
  protected void init() {
    appKey = getIntent().getStringExtra(Constants.INTENT_KEY_APP_KEY);
    initView();
  }

  @Override
  protected View getRootView() {
    binding = ActivityPstnSettingBinding.inflate(getLayoutInflater());
    return binding.getRoot();
  }

  private void initView() {
    binding.switchButton.setChecked(HighKeepAliveUtil.isHighKeepAliveOpen());
    binding.switchButton.setOnCheckedChangeListener(
        (compoundButton, isChecked) -> {
          if (isChecked) {
            int code = HighKeepAliveUtil.openHighKeepAlive(PSTNSettingActivity.this, appKey);
            if (code != ErrorCode.SUCCESS) {
              ToastUtils.showShort("open high keep alive feature failed,errorCode:" + code);
              compoundButton.setChecked(false);
              new AlertDialog.Builder(PSTNSettingActivity.this)
                  .setTitle(R.string.app_tips)
                  .setMessage(R.string.app_notification_tips)
                  .setNegativeButton(R.string.cancel, (dialog, which) -> dialog.dismiss())
                  .setPositiveButton(
                      R.string.app_sure,
                      (dialog, which) -> {
                        HighKeepAliveUtil.requestNotifyPermission(PSTNSettingActivity.this);
                        dialog.dismiss();
                      })
                  .create()
                  .show();
            }
          } else {
            HighKeepAliveUtil.closeHighKeepAlive(PSTNSettingActivity.this);
          }
        });
    binding.clSetting.setOnClickListener(
        new View.OnClickListener() {
          @Override
          public void onClick(View v) {
            if (binding.tvFloatPermission.getText().equals(getString(R.string.has_open))) {
              return;
            }
            ForegroundKit.getInstance(PSTNSettingActivity.this).requestFloatPermission();
          }
        });
  }

  @Override
  protected void onResume() {
    super.onResume();
    if (ForegroundKit.getInstance(this).checkFloatPermission()) {
      binding.tvFloatPermission.setText(getString(R.string.has_open));
      binding.ivRightArrow.setVisibility(View.GONE);
    } else {
      binding.tvFloatPermission.setText(getString(R.string.has_close));
      binding.ivRightArrow.setVisibility(View.VISIBLE);
    }
  }

  @Override
  protected StatusBarConfig provideStatusBarConfig() {
    return new StatusBarConfig.Builder()
        .statusBarDarkFont(true)
        .statusBarColor(R.color.color_eff1f4)
        .fitsSystemWindow(true)
        .build();
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.yunxin.kit.entertainment.common.utils.ViewUtils;

public class BaseActivity extends AppCompatActivity {

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (needTransparentStatusBar()) {
      ViewUtils.transparentStatusBar(getWindow(), getStatusBarTextModeType());
    }
  }

  protected boolean needTransparentStatusBar() {
    return false;
  }

  protected ViewUtils.ModeType getStatusBarTextModeType() {
    return ViewUtils.ModeType.AUTO;
  }

  protected void paddingStatusBarHeight(View view) {
    ViewUtils.paddingStatusBarHeight(this, view);
  }
}

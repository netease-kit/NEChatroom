// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.entertainment.common.AppStates;
import com.netease.yunxin.kit.entertainment.common.AppStatusConstant;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;

public abstract class BasePartyActivity extends BaseActivity {

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (validateAppStatus()) {
      setContentView(getRootView());
      init();
    } else {
      finish();
    }
  }

  private boolean validateAppStatus() {
    return AppStatusManager.getInstance().getAppStatus() == AppStatusConstant.STATUS_NORMAL;
  }

  protected abstract View getRootView();

  protected void init() {}

  protected boolean ignoredLoginEvent() {
    return AppStates.get().isAppRestartInFlight();
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.content.Context;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.entertainment.common.R;

public class NetUtils {
  public static final String TAG = "NetworkUtils";

  public static boolean checkNetwork(Context context) {
    if (context == null) {
      ALog.e(TAG, "checkNetwork but context == null");
      return false;
    }

    if (isConnected()) {
      return true;
    } else {
      ToastUtils.INSTANCE.showShortToast(
          context.getApplicationContext(), context.getString(R.string.common_network_error));
      return false;
    }
  }

  public static void registerStateListener(NetworkUtils.NetworkStateListener listener) {
    NetworkUtils.registerNetworkStatusChangedListener(listener);
  }

  public static void unregisterStateListener(NetworkUtils.NetworkStateListener listener) {
    NetworkUtils.unregisterNetworkStatusChangedListener(listener);
  }

  public static boolean isConnected() {
    return NetworkUtils.isConnected();
  }
}

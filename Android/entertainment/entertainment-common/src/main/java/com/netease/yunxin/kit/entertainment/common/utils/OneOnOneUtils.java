// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import com.netease.yunxin.kit.corekit.service.XKitServiceManager;

public class OneOnOneUtils {
  public static final String TAG = "OneOnOneUtils";
  private static final String ONE_ON_ONE_SERVICE_NAME = "OneOnOne";

  public static boolean isInTheCall() {
    Object result =
        XKitServiceManager.Companion.getInstance()
            .callService(ONE_ON_ONE_SERVICE_NAME, "isInTheCall", null);
    return result instanceof Boolean && (boolean) result;
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.app.*;

public class Utils {
  private static Application application;

  public static Application getApp() {
    if (application != null) {
      return application;
    }
    try {
      application =
          (Application)
              Class.forName("android.app.ActivityThread")
                  .getMethod("currentApplication")
                  .invoke(null, (Object[]) null);
      return application;
    } catch (Exception e) {
      e.printStackTrace();
    }
    return null;
  }
}

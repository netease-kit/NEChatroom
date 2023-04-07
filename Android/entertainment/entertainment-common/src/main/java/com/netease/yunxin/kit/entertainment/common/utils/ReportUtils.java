// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.content.Context;
import android.content.Intent;

public class ReportUtils {

  public static final String ACTION_REPORT = "com.netease.yunxin.app.party.INTENT_REPORT";
  public static final String EXTRA_PAGE = "page";
  public static final String EXTRA_KEY = "key";

  public static void report(Context context, String page, String key) {
    Intent intent = new Intent();
    intent.setAction(ACTION_REPORT);
    intent.putExtra(EXTRA_PAGE, page);
    intent.putExtra(EXTRA_KEY, key);
    intent.setPackage(context.getPackageName());
    context.sendBroadcast(intent);
  }
}

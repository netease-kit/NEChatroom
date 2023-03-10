// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.impl.utils;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Resources;
import android.util.DisplayMetrics;
import java.lang.reflect.Field;

public class ScreenUtil {

  private static final String TAG = "Demo.ScreenUtil";

  private static final double RATIO = 0.85;

  public static int screenWidth;

  public static int screenHeight;

  public static int screenMin; // 宽高中，小的一边

  public static int screenMax; // 宽高中，较大的值

  public static float density;

  public static float scaleDensity;

  public static float xdpi;

  public static float ydpi;

  public static int densityDpi;

  public static int dialogWidth;

  public static int statusBarHeight;

  public static int navBarHeight;

  public static int dip2px(float dipValue) {
    return (int) (dipValue * density + 0.5f);
  }

  public static int px2dip(float pxValue) {
    return (int) (pxValue / density + 0.5f);
  }

  public static int sp2px(float spValue) {
    return (int) (spValue * scaleDensity + 0.5f);
  }

  public static int getDialogWidth() {
    dialogWidth = (int) (screenMin * RATIO);
    return dialogWidth;
  }

  public static void init(Context context) {
    if (null == context) {
      return;
    }
    DisplayMetrics dm = context.getApplicationContext().getResources().getDisplayMetrics();
    screenWidth = dm.widthPixels;
    screenHeight = dm.heightPixels;
    screenMin = Math.min(screenWidth, screenHeight);
    density = dm.density;
    scaleDensity = dm.scaledDensity;
    xdpi = dm.xdpi;
    ydpi = dm.ydpi;
    densityDpi = dm.densityDpi;
  }

  public static int getDisplayWidth() {
    return screenWidth;
  }

  public static int getDisplayHeight() {
    return screenHeight;
  }

  public static void getInfo(Context context) {
    if (null == context) {
      return;
    }
    DisplayMetrics dm = context.getApplicationContext().getResources().getDisplayMetrics();
    screenWidth = dm.widthPixels;
    screenHeight = dm.heightPixels;
    screenMin = Math.min(screenWidth, screenHeight);
    screenMax = Math.max(screenWidth, screenHeight);
    density = dm.density;
    scaleDensity = dm.scaledDensity;
    xdpi = dm.xdpi;
    ydpi = dm.ydpi;
    densityDpi = dm.densityDpi;
    statusBarHeight = getStatusBarHeight(context);
    navBarHeight = getNavBarHeight(context);
  }

  public static int getStatusBarHeight(Context context) {
    if (statusBarHeight == 0) {
      try {
        @SuppressLint("PrivateApi")
        Class<?> c = Class.forName("com.android.internal.R$dimen");
        Object o = c.newInstance();
        Field field = c.getField("status_bar_height");
        int x = (int) field.get(o);
        statusBarHeight = context.getResources().getDimensionPixelSize(x);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    if (statusBarHeight == 0) {
      statusBarHeight = ScreenUtil.dip2px(25);
    }
    return statusBarHeight;
  }

  public static int getNavBarHeight(Context context) {
    Resources resources = context.getResources();
    @SuppressLint("InternalInsetResource")
    int resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android");
    if (resourceId > 0) {
      return resources.getDimensionPixelSize(resourceId);
    }
    return 0;
  }
}

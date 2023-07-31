// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import androidx.core.content.res.ResourcesCompat;
import com.netease.yunxin.kit.common.utils.ScreenUtils;
import com.netease.yunxin.kit.common.utils.XKitUtils;
import com.netease.yunxin.kit.entertainment.common.R;

/** Created by luc on 2020/11/25. */
public final class ViewUtils {

  /**
   * 判断当前坐标是否在设置的view上
   *
   * @param view 目标 view
   * @param x 横坐标
   * @param y 纵坐标
   * @return true 在view 上，false 反之。
   */
  public static boolean isInView(View view, int x, int y) {
    if (view == null) {
      return false;
    }
    int[] location = new int[2];
    view.getLocationOnScreen(location);
    int left = location[0];
    int top = location[1];
    int right = left + view.getMeasuredWidth();
    int bottom = top + view.getMeasuredHeight();
    return y >= top && y <= bottom && x >= left && x <= right;
  }

  public static void transparentStatusBar(Window window) {
    transparentStatusBar(window, ModeType.AUTO);
  }

  public static void transparentStatusBar(Window window, ModeType modeType) {
    window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
    window
        .getDecorView()
        .setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
    //将状态栏设置成透明色
    window.setStatusBarColor(Color.TRANSPARENT);
    setStatusBarTextColor(
        window,
        modeType == ModeType.AUTO ? isNightMode(window.getContext()) : modeType == ModeType.NIGHT);
    setNavigationBarColor(
        window,
        modeType == ModeType.AUTO ? isNightMode(window.getContext()) : modeType == ModeType.NIGHT);
  }

  public static void setStatusBarTextColor(Window window, boolean isNightMode) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      int systemUiVisibility = window.getDecorView().getSystemUiVisibility();
      if (isNightMode) { //白色文字
        systemUiVisibility &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
      } else { //黑色文字
        systemUiVisibility |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
      }
      window.getDecorView().setSystemUiVisibility(systemUiVisibility);
    }
  }

  public static void setNavigationBarColor(Window window, boolean isNightMode) {
    int color;
    if (isNightMode) {
      color =
          ResourcesCompat.getColor(
              XKitUtils.getApplicationContext().getResources(), R.color.black, null);
    } else {
      color =
          ResourcesCompat.getColor(
              XKitUtils.getApplicationContext().getResources(), R.color.white, null);
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      window.setNavigationBarContrastEnforced(false);
    }
    window.setNavigationBarColor(color);
  }

  private static boolean isNightMode(Context context) {
    int nightModeFlags =
        context.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;
    return nightModeFlags == Configuration.UI_MODE_NIGHT_YES;
  }

  public static void paddingStatusBarHeight(Activity activity, View view) {

    if (view == null) {
      return;
    }
    int barHeight = getStatusBarHeight(activity);
    view.setPadding(
        view.getPaddingLeft(),
        view.getPaddingTop() + barHeight,
        view.getPaddingRight(),
        view.getPaddingBottom());
  }

  public static int getStatusBarHeight(Activity activity) {
    return ScreenUtils.getStatusBarHeight();
  }

  public enum ModeType {
    AUTO,
    NIGHT,
    NOT_NIGHT
  }
}

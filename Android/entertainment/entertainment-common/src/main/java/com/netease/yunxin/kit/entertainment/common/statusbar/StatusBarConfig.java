// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.statusbar;

import android.app.Activity;
import android.view.View;
import com.gyf.immersionbar.ImmersionBar;

public class StatusBarConfig {
  private boolean fits;
  private boolean darkFont;
  private boolean fullScreen;
  private int barColor;

  private StatusBarConfig(Builder builder) {
    this.barColor = builder.barColor;
    this.fits = builder.fits;
    this.fullScreen = builder.fullScreen;
    this.darkFont = builder.darkFont;
  }

  public boolean isFits() {
    return fits;
  }

  public boolean isDarkFont() {
    return darkFont;
  }

  public boolean isFullScreen() {
    return fullScreen;
  }

  public int getBarColor() {
    return barColor;
  }

  public static class Builder {
    private boolean fits = false;
    private boolean darkFont = false;
    private boolean fullScreen = false;
    private int barColor = android.R.color.transparent;

    public Builder fitsSystemWindow(boolean fits) {
      this.fits = fits;
      return this;
    }

    public Builder statusBarDarkFont(boolean darkFont) {
      this.darkFont = darkFont;
      return this;
    }

    public Builder fullScreen(boolean fullScreen) {
      this.fullScreen = fullScreen;
      return this;
    }

    public Builder statusBarColor(int barColor) {
      this.barColor = barColor;
      return this;
    }

    public StatusBarConfig build() {
      return new StatusBarConfig(this);
    }
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
    return ImmersionBar.getStatusBarHeight(activity);
  }
}

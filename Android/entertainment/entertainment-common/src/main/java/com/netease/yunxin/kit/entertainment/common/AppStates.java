// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common;

public class AppStates {

  private static class AppStatesHolder {
    private static final AppStates INSTANCE = new AppStates();
  }

  private AppStates() {}

  public static AppStates get() {
    return AppStatesHolder.INSTANCE;
  }

  private boolean isAppRestartInFlight = false;

  public boolean isAppRestartInFlight() {
    return isAppRestartInFlight;
  }

  public void setAppRestartInFlight(boolean appRestartInFlight) {
    isAppRestartInFlight = appRestartInFlight;
  }
}

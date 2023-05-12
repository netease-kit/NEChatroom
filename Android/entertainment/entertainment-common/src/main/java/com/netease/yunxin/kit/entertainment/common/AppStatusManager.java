// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

public class AppStatusManager implements Application.ActivityLifecycleCallbacks {

  //默认被初始化状态，被系统回收(强杀)状态
  public int mAppStatus = AppStatusConstant.STATUS_FORCE_KILLED;;

  public static AppStatusManager mAppStatusManager;
  private Application application;
  //是否前台
  private boolean isForground;
  //Activity运行个数
  private int activeCount;

  private AppStatusManager(Application application) {
    this.application = application;
    application.registerActivityLifecycleCallbacks(this);
  }

  public static void init(Application application) {
    if (mAppStatusManager == null) {
      mAppStatusManager = new AppStatusManager(application);
    }
  }

  public static AppStatusManager getInstance() {
    return mAppStatusManager;
  }

  /**
   * 获取APP状态
   *
   * @return
   */
  public int getAppStatus() {
    return mAppStatus;
  }

  /**
   * 设置APP状态
   *
   * @param appStatus
   */
  public void setAppStatus(int appStatus) {
    this.mAppStatus = appStatus;
  }

  /**
   * 是否前台显示
   *
   * @return
   */
  public boolean isForground() {
    return isForground;
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

  @Override
  public void onActivityStarted(Activity activity) {
    activeCount++;
  }

  @Override
  public void onActivityResumed(Activity activity) {
    isForground = true;
  }

  @Override
  public void onActivityPaused(Activity activity) {}

  @Override
  public void onActivityStopped(Activity activity) {
    activeCount--;
    if (activeCount == 0) {
      isForground = false;
    }
  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

  @Override
  public void onActivityDestroyed(Activity activity) {}

  public void setActiveCount(int activeCount) {
    this.activeCount = activeCount;
  }

  public int getActiveCount() {
    return activeCount;
  }
}

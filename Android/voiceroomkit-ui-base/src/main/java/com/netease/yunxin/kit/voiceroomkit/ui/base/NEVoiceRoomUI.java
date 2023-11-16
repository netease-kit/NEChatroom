// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;
import com.netease.yunxin.kit.voiceroomkit.ui.base.widget.BaseActivityManager;

public class NEVoiceRoomUI {
  private static final String TAG = "NEVoiceRoomUI";
  private static volatile NEVoiceRoomUI instance;
  private Application application;

  private NEVoiceRoomUI() {}

  public static NEVoiceRoomUI getInstance() {
    if (instance == null) {
      synchronized (NEVoiceRoomUI.class) {
        if (instance == null) {
          instance = new NEVoiceRoomUI();
        }
      }
    }
    return instance;
  }

  public Application getApplication() {
    return application;
  }

  public void init(Application application) {
    this.application = application;
    AppStatusManager.init(application);
    //监听activity生命周期
    application.registerActivityLifecycleCallbacks(
        new Application.ActivityLifecycleCallbacks() {
          @Override
          public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            BaseActivityManager.getInstance().addActivity(activity);
          }

          @Override
          public void onActivityStarted(Activity activity) {}

          @Override
          public void onActivityResumed(Activity activity) {}

          @Override
          public void onActivityPaused(Activity activity) {}

          @Override
          public void onActivityStopped(Activity activity) {}

          @Override
          public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

          @Override
          public void onActivityDestroyed(Activity activity) {
            BaseActivityManager.getInstance().removeActivity(activity);
          }
        });
  }
}

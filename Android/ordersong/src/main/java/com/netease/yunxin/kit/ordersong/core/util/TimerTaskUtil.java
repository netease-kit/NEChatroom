// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.util;

import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.copyrightedmedia.utils.SongLog;

/** 定时任务工具类 */
public class TimerTaskUtil {
  private static final String TAG = "TimerTaskUtil";

  private static HandlerThread mThread;
  private static Handler mTimerTaskHandler = null;

  /** 初始化，开启消息队列 */
  public static void init() {
    mThread = new HandlerThread("TimerTaskUtil");
    mThread.start();
    mTimerTaskHandler =
        new Handler(mThread.getLooper()) {
          @Override
          public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            if (msg.obj instanceof Runnable) {
              ((Runnable) msg.obj).run();
            }
          }
        };
  }

  /** 反初始化，停止所有任务 */
  public static void release() {
    if (mThread != null) {
      mThread.quit();
    }
    mTimerTaskHandler = null;
  }

  /**
   * 添加任务
   *
   * @param what 任务类型ID
   * @param runnable
   * @param delayTime 延迟时间
   */
  public static void addTask(int what, Runnable runnable, long delayTime) {
    Message message = Message.obtain();
    message.what = what;
    message.obj = runnable;
    if (mTimerTaskHandler != null) {
      mTimerTaskHandler.removeMessages(what);
      SongLog.i(TAG, "addTask: what = " + what + " :: delayTime = " + delayTime);
      mTimerTaskHandler.sendMessageDelayed(message, delayTime);
    }
  }

  /**
   * 移除任务
   *
   * @param what 类型ID
   */
  public static void removeTask(int what) {
    if (mTimerTaskHandler != null) {
      SongLog.i(TAG, "removeTask: what = " + what);
      mTimerTaskHandler.removeMessages(what);
    }
  }
}

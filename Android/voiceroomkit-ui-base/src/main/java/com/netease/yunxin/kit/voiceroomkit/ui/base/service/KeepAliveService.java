// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.service;

import android.annotation.TargetApi;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;

@TargetApi(21)
public class KeepAliveService extends Service {
  private static final int NOTIFICATION_ID = 1;
  private static final String CHANNEL_ID = "KeepAliveService";

  private SimpleBinder mScreenShareBinder;
  private SimpleNotification simpleNotification;

  public KeepAliveService() {
    mScreenShareBinder = new SimpleBinder();
  }

  @Override
  public IBinder onBind(Intent intent) {
    startForeground();
    return mScreenShareBinder;
  }

  @Override
  public boolean onUnbind(Intent intent) {
    stopForeground(true);
    return super.onUnbind(intent);
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
  }

  private void createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      int importance = NotificationManager.IMPORTANCE_DEFAULT;
      NotificationChannel channel = new NotificationChannel(CHANNEL_ID, CHANNEL_ID, importance);
      channel.setDescription(CHANNEL_ID);
      NotificationManager notificationManager = getSystemService(NotificationManager.class);
      notificationManager.createNotificationChannel(channel);
    }
  }

  private void createNotification() {
    simpleNotification =
        () -> {
          Intent notificationIntent =
              new Intent(getApplicationContext(), getApplicationContext().getClass());
          PendingIntent pendingIntent;
          if (Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            pendingIntent =
                PendingIntent.getActivity(
                    getApplicationContext(), 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
          } else {
            pendingIntent =
                PendingIntent.getActivity(
                    getApplicationContext(), 0, notificationIntent, PendingIntent.FLAG_ONE_SHOT);
          }

          Notification.Builder builder =
              new Notification.Builder(getApplicationContext())
                  .setContentTitle(CHANNEL_ID)
                  .setContentIntent(pendingIntent)
                  .setContentText(CHANNEL_ID);
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setChannelId(CHANNEL_ID);
          }

          return builder.build();
        };
  }

  public class SimpleBinder extends Binder {
    public KeepAliveService getService() {
      return KeepAliveService.this;
    }
  }

  private void startForeground() {

    createNotificationChannel();
    createNotification();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      try {
        startForeground(
            NOTIFICATION_ID,
            simpleNotification.getNotification(),
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION);
      } catch (IllegalArgumentException e) {
        e.printStackTrace();
        stopForeground(true);
        startForeground(NOTIFICATION_ID, simpleNotification.getNotification());
      }

    } else {
      startForeground(NOTIFICATION_ID, simpleNotification.getNotification());
    }
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.Permission;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.common.utils.XKitUtils;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class BluetoothHeadsetUtil {
  private static final String BLUETOOTH_CONNECT_PERMISSION = Manifest.permission.BLUETOOTH_CONNECT;
  private static final String TAG = "BluetoothHeadsetUtil";

  public static final class BluetoothHeadsetStatusReceiver extends BroadcastReceiver {
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final CopyOnWriteArrayList<BluetoothHeadsetStatusObserver> listeners =
        new CopyOnWriteArrayList<>();

    private static BluetoothHeadsetStatusReceiver getInstance() {
      return BluetoothHeadsetStatusReceiver.LazyHolder.INSTANCE;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      ALog.i(TAG, "onReceive,intent:" + intent);
      if (BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED.equals(action)) {
        int state =
            intent.getIntExtra(BluetoothHeadset.EXTRA_STATE, BluetoothHeadset.STATE_DISCONNECTED);

        if (state == BluetoothHeadset.STATE_CONNECTED) {
          for (BluetoothHeadsetStatusObserver listener : listeners) {
            listener.connect();
          }
        } else if (state == BluetoothHeadset.STATE_DISCONNECTED) {
          for (BluetoothHeadsetStatusObserver listener : listeners) {
            listener.disconnect();
          }
        }
      }
    }

    private static class LazyHolder {
      private static final BluetoothHeadsetStatusReceiver INSTANCE =
          new BluetoothHeadsetStatusReceiver();
    }

    public void registerBluetoothHeadsetStatusObserver(BluetoothHeadsetStatusObserver observer) {
      mainHandler.post(
          () -> {
            int preSize = listeners.size();
            listeners.add(observer);
            if (preSize == 0 && listeners.size() == 1) {
              IntentFilter filter = new IntentFilter();
              filter.addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED);
              XKitUtils.getApplicationContext()
                  .registerReceiver(BluetoothHeadsetStatusReceiver.getInstance(), filter);
            }
          });
    }

    public void unregisterBluetoothHeadsetStatusObserver(BluetoothHeadsetStatusObserver observer) {
      mainHandler.post(
          () -> {
            int preSize = listeners.size();
            listeners.remove(observer);
            if (preSize == 1 && listeners.size() == 0) {
              XKitUtils.getApplicationContext()
                  .unregisterReceiver(BluetoothHeadsetStatusReceiver.getInstance());
            }
          });
    }
  }

  public static void registerBluetoothHeadsetStatusObserver(
      final BluetoothHeadsetStatusObserver observer) {
    BluetoothHeadsetStatusReceiver.getInstance().registerBluetoothHeadsetStatusObserver(observer);
  }

  public static void unregisterBluetoothHeadsetStatusObserver(
      final BluetoothHeadsetStatusObserver observer) {
    BluetoothHeadsetStatusReceiver.getInstance().unregisterBluetoothHeadsetStatusObserver(observer);
  }

  @SuppressLint("MissingPermission")
  public static boolean isBluetoothHeadsetConnected() {
    if (BluetoothAdapter.getDefaultAdapter() == null) {
      return false;
    }
    return BluetoothAdapter.getDefaultAdapter().getProfileConnectionState(BluetoothProfile.HEADSET)
        == BluetoothProfile.STATE_CONNECTED;
  }

  public static boolean hasBluetoothConnectPermission(Context context) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
      return true;
    }
    return Permission.hasPermissions(context, BLUETOOTH_CONNECT_PERMISSION);
  }

  public static void requestBluetoothConnectPermission(Context context) {
    Permission.requirePermissions(context, BLUETOOTH_CONNECT_PERMISSION)
        .request(
            new Permission.PermissionCallback() {
              @Override
              public void onGranted(@NonNull List<String> granted) {
                ALog.i(TAG, "BLUETOOTH_CONNECT_PERMISSION onGranted");
              }

              @Override
              public void onDenial(
                  List<String> permissionsDenial, List<String> permissionDenialForever) {
                ALog.e(TAG, "BLUETOOTH_CONNECT_PERMISSION onDenied");
                ToastX.showShortToast("Bluetooth connect permission denied");
              }

              @Override
              public void onException(Exception exception) {}
            });
  }

  public interface BluetoothHeadsetStatusObserver {
    void connect();

    void disconnect();
  }
}

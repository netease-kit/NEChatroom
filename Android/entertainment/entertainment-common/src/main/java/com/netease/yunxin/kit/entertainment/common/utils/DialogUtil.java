// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.app.Activity;
import android.text.TextUtils;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.yunxin.kit.common.ui.dialog.AlertListener;
import com.netease.yunxin.kit.common.ui.dialog.CommonAlertDialog;
import com.netease.yunxin.kit.common.ui.dialog.CommonConfirmDialog;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.dialog.ECCommonConfirmDialog;

public class DialogUtil {
  public static void showAlertDialog(AppCompatActivity activity, String title) {
    showAlertDialog(activity, title, null, () -> {});
  }

  public static void showAlertDialog(
      AppCompatActivity activity, String title, String content, AlertListener listener) {
    if (activity.isFinishing() || activity.getSupportFragmentManager().isDestroyed()) {
      return;
    }
    CommonAlertDialog commonDialog = new CommonAlertDialog();
    commonDialog
        .setTitleStr(title)
        .setPositiveStr(activity.getString(R.string.confirm))
        .setConfirmListener(listener);
    if (!TextUtils.isEmpty(content)) {
      commonDialog.setContent(content);
    }
    commonDialog.show(activity.getSupportFragmentManager());
  }

  public static void showConfirmDialog(
      Activity activity, String title, String content, CommonConfirmDialog.Callback callback) {
    CommonConfirmDialog.Companion.show(activity, title, content, true, true, callback);
  }

  public static void showConfirmDialog(
      Activity activity,
      String title,
      String content,
      String cancel,
      String ok,
      CommonConfirmDialog.Callback callback) {
    if (activity == null || activity.isFinishing()) {
      return;
    }
    CommonConfirmDialog.Companion.show(activity, title, content, cancel, ok, true, true, callback);
  }

  public static void showECConfirmDialog(
      Activity activity,
      String title,
      String content,
      String cancel,
      String ok,
      ECCommonConfirmDialog.Callback callback) {
    if (activity == null || activity.isFinishing()) {
      return;
    }

    ECCommonConfirmDialog.show(activity, title, content, cancel, ok, true, true, callback);
  }
}

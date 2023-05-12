// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.dialog;

import android.content.Context;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.common.ui.dialog.CommonConfirmDialog;
import com.netease.yunxin.kit.entertainment.common.R;

public class ECCommonConfirmDialog extends CommonConfirmDialog {

  protected ECCommonConfirmDialog(@NonNull Context context) {
    super(context, R.style.TransCommonDialogTheme);
  }

  @Override
  public int getLayout() {
    return R.layout.ec_common_confirm_dialog_layout;
  }

  public static void show(
      Context context,
      String title,
      CharSequence message,
      CharSequence cancel,
      CharSequence ok,
      Boolean cancelable,
      Boolean cancelOnTouchOutside,
      Callback callback) {
    ECCommonConfirmDialog dialog = new ECCommonConfirmDialog(context);
    dialog.setTitle(title);
    dialog.setMessage(message);
    dialog.setCancelable(cancelable);
    dialog.setCancel(cancel);
    dialog.setOk(ok);
    dialog.setCanceledOnTouchOutside(cancelOnTouchOutside);
    dialog.setCallback(callback);
    dialog.show();
  }
}

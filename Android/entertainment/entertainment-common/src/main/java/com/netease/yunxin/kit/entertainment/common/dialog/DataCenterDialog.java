// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.Window;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.R;

public class DataCenterDialog extends Dialog {
  public DataCenterDialog(@NonNull Context context) {
    super(context);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Window window = getWindow();
    if (window != null) {
      WindowManager.LayoutParams wlp = window.getAttributes();
      wlp.gravity = Gravity.CENTER;
      wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
      wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
      window.setAttributes(wlp);
      window.setBackgroundDrawableResource(android.R.color.transparent);
    }
    setContentView(R.layout.dialog_data_center);
    setCanceledOnTouchOutside(true);
    setCancelable(true);
    initView();
  }

  private void initView() {
    findViewById(R.id.tv_dialog_negative)
        .setOnClickListener(
            v -> {
              if (dialogCallback != null) {
                dialogCallback.onCancel(this);
              }
            });
    findViewById(R.id.tv_dialog_positive)
        .setOnClickListener(
            v -> {
              if (dialogCallback != null) {
                dialogCallback.onConfirm(this);
              }
            });
  }

  public void setDialogCallback(TipsDialogCallback dialogCallback) {
    this.dialogCallback = dialogCallback;
  }

  private TipsDialogCallback dialogCallback;

  public interface TipsDialogCallback {
    void onConfirm(Dialog dialog);

    void onCancel(Dialog dialog);
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.R;

public class ECAlertDialog extends Dialog {
  private String confirmText;
  private String content;

  public ECAlertDialog(@NonNull Context context) {
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
    setContentView(R.layout.dialog_ec_alert);
    setCanceledOnTouchOutside(true);
    setCancelable(true);
    initView();
  }

  private void initView() {
    findViewById(R.id.tv_dialog_positive)
        .setOnClickListener(
            v -> {
              if (dialogCallback != null) {
                dialogCallback.onConfirm(this);
              }
              dismiss();
            });
    ((TextView) findViewById(R.id.tv_dialog_positive)).setText(getConfirmText());
    ((TextView) findViewById(R.id.tv_dialog_content)).setText(getContent());
  }

  public void setDialogCallback(DialogCallback dialogCallback) {
    this.dialogCallback = dialogCallback;
  }

  public void setConfirmText(String text) {
    confirmText = text;
  }

  public void setContent(String text) {
    content = text;
  }

  private String getConfirmText() {
    if (!TextUtils.isEmpty(confirmText)) {
      return confirmText;
    } else {
      return getContext().getString(R.string.app_sure);
    }
  }

  private String getContent() {
    if (!TextUtils.isEmpty(content)) {
      return content;
    } else {
      return "";
    }
  }

  private DialogCallback dialogCallback;

  public interface DialogCallback {
    void onConfirm(Dialog dialog);
  }
}

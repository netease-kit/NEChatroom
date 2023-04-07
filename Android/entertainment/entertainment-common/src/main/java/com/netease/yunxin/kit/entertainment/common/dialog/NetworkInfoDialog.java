// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.R;

public class NetworkInfoDialog extends Dialog {
  private String content;
  private View rootView;

  public NetworkInfoDialog(@NonNull Context context) {
    super(context);
    rootView = LayoutInflater.from(getContext()).inflate(R.layout.dialog_network_info, null);
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
    setContentView(rootView);
    setCanceledOnTouchOutside(true);
    setCancelable(true);
  }

  public void setContent(String content) {
    this.content = content;
  }

  @Override
  public void show() {
    if (isShowing()) {
      return;
    }

    rootView
        .findViewById(R.id.tv_dialog_positive)
        .setOnClickListener(
            v -> {
              if (dialogCallback != null) {
                dialogCallback.onConfirm(this);
              }
            });
    TextView tvContent = rootView.findViewById(R.id.tv_content);
    tvContent.setMovementMethod(ScrollingMovementMethod.getInstance());
    tvContent.setText(content);
    super.show();
  }

  public void setDialogCallback(TipsDialogCallback dialogCallback) {
    this.dialogCallback = dialogCallback;
  }

  private TipsDialogCallback dialogCallback;

  public interface TipsDialogCallback {
    void onConfirm(Dialog dialog);
  }
}

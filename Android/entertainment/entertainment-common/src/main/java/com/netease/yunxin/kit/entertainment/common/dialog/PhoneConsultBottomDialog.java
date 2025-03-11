// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;
import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.R;

public class PhoneConsultBottomDialog extends Dialog {
  private final String PHONE_NUMBER_SHOW = "4009-000-123";
  private final String PHONE_NUMBER = "4009000123";

  protected Activity activity;
  protected View rootView;

  public PhoneConsultBottomDialog(@NonNull Activity activity) {
    super(activity, R.style.BottomDialogTheme);
    this.activity = activity;
    rootView = LayoutInflater.from(getContext()).inflate(contentLayoutId(), null);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    final Window window = getWindow();
    if (window != null) {
      window.getDecorView().setPadding(0, 0, 0, 0);
      WindowManager.LayoutParams wlp = window.getAttributes();
      wlp.gravity = Gravity.BOTTOM;
      wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
      wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
      window.setAttributes(wlp);
    }

    setContentView(rootView);
    setCanceledOnTouchOutside(true);

    TextView textView = rootView.findViewById(R.id.tv_phone_number);
    textView.setText(PHONE_NUMBER_SHOW);
    textView.setOnClickListener(
        v -> {
          Intent intent = new Intent(Intent.ACTION_CALL);
          Uri data = Uri.parse("tel:" + PHONE_NUMBER);
          intent.setData(data);
          getContext().startActivity(intent);
        });

    rootView.findViewById(R.id.tv_button_cancel).setOnClickListener(v -> cancel());
  }

  protected @LayoutRes int contentLayoutId() {
    return R.layout.dialog_bottom_phone_consult;
  }

  @Override
  public void show() {
    if (isShowing()) {
      return;
    }
    try {
      super.show();
    } catch (WindowManager.BadTokenException e) {
      e.printStackTrace();
    }
  }
}

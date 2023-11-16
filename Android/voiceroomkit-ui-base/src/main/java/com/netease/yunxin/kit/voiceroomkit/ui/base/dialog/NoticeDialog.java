// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.dialog;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;

public class NoticeDialog extends BaseDialogFragment {

  View contentView;

  TextView close;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setStyle(DialogFragment.STYLE_NO_TITLE, R.style.request_dialog_fragment);
  }

  @Nullable
  @Override
  public View onCreateView(
      LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
    if (getDialog() == null) {
      dismiss();
    }
    getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
    contentView = inflater.inflate(R.layout.dialog_notice_layout, container, false);
    return contentView;
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
  }

  @Override
  public void onResume() {
    super.onResume();
    initView();
  }

  private void initView() {
    close = contentView.findViewById(R.id.close);
    close.setOnClickListener(v -> dismiss());
    getDialog()
        .setOnKeyListener(
            (dialog, keyCode, event) -> {
              if (keyCode == KeyEvent.KEYCODE_BACK) {
                return true;
              }
              return false;
            });
  }
}

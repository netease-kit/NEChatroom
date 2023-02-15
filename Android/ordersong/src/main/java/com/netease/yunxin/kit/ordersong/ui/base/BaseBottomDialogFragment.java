// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.ui.base;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import com.netease.yunxin.kit.ordersong.ui.R;

/** */
public abstract class BaseBottomDialogFragment extends BaseDialogFragment {
  @Override
  public void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setStyle(DialogFragment.STYLE_NORMAL, R.style.TransBottomDialogTheme);
  }

  @Nullable
  @Override
  public View onCreateView(
      @NonNull LayoutInflater inflater,
      @Nullable ViewGroup container,
      @Nullable Bundle savedInstanceState) {
    View rootView = inflater.inflate(getResourceLayout(), container, false);
    initView(rootView);
    initIntent();
    return rootView;
  }

  protected void initIntent() {}

  @Override
  public void onStart() {
    super.onStart();
    initParams();
    initData();
  }

  protected abstract int getResourceLayout();

  protected abstract void initView(View rootView);

  protected abstract void initData();

  protected void initParams() {
    Window window = getDialog().getWindow();
    if (window != null) {
      window.setBackgroundDrawableResource(R.drawable.shape_utils_dialog_bg);

      WindowManager.LayoutParams params = window.getAttributes();
      params.gravity = Gravity.BOTTOM;
      // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
      params.width = ViewGroup.LayoutParams.MATCH_PARENT;
      params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
      window.setAttributes(params);
    }
    setCancelable(true); //设置点击外部是否消失
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.widget;

import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import androidx.constraintlayout.widget.ConstraintLayout;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.databinding.ViewTitleBarBinding;

public class TitleBar extends ConstraintLayout {
  private ViewTitleBarBinding binding;

  public TitleBar(Context context) {
    super(context);
    init(context, null);
  }

  public TitleBar(Context context, AttributeSet attrs) {
    super(context, attrs);
    init(context, attrs);
  }

  public TitleBar(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context, attrs);
  }

  private void init(Context context, AttributeSet attrs) {
    binding = ViewTitleBarBinding.inflate(LayoutInflater.from(context), this, true);
    TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.TitleBar);
    String title = typedArray.getString(R.styleable.TitleBar_titleBar_title);
    setTitle(title);
    int titleBgColor = typedArray.getColor(R.styleable.TitleBar_titleBar_title_bg_color, 0xffffff);
    setTitleBgColor(titleBgColor);
    int backIconResId =
        typedArray.getResourceId(
            R.styleable.TitleBar_titleBar_back_icon, R.drawable.icon_left_arrow_dark);
    binding.ivBack.setImageResource(backIconResId);
    initEvent();
    typedArray.recycle();
  }

  private void initEvent() {
    binding.ivBack.setOnClickListener(
        view -> {
          if (getContext() instanceof Activity) {
            ((Activity) getContext()).finish();
          }
        });
  }

  public void setTitle(String title) {
    if (TextUtils.isEmpty(title)) {
      return;
    }
    binding.tvTitle.setText(title);
  }

  private void setTitleBgColor(int color) {
    binding.clRoot.setBackgroundColor(color);
  }
}

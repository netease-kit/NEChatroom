// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.databinding.ViewSettingItemBinding;

public class SettingItemView extends RelativeLayout {
  private ViewSettingItemBinding binding;

  public SettingItemView(Context context) {
    super(context);
    init(context, null);
  }

  public SettingItemView(Context context, AttributeSet attrs) {
    super(context, attrs);
    init(context, attrs);
  }

  public SettingItemView(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context, attrs);
  }

  private void init(Context context, AttributeSet attrs) {
    binding = ViewSettingItemBinding.inflate(LayoutInflater.from(context), this, true);
    TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.SettingItemView);
    int iconDrawableResId =
        typedArray.getResourceId(R.styleable.SettingItemView_setting_item_icon, 0);
    String title = typedArray.getString(R.styleable.SettingItemView_setting_item_title);
    typedArray.recycle();

    setIcon(iconDrawableResId);
    setTitle(title);
  }

  public void setIcon(int resId) {
    if (resId == 0) {
      binding.ivIcon.setVisibility(View.GONE);
    } else {
      binding.ivIcon.setBackgroundResource(resId);
    }
  }

  public void setTitle(String title) {
    if (TextUtils.isEmpty(title)) {
      return;
    }
    binding.tvTitle.setText(title);
  }
}

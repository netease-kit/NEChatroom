// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.floatplay;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.HeadImageView;

public class FloatPlayLayout extends ConstraintLayout {
  private HeadImageView ivAvatar;
  private ImageView ivClose;

  public FloatPlayLayout(@NonNull Context context) {
    super(context);
    init(context);
  }

  public FloatPlayLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public FloatPlayLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context);
  }

  private void init(Context context) {
    LayoutInflater.from(context).inflate(R.layout.voice_float_play_ui, this);
    ivAvatar = findViewById(R.id.iv_avatar);
    ivClose = findViewById(R.id.iv_close);
    ivClose.setOnClickListener(
        v -> {
          if (closeCallback != null) {
            closeCallback.close();
          }
        });
  }

  public void setAvatar(String url) {
    ivAvatar.loadAvatar(url);
  }

  public void setCloseCallback(CloseCallback closeCallback) {
    this.closeCallback = closeCallback;
  }

  private CloseCallback closeCallback;

  public interface CloseCallback {
    void close();
  }
}

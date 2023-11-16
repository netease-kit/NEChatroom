// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.chatroom;

import android.graphics.Paint;
import android.graphics.Paint.FontMetricsInt;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.style.ImageSpan;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class VerticalImageSpan extends ImageSpan {
  private final Drawable drawable1;

  public VerticalImageSpan(Drawable drawable1) {
    super(drawable1);
    this.drawable1 = drawable1;
  }

  @Override
  public int getSize(
      @NonNull Paint paint,
      CharSequence text,
      int start,
      int end,
      @Nullable FontMetricsInt fontMetricsInt) {
    Drawable drawable = getDrawable();
    if (drawable == null) {
      drawable = this.drawable1;
    }
    Rect rect = drawable.getBounds();
    if (fontMetricsInt != null) {
      FontMetricsInt fmPaint = paint.getFontMetricsInt();
      int fontHeight = fmPaint.bottom - fmPaint.top;
      int drHeight = rect.bottom - rect.top;
      int top = drHeight / 2 - fontHeight / 4;
      int bottom = drHeight / 2 + fontHeight / 4;
      fontMetricsInt.ascent = -bottom;
      fontMetricsInt.top = -bottom;
      fontMetricsInt.bottom = top;
      fontMetricsInt.descent = top;
    }
    return rect.right;
  }
}

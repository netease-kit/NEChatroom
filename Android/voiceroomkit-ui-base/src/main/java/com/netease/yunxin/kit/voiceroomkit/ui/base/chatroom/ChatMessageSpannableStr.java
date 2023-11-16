// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.chatroom;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import androidx.annotation.ColorInt;
import androidx.annotation.DrawableRes;
import androidx.core.content.ContextCompat;

public class ChatMessageSpannableStr {

  private final CharSequence messageInfo;

  public ChatMessageSpannableStr(CharSequence messageInfo) {
    this.messageInfo = messageInfo;
  }

  public CharSequence getMessageInfo() {
    return messageInfo;
  }

  static class Builder {
    private final SpannableStringBuilder builder = new SpannableStringBuilder();

    /**
     * 添加 icon 资源
     *
     * @param drawableRes icon 资源id
     */
    public Builder append(Context context, @DrawableRes int drawableRes, int width, int height) {
      Drawable drawable = ContextCompat.getDrawable(context, drawableRes);
      return append(drawable, width, height);
    }

    /**
     * 添加 Icon
     *
     * @param drawable icon 资源
     */
    public Builder append(Drawable drawable, int width, int height) {
      if (drawable != null) {
        drawable.setBounds(0, 0, width, height);
        append(" ", new VerticalImageSpan(drawable));
      }
      return this;
    }

    /**
     * 添加文字同时带有颜色
     *
     * @param content 添加内容
     * @param color 颜色数值
     */
    public Builder append(CharSequence content, @ColorInt int color) {
      append(content, new ForegroundColorSpan(color));
      return this;
    }

    /**
     * 添加CharSequence
     *
     * @param content 添加内容
     */
    public Builder append(CharSequence content) {
      builder.append(content);
      return this;
    }

    /** 构建 ChatMessage */
    public ChatMessageSpannableStr build() {
      return new ChatMessageSpannableStr(builder);
    }

    /** 为 text 添加对应的 span 对象 */
    private void append(CharSequence text, Object what) {
      int start = builder.length();
      if (text != null) {
        builder.append(text);
        builder.setSpan(what, start, builder.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
      }
    }
  }
}

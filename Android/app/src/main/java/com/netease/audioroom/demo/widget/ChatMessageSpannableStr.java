package com.netease.audioroom.demo.widget;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.DynamicDrawableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;

import java.util.Objects;

import androidx.annotation.ColorInt;
import androidx.annotation.DrawableRes;
import androidx.core.content.ContextCompat;

/**
 * Created by luc on 2020/11/10.
 */
public final class ChatMessageSpannableStr {
    private final CharSequence messageInfo;

    public ChatMessageSpannableStr(CharSequence messageInfo) {
        this.messageInfo = messageInfo;
    }

    public CharSequence getMessageInfo() {
        return messageInfo;
    }


    /**
     * 消息构建
     */
    public static class Builder {
        private final SpannableStringBuilder builder;

        public Builder() {
            this.builder = new SpannableStringBuilder();
        }

        /**
         * 添加 icon 资源
         *
         * @param context     app 上下文
         * @param drawableRes icon 资源id
         */
        public Builder append(Context context, @DrawableRes int drawableRes, int width, int height) {
            Drawable drawable = ContextCompat.getDrawable(context, drawableRes);
            Objects.requireNonNull(drawable);
            return append(drawable, width, height);
        }

        /**
         * 添加 Icon
         *
         * @param drawable icon 资源
         */
        public Builder append(Drawable drawable, int width, int height) {
            drawable.setBounds(0, 0, width, height);
            append(" ", new ImageSpan(drawable, DynamicDrawableSpan.ALIGN_BOTTOM));
            return this;
        }

        /**
         * 添加文字同时带有颜色
         *
         * @param content 添加内容
         * @param color   颜色数值
         */
        public Builder append(CharSequence content, @ColorInt int color) {
            append(content, new ForegroundColorSpan(color));
            return this;
        }

        /**
         * 添加文字同时设置文字大小
         *
         * @param content 添加内容
         * @param size    文字大小
         */
        public Builder appendWithSize(CharSequence content, int size) {
            append(content, new AbsoluteSizeSpan(size));
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

        /**
         * 构建 ChatMessage
         */
        public ChatMessageSpannableStr build() {
            return new ChatMessageSpannableStr(builder);
        }

        /**
         * 为 text 添加对应的 span 对象
         */
        public void append(CharSequence text, Object what) {
            int start = builder.length();
            builder.append(text);
            builder.setSpan(what, start, builder.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
        }

    }
}

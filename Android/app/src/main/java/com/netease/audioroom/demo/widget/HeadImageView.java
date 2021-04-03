package com.netease.audioroom.demo.widget;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.nimlib.sdk.nos.model.NosThumbParam;
import com.netease.nimlib.sdk.nos.util.NosThumbImageUtil;
import com.netease.yunxin.android.lib.picture.ImageLoader;


public class HeadImageView extends CircleImageView {

    public static final int DEFAULT_AVATAR_THUMB_SIZE = (int) DemoCache.getContext().getResources().getDimension(R.dimen.avatar_size_default);
    private static final int DEFAULT_AVATAR_RES_ID = R.drawable.nim_avatar_default;

    public HeadImageView(Context context) {
        super(context);
    }

    public HeadImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public HeadImageView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    /**
     * 加载用户头像（默认大小的缩略图）
     *
     * @param url 头像地址
     */
    public void loadAvatar(final String url) {
        doLoadImage(url, DEFAULT_AVATAR_RES_ID, DEFAULT_AVATAR_THUMB_SIZE);
    }

    public void loadAvatar(final String url, int size) {
        doLoadImage(url, DEFAULT_AVATAR_RES_ID, size);
    }


    /**
     * ImageLoader异步加载
     */
    private void doLoadImage(final String url, final int defaultResId, final int thumbSize) {

        resetImageView();

        /*
         * 若使用网易云信云存储，这里可以设置下载图片的压缩尺寸，生成下载URL
         *
         * 如果图片来源是非网易云信云存储，请不要使用NosThumbImageUtil
         */
//        final String thumbUrl = makeAvatarThumbNosUrl(url, thumbSize);
        final String thumbUrl = url;

        ImageLoader.with(getContext().getApplicationContext())
                .asBitmap()
                .load(thumbUrl)
                .error(defaultResId)
                .placeholder(defaultResId)
                .override(thumbSize)
                .into(this);
    }

    /**
     * 解决ViewHolder复用问题
     */
    public void resetImageView() {
        setImageBitmap(null);
    }


    /**
     * 生成头像缩略图NOS URL地址（用作ImageLoader缓存的key）
     */
    private static String makeAvatarThumbNosUrl(final String url, final int thumbSize) {
        if (TextUtils.isEmpty(url)) {
            return url;
        }

        return thumbSize > 0 ? NosThumbImageUtil.makeImageThumbUrl(url, NosThumbParam.ThumbType.Crop, thumbSize, thumbSize) : url;
    }

}

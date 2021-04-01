package com.netease.yunxin.nertc.nertcvoiceroom.model.ktv;

import android.text.TextUtils;

import java.io.Serializable;
import java.util.Objects;

public class Music implements Serializable {

    public String id;//音乐ID

    public String name;//音乐名称

    public String singer;//音乐作者

    public String avatar;//歌曲头像

    public String url;//歌曲地址

    public String lyricUrl;//歌词地址

    public String duration;//时长

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Music music = (Music) o;
        return TextUtils.equals(id, music.id) &&
                TextUtils.equals(name, music.name) &&
                TextUtils.equals(singer, music.singer) &&
                TextUtils.equals(avatar, music.avatar) &&
                TextUtils.equals(url, music.url) &&
                TextUtils.equals(lyricUrl, music.lyricUrl) &&
                TextUtils.equals(duration, music.duration);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, singer, avatar, url, lyricUrl, duration);
    }
}

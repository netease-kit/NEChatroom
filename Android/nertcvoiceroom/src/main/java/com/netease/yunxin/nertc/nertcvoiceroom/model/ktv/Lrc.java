package com.netease.yunxin.nertc.nertcvoiceroom.model.ktv;

/**
 * 歌词
 */
public class Lrc {
    private long time;
    private String text;

    public void setTime(long time) {
        this.time = time;
    }

    public void setText(String text) {
        this.text = text;
    }

    public long getTime() {
        return time;
    }

    public String getText() {
        return text;
    }
}

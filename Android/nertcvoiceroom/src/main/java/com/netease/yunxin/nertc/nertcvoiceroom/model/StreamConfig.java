package com.netease.yunxin.nertc.nertcvoiceroom.model;

import java.io.Serializable;

/**
 * Created by luc on 1/18/21.
 * <p>
 * 主播进行 CDN 模式下，推拉流配置信息
 */
public class StreamConfig implements Serializable {

    /**
     * 主播推流地址
     */
    public final String pushUrl;

    /**
     * 观众拉流地址（下面三个都是拉流地址，用户可按需求选择使用对应拉流协议）
     */
    public final String httpPullUrl;
    public final String rtmpPullUrl;
    public final String hlsPullUrl;

    public StreamConfig(String pushUrl, String httpPullUrl, String rtmpPullUrl, String hlsPullUrl) {
        this.pushUrl = pushUrl;
        this.httpPullUrl = httpPullUrl;
        this.rtmpPullUrl = rtmpPullUrl;
        this.hlsPullUrl = hlsPullUrl;
    }
}

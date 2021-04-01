package com.netease.yunxin.nertc.nertcvoiceroom.model;

/**
 * Created by luc on 1/18/21.
 * <p>
 * CDN 模式下推流控制
 */
public interface StreamTaskControl {

    /**
     * 添加推流任务
     *
     * @param uid     rtc 房间用户id
     * @param pushUrl 推流地址
     */
    void addStreamTask(long uid, String pushUrl);

    /**
     * 移除当前推流任务
     */
    void removeStreamTask();

    /**
     * 添加混流用户
     *
     * @param uid rtc 房间用户id
     */
    void addMixStreamUser(long uid);

    /**
     * 移除混流用户
     *
     * @param uid rtc 房间用户id
     */
    void removeMixStreamUser(long uid);
}

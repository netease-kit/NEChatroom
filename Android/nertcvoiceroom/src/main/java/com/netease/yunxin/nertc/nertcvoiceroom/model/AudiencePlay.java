package com.netease.yunxin.nertc.nertcvoiceroom.model;

/**
 * Created by luc on 1/18/21.
 */
public interface AudiencePlay {

    void play(String url);

    void pause();

    boolean isPaused();

    void resume();

    void stop();

    void release();

    void setVolume(float volume);

    float getVolume();

    boolean isReleased();

    void registerNotify(PlayerNotify notify);

    /**
     * 自定义封装播放器回调
     */
    interface PlayerNotify {
        /**
         * 播放器开始准备阶段调用
         */
        void onPreparing();

        /**
         * 播放器完成准备刚进入播放时回调
         */
        void onPlaying();

        /**
         * 拉流过程中出现错误或设置拉流地址有误回调
         */
        void onError();
    }
}

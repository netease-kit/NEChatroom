package com.netease.yunxin.nertc.nertcvoiceroom.model;

/**
 * 播放操作接口
 */
public interface AudioPlay {
    /**
     * 设置伴音音量（播放和发送音量）
     *
     * @param volume 混音音量 0-100
     */
    void setMixingVolume(int volume);

    /**
     * 设置伴音文件
     *
     * @param paths 伴音文件路径数组
     * @return 设置成功
     */
    boolean setMixingFile(String[] paths);

    /**
     * 设置伴音文件
     *
     * @param index 伴音文件索引
     * @param path  伴音文件路径
     * @return 设置成功
     */
    boolean setMixingFile(int index, String path);

    /**
     * 获取伴音文件
     *
     * @param index 伴音文件索引
     * @return 伴音文件路径
     */
    String getMixingFile(int index);

    /**
     * 播放或暂停当前伴音文件
     *
     * @return 动作成功
     */
    boolean playOrPauseMixing();

    /**
     * 播放下一个伴音文件（循环模式）
     *
     * @return 动作成功
     */
    boolean playNextMixing();

    /**
     * 播放伴音文件
     *
     * @param index 伴音文件索引
     * @return 动作成功
     */
    boolean playMixing(int index);

    /**
     * 设置音效音量（播放和发送音量）
     *
     * @param volume 音效音量 0-100
     */
    void setEffectVolume(int volume);

    /**
     * 设置音效文件
     *
     * @param paths 音效文件路径数组
     * @return 设置成功
     */
    boolean setEffectFile(String[] paths);

    /**
     * 播放音效文件
     *
     * @param index 音效文件索引
     * @return 动作成功
     */
    boolean playEffect(int index);

    /**
     * 伴音播放状态
     */
    interface AudioMixingPlayState {
        /**
         * 停止，未播放
         */
        int STATE_STOPPED = 0;

        /**
         * 播放中
         */
        int STATE_PLAYING = 1;

        /**
         * 暂停
         */
        int STATE_PAUSED = 2;
    }

    /**
     * 播放回调（伴音，音效）
     */
    interface Callback {
        /**
         * 伴音播放状态
         *
         * @param state     {@link com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay.AudioMixingPlayState 播放状态}
         * @param index 伴音文件索引
         */
        void onAudioMixingPlayState(int state, int index);

        /**
         * 伴音播放错误
         */
        void onAudioMixingPlayError();

        /**
         * 音效播放完成
         *
         * @param index 音效文件索引
         */
        void onAudioEffectPlayFinished(int index);
    }

    /**
     * 设置播放回调
     *
     * @param callback     {@link com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay.Callback 回调}
     */
    void setCallback(Callback callback);
}

package com.netease.yunxin.nertc.nertcvoiceroom.model;

import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicOrderedItem;

/**
 * 播放操作接口
 */
public interface AudioPlay {
    /**
     * 设置伴音音量（播放和发送音量）
     *
     * @param volume 混音音量 0-100
     * @param isKtv  是否ktv
     */
    void setMixingVolume(int volume, boolean isKtv);

    /**
     * 停止KTV唱歌
     *
     * @param needSetStatus 是否需要设置状态
     * @param stopMixing    停止伴音
     */
    void onSingFinish(boolean needSetStatus, boolean stopMixing);

    /**
     * KTV开始唱歌（自己或者他人）
     */
    void onSingStart();

    /**
     * KTV模式混音
     *
     * @param music
     * @return
     */
    int setKtvMusicPlay(MusicOrderedItem music);

    /**
     * ktv 暂停
     *
     * @return
     */
    int pauseKtvMusic();

    /**
     * 恢复 ktv
     *
     * @return
     */
    int resumeKtvMusic();

    /**
     * 停止ktv
     *
     * @return
     */
    int stopKtvMusic();

    /**
     * 获取当前伴音音量
     */
    int getMixingVolume(boolean isKtv);

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
     * 停止音效文件播放
     *
     * @param index 音效文件索引
     * @return 动作结果
     */
    boolean stopEffect(int index);

    /**
     * 停止所有音效文件播放
     *
     * @return 动作结果
     */
    boolean stopAllEffects();

    /**
     * 获取当前播放状态
     *
     * @return {@link AudioMixingPlayState}
     * */
    int getCurrentState();

    /**
     * 获取当前正在播放伴音 index
     */
    int getPlayingMixIndex();

    /**
     * 播放状态初始化
     */
    void reset();

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

        /**
         * 混音重置
         */
        void onAudioReset();

        /**
         * 错误信息
         *
         * @param msg
         */
        void onError(String msg);
    }

    /**
     * 设置播放回调
     *
     * @param callback     {@link com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay.Callback 回调}
     */
    void setCallback(Callback callback);
}

package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioEffectOption;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption;

import java.util.Arrays;

import static com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay.AudioMixingPlayState.STATE_PAUSED;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay.AudioMixingPlayState.STATE_PLAYING;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay.AudioMixingPlayState.STATE_STOPPED;

import com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay;

class AudioPlayImpl implements AudioPlay {
    private final NERtcEx engine;

    private Callback callback;

    /**
     * 混音音量
     */
    private int audioMixingVolume = 100;

    /**
     * 混音文件
     */
    private String[] audioMixingFilePaths;

    /**
     * 当前混音
     */
    private int audioMixingIndex = 0;

    /**
     * 混音播放状态
     */
    private int audioMixingState = STATE_STOPPED;

    /**
     * 音效音量
     */
    private int effectVolume = 100;

    /**
     * 音效文件
     */
    private String[] effectPaths;

    AudioPlayImpl(NERtcEx engine) {
        this.engine = engine;
    }

    @Override
    public void setCallback(Callback callback) {
        this.callback = callback;
    }

    @Override
    public void setMixingVolume(int volume) {
        engine.setAudioMixingSendVolume(volume);
        engine.setAudioMixingPlaybackVolume(volume);
        audioMixingVolume = volume;
    }

    @Override
    public boolean setMixingFile(String[] paths) {
        if (audioMixingFilePaths != null) {
            return false;
        }
        if (paths == null || paths.length == 0) {
            return false;
        }
        audioMixingFilePaths = Arrays.copyOf(paths, paths.length);
        return true;
    }

    @Override
    public boolean setMixingFile(int index, String path) {
        if (audioMixingFilePaths == null
                || index < 0 || index >= audioMixingFilePaths.length) {
            return false;
        }
        audioMixingFilePaths[index] = path;
        return false;
    }

    @Override
    public String getMixingFile(int index) {
        if (audioMixingFilePaths == null
                || index < 0 || index >= audioMixingFilePaths.length) {
            return null;
        }
        return audioMixingFilePaths[index];
    }

    @Override
    public boolean playOrPauseMixing() {
        return shiftPlayState();
    }

    @Override
    public boolean playNextMixing() {
        stopAudioMixing();
        audioMixingIndex = getNextAudioMixingIndex(audioMixingIndex, audioMixingFilePaths);

        return shiftPlayState();
    }

    @Override
    public boolean playMixing(int index) {
        if (isAudioMixingIndexInvalid(index, audioMixingFilePaths)) {
            return false;
        }

        stopAudioMixing();
        audioMixingIndex = index;

        return shiftPlayState();
    }

    /**
     * STATE_PLAYING -> STATE_PAUSED
     * STATE_PAUSED  -> STATE_PLAYING
     * STATE_STOPPED -> STATE_PLAYING
     */
    private boolean shiftPlayState() {
        int stateOld = audioMixingState;
        int stateNew;
        int result;
        if (stateOld == STATE_PLAYING) {
            stateNew = STATE_PAUSED;
            result = engine.pauseAudioMixing();
        } else if (stateOld == STATE_PAUSED) {
            stateNew = STATE_PLAYING;
            result = engine.resumeAudioMixing();
        } else {
            stateNew = STATE_PLAYING;
            NERtcCreateAudioMixingOption option = new NERtcCreateAudioMixingOption();
            option.path = audioMixingFilePaths[audioMixingIndex];
            option.playbackVolume = audioMixingVolume;
            option.sendVolume = audioMixingVolume;
            result = engine.startAudioMixing(option);
        }
        if (result == 0) {
            audioMixingState = stateNew;
            notifyAudioMixingState();
        }
        return result == 0;
    }

    private void stopAudioMixing() {
        engine.stopAudioMixing();
        audioMixingState = STATE_STOPPED;
        notifyAudioMixingState();
    }

    private void notifyAudioMixingState() {
        if (callback != null) {
            callback.onAudioMixingPlayState(audioMixingState, audioMixingIndex);
        }
    }

    private void onAudioMixingError() {
        stopAudioMixing();
        if (callback != null) {
            callback.onAudioMixingPlayError();
        }
    }

    void onAudioMixingStateChanged(int reason) {
        switch (reason) {
            case 0:
                playNextMixing();
                break;
            case 1:
                onAudioMixingError();
                break;
        }
    }

    void onAudioEffectFinished(int effectId) {
        if (callback != null) {
            callback.onAudioEffectPlayFinished(effectIdToEffectIndex(effectId));
        }
    }

    @Override
    public void setEffectVolume(int volume) {
        for (int index = 0; index < effectPaths.length; index++) {
            int effectId = effectIndexToEffectId(index);
            engine.setEffectPlaybackVolume(effectId, volume);
            engine.setEffectSendVolume(effectId, volume);
        }
        effectVolume = volume;
    }

    @Override
    public boolean setEffectFile(String[] paths) {
        if (effectPaths != null) {
            return false;
        }
        if (paths == null || paths.length == 0) {
            return false;
        }
        effectPaths = Arrays.copyOf(paths, paths.length);
        return true;
    }

    @Override
    public boolean playEffect(int index) {
        String path = null;
        if (effectPaths == null // not set
                || index < 0 || index >= effectPaths.length // out of bound
                || TextUtils.isEmpty((path = effectPaths[index]))) { // not set
            return false;
        }
        int effectId = effectIndexToEffectId(index);

        NERtcCreateAudioEffectOption option = new NERtcCreateAudioEffectOption();
        option.path = path;
        option.loopCount = 1; // once
        option.sendVolume = effectVolume;
        option.playbackVolume = effectVolume;
        engine.stopEffect(effectId);
        return engine.playEffect(effectId, option) == 0;
    }

    private static int getNextAudioMixingIndex(int index, @NonNull String[] paths) {
        do {
            index = (index + 1) % paths.length;
        } while (isAudioMixingIndexInvalid(index, paths));
        return index;
    }

    private static boolean isAudioMixingIndexInvalid(int index, @NonNull String[] paths) {
        return index < 0 || index >= paths.length
                || TextUtils.isEmpty(paths[index]);
    }

    private static int effectIdToEffectIndex(int id) {
        return id - 1;
    }

    private static int effectIndexToEffectId(int index) {
        return index + 1; // effect id starts from one
    }
}

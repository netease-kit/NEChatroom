package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

import android.content.Context;
import android.media.AudioManager;

import com.netease.yunxin.kit.alog.ALog;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcParameters;
import com.netease.yunxin.nertc.nertcvoiceroom.model.AudiencePlay;
import com.netease.yunxin.nertc.nertcvoiceroom.model.PushTypeSwitcher;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;

/**
 * Created by luc on 1/19/21.
 */
public class PushTypeSwitcherImpl implements PushTypeSwitcher {
    private final NERtcEx engine;
    private final AudiencePlay audiencePlay;
    private final AudioManager audioManager;

    private final int MAX_MUSIC_VOLUME;
    private final int MIN_MUSIC_VOLUME;

    private final int MAX_CALL_VOLUME;
    private final int MIN_CALL_VOLUME;

    private float currentVolume;

    public PushTypeSwitcherImpl(Context context, NERtcEx engine, AudiencePlay audiencePlay) {
        this.engine = engine;
        this.audiencePlay = audiencePlay;
        this.audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);

        MAX_MUSIC_VOLUME = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        MIN_MUSIC_VOLUME = audioManager.getStreamMinVolume(AudioManager.STREAM_MUSIC);

        MAX_CALL_VOLUME = audioManager.getStreamMaxVolume(AudioManager.STREAM_VOICE_CALL);
        MIN_CALL_VOLUME = audioManager.getStreamMinVolume(AudioManager.STREAM_VOICE_CALL);
    }

    @Override
    public void toCDN(String url) {
        audiencePlay.play(url);
        audiencePlay.setVolume(currentVolume);
        engine.leaveChannel();
        engine.enableLocalAudio(false);
        // 获取 communication 音量填充至 music
        int volumeIndex = audioManager.getStreamVolume(AudioManager.STREAM_VOICE_CALL);
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, getMusicVolumeIndex(volumeIndex), AudioManager.FLAG_REMOVE_SOUND_AND_VIBRATE);
    }

    @Override
    public void toRTC(VoiceRoomInfo roomInfo, long uid) {
        // 设置加入房间时通话质量
        engine.setAudioProfile(NERtcConstants.AudioProfile.HIGH_QUALITY, NERtcConstants.AudioScenario.CHATROOM);
        // 设置加入房间自动订阅音频流
        NERtcParameters parameters = new NERtcParameters();
        parameters.setBoolean(NERtcParameters.KEY_AUTO_SUBSCRIBE_AUDIO, true);
        parameters.set(NERtcParameters.KEY_PUBLISH_SELF_STREAM, true);
        NERtcEx.getInstance().setParameters(parameters);
        // 设置本地音频采集
        engine.enableLocalAudio(true);
        int result = engine.joinChannel(null, roomInfo.getRoomId(), uid);
        ALog.e("====>", "join channel code is " + result);
        currentVolume = audiencePlay.getVolume();
        audiencePlay.release();
        int volumeIndex = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
        audioManager.setStreamVolume(AudioManager.STREAM_VOICE_CALL, getCallVolumeIndex(volumeIndex), AudioManager.FLAG_REMOVE_SOUND_AND_VIBRATE);
        // 获取music 音量填充至 communication
    }

    private int getMusicVolumeIndex(int indexFromCall) {
        int index = indexFromCall * (MAX_MUSIC_VOLUME - MIN_MUSIC_VOLUME) / (MAX_CALL_VOLUME - MIN_CALL_VOLUME);

        if (index >= MAX_MUSIC_VOLUME) {
            return MAX_MUSIC_VOLUME;
        }
        if (index <= MIN_MUSIC_VOLUME) {
            return MIN_MUSIC_VOLUME;
        }
        return index;
    }

    private int getCallVolumeIndex(int indexFromMusic) {
        int index = indexFromMusic * (MAX_CALL_VOLUME - MIN_CALL_VOLUME) / (MAX_MUSIC_VOLUME - MIN_MUSIC_VOLUME);

        if (index >= MAX_CALL_VOLUME) {
            return MAX_CALL_VOLUME;
        }
        if (index <= MIN_CALL_VOLUME) {
            return MIN_CALL_VOLUME;
        }
        return index;
    }
}

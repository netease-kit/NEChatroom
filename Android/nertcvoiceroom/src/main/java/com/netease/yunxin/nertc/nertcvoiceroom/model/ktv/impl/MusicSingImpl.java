package com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.impl;

import android.text.TextUtils;

import com.blankj.utilcode.util.GsonUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.chatroom.ChatRoomMessageBuilder;
import com.netease.nimlib.sdk.chatroom.ChatRoomService;
import com.netease.nimlib.sdk.util.Entry;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Audience;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomMessage;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.CustomAttachmentType;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.MusicControl;
import com.netease.yunxin.nertc.nertcvoiceroom.model.impl.NERtcVoiceRoomImpl;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.LyricListener;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.Music;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicChangeListener;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicOrderedItem;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class MusicSingImpl extends MusicSing {

    private static final int MOST_MUSIC_ORDER_NUM = 99;

    private static final int MOST_MUSIC_ONE_USER_ORDER = 20;

    private static final String LOG_TAG = "NERtcVoiceRoomImpl";

    public static final String KEY_BASE = "music_";

    private ChatRoomService chatRoomService;

    private String roomId;

    private static MusicSingImpl instance;

    private VoiceRoomUser userInfo;//自己的用户信息

    private List<MusicOrderedItem> orderedMusics;

    private List<MusicOrderedItem> selfOrderedMusic;

    private LyricListener lyricListener;

    private List<MusicChangeListener> musicChangeListeners;

    private MusicOrderedItem currentMusic;

    private boolean isAnchor;//是否是主播

    private Audience audience;//观众信息

    private NERtcVoiceRoomDef.RoomCallback roomCallback;

    public static synchronized MusicSingImpl shareInstance() {
        if (instance == null) {
            instance = new MusicSingImpl();
        }
        return instance;
    }

    private MusicSingImpl() {
        orderedMusics = new CopyOnWriteArrayList<>();
        musicChangeListeners = new LinkedList<>();
        selfOrderedMusic = new LinkedList<>();
    }

    @Override
    public void initRoom(ChatRoomService chatRoomService, VoiceRoomUser userInfo, String roomId) {
        this.chatRoomService = chatRoomService;
        this.roomId = roomId;
        this.userInfo = userInfo;
    }

    @Override
    public void setAudienceInfo(boolean isAnchor, Audience audience) {
        this.isAnchor = isAnchor;
        this.audience = audience;
    }

    @Override
    public void setRoomCallback(NERtcVoiceRoomDef.RoomCallback roomCallback) {
        this.roomCallback = roomCallback;
    }

    private boolean equalCurrentMusic(MusicOrderedItem music) {
        if (currentMusic == null || music == null) {
            return false;
        }
        return TextUtils.equals(currentMusic.getKey(), music.getKey());
    }


    @Override
    public void addMusic(final Music music, final RequestCallback<Void> callback) {
        if (!contextCheck()) {
            return;
        }

        if (!isAnchor && !isAudienceSeatOn()) {
            showError("需要上麦才能唱歌");
            return;
        }
        if (orderedMusics.size() >= MOST_MUSIC_ORDER_NUM) {
            showError("歌单最多99首哦");
            return;
        }
        if (selfOrderedMusic.size() >= MOST_MUSIC_ONE_USER_ORDER) {
            showError("每人最多点20首哦");
            return;
        }
        final MusicOrderedItem musicOrderedItem = new MusicOrderedItem(userInfo, music);
        if (selfOrderedMusic.contains(musicOrderedItem)) {
            showError("该歌曲已经点过");
            return;
        }
        chatRoomService.updateQueueEx(roomId, getKey(music), GsonUtils.toJson(musicOrderedItem), true).setCallback(
                new RequestCallback<Void>() {
                    @Override
                    public void onSuccess(Void param) {
                        ALog.i(LOG_TAG, "add music success music = " + music.toString());
                        if (callback != null) {
                            callback.onSuccess(param);
                        }
                    }

                    @Override
                    public void onFailed(int code) {
                        if (callback != null) {
                            callback.onFailed(code);
                        }
                    }

                    @Override
                    public void onException(Throwable exception) {
                        if (callback != null) {
                            callback.onException(exception);
                        }
                    }
                });
    }

    private boolean isAudienceSeatOn() {
        return audience.getSeat() != null && audience.getSeat().isOn();
    }

    private void showError(String msg) {
        if (musicChangeListeners.size() > 0) {
            for (MusicChangeListener listener : musicChangeListeners) {
                listener.onError(msg);
            }
        }
    }

    @Override
    public void sendCustomMessage(MusicControl customMessage) {
        chatRoomService.sendMessage(ChatRoomMessageBuilder.createChatRoomCustomMessage(roomId, customMessage), false);
        if (roomCallback != null) {
            VoiceRoomMessage msg = VoiceRoomMessage.createEventMessage(
                    NERtcVoiceRoomImpl.getMessageTextBuilder().musicEvent(customMessage.operator, customMessage.getType() == CustomAttachmentType.MUSIC_PAUSE));
            roomCallback.onVoiceRoomMessage(msg);
        }
    }


    @Override
    public void removeMusic(final MusicOrderedItem music, final RequestCallback<Void> callback) {
        if (!contextCheck()) {
            return;
        }
        chatRoomService.pollQueue(roomId, music.getKey()).setCallback(
                new RequestCallbackWrapper<Entry<String, String>>() {

                    @Override
                    public void onResult(int code, Entry<String, String> result, Throwable exception) {
                        ALog.i(LOG_TAG, "removeMusic musicKey = " + music.getKey() + " result code = " + code);
                        if (callback != null) {
                            callback.onSuccess(null);
                        }
                    }
                });
    }

    @Override
    public void nextMusic(RequestCallback<Void> callback) {
        if (!contextCheck()) {
            return;
        }
        if (orderedMusics != null && orderedMusics.size() > 0) {
            removeMusic(orderedMusics.get(0), callback);
        } else if (callback != null) {
            callback.onFailed(-1);
        }
    }

    private void postValues() {
        if (musicChangeListeners.size() == 0) {
            return;
        }
        for (MusicChangeListener listener : musicChangeListeners) {
            postValue(listener, false);
        }
        if (orderedMusics.size() > 0) {
            currentMusic = orderedMusics.get(0);
        } else {
            currentMusic = null;
        }
    }

    private void postValue(MusicChangeListener listener, boolean isInit) {
        listener.onListChange(orderedMusics, isInit);
        ALog.i(LOG_TAG, "postValue");
        if (orderedMusics.size() > 0) {
            MusicOrderedItem topMusic = orderedMusics.get(0);
            if (equalCurrentMusic(topMusic)) {
                ALog.i(LOG_TAG, "postValue  music not change");
                return;
            }
            ALog.i(LOG_TAG, "postValue  music change");
            boolean isMy = TextUtils.equals(topMusic.userId, userInfo.account);
            listener.onSongChange(topMusic, isMy, isInit);
        } else {
            listener.onSongChange(null, false, isInit);
        }
    }

    @Override
    public void fetchSongs(final RequestCallback<List<MusicOrderedItem>> callback) {
        if (!contextCheck()) {
            return;
        }
        chatRoomService.fetchQueue(roomId).setCallback(new RequestCallback<List<Entry<String, String>>>() {

            @Override
            public void onSuccess(List<Entry<String, String>> param) {
                List<MusicOrderedItem> musics = getOrderMusic(param);
                orderedMusics.clear();
                if (musics != null && musics.size() > 0) {
                    orderedMusics.addAll(musics);
                }
                resetSelfOrdered();
                if (orderedMusics.size() == 0) {
                    currentMusic = null;
                }
                postValues();
                if (callback != null) {
                    callback.onSuccess(musics);
                }
            }

            @Override
            public void onFailed(int code) {
                if (callback != null) {
                    callback.onFailed(code);
                }
            }

            @Override
            public void onException(Throwable exception) {
                if (callback != null) {
                    callback.onException(exception);
                }
            }
        });
    }

    @Override
    public void addSongFromQueue(String musicString) {
        try {
            MusicOrderedItem music = GsonUtils.fromJson(musicString, MusicOrderedItem.class);
            if (music == null || orderedMusics.contains(music)) {
                return;
            }
            orderedMusics.add(music);
            if (TextUtils.equals(music.userId, userInfo.account)) {
                selfOrderedMusic.add(music);
            }
            postValues();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void removeSongFromQueue(String musicString) {
        try {
            MusicOrderedItem music = GsonUtils.fromJson(musicString, MusicOrderedItem.class);
            if (music == null) {
                return;
            }
            orderedMusics.remove(music);
            if (TextUtils.equals(music.userId, userInfo.account)) {
                selfOrderedMusic.remove(music);
            }
            if (orderedMusics.size() == 0) {
                currentMusic = null;
            }
            postValues();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void resetSelfOrdered() {
        selfOrderedMusic.clear();
        for (MusicOrderedItem music : orderedMusics) {
            if (TextUtils.equals(music.userId, userInfo.account)) {
                selfOrderedMusic.add(music);
            }
        }
    }

    @Override
    public void updateMusicTime(MusicOrderedItem music, int time) {
        if (!contextCheck()) {
            return;
        }
        music.setCountTimeSec(time);
        chatRoomService.updateQueueEx(roomId, music.getKey(), GsonUtils.toJson(music), true);
    }

    @Override
    public void updateStatusAndTimestamp(MusicOrderedItem music, int status, long timestamp) {
        if (!contextCheck()) {
            return;
        }
        MusicOrderedItem targetMusic = (music == null ? currentMusic : music);
        targetMusic.setStatus(status);
        targetMusic.setTimestamp(timestamp);
        chatRoomService.updateQueueEx(roomId, targetMusic.getKey(), GsonUtils.toJson(targetMusic), true);
    }

    @Override
    public void update() {
        fetchSongs(null);
    }

    @Override
    public void setLyricListener(LyricListener lyricListener) {
        this.lyricListener = lyricListener;
    }

    @Override
    public void addMusicChangeListener(MusicChangeListener musicChangeListener) {
        if (musicChangeListener == null) {
            //voice chat mode
            return;
        }
        musicChangeListeners.add(musicChangeListener);
        postValue(musicChangeListener, true);
        if (orderedMusics.size() > 0) {
            currentMusic = orderedMusics.get(0);
        }
    }

    @Override
    public void removeMusicChangeListener(MusicChangeListener musicChangeListener) {
        musicChangeListeners.remove(musicChangeListener);
    }

    @Override
    public void receiveSEIMsg(long timestampMs) {
        if (lyricListener != null) {
            lyricListener.onReceiveSeiTimestamp(timestampMs);
        }
    }

    @Override
    public void reset() {
        orderedMusics.clear();
        musicChangeListeners.clear();
        currentMusic = null;
        selfOrderedMusic.clear();
    }

    @Override
    public void leaveSet(VoiceRoomUser user, boolean isSelf) {
        for (MusicOrderedItem music : orderedMusics) {
            if (TextUtils.equals(music.userId, user.account)) {
                orderedMusics.remove(music);
                if (TextUtils.equals(music.userId, userInfo.account)) {
                    selfOrderedMusic.remove(music);
                }
                if (!isSelf) {
                    removeMusic(music, null);
                }
            }
        }
        postValues();
    }

    /**
     * 检查上下文
     *
     * @return
     */
    private boolean contextCheck() {
        if (chatRoomService == null || TextUtils.isEmpty(roomId) || userInfo == null || audience == null) {
            showError("点歌服务数据错误，请确保正确初始化");
            return false;
        }
        return true;
    }

    /**
     * 获取歌单
     *
     * @param listParam
     * @return
     */
    private List<MusicOrderedItem> getOrderMusic(List<Entry<String, String>> listParam) {
        if (listParam == null) {
            return null;
        }
        List<MusicOrderedItem> musicOrder = new ArrayList<>();
        try {
            for (Entry<String, String> entry : listParam) {
                if (isMusicKey(entry.key)) {
                    musicOrder.add(GsonUtils.fromJson(entry.value, MusicOrderedItem.class));
                }
            }
        } catch (Exception e) {
            ALog.e(LOG_TAG, "json parse error", e);
            return null;
        }
        return musicOrder;
    }

    private String getKey(Music music) {
        return KEY_BASE + music.id + "_" + userInfo.account;
    }


    public static boolean isMusicKey(String key) {
        return key.startsWith(KEY_BASE);
    }
}

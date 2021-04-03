package com.netease.yunxin.nertc.nertcvoiceroom.model.ktv;

import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.chatroom.ChatRoomService;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Audience;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.MusicControl;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.impl.MusicSingImpl;

import java.util.List;

/**
 * 歌曲控制平台
 */
public abstract class MusicSing {

    public static synchronized MusicSing shareInstance(){
        return MusicSingImpl.shareInstance();
    }

    /**
     * 初始化，调用一次
     *
     * @param chatRoomService
     * @param userInfo
     * @param roomId
     */
    public abstract void initRoom(ChatRoomService chatRoomService, VoiceRoomUser userInfo, String roomId);

    /**
     * 设置观众信息
     *
     * @param isAnchor
     * @param audience
     */
    public abstract void setAudienceInfo(boolean isAnchor, Audience audience);

    /**
     * 设置回调
     *
     * @param roomCallback
     */
    public abstract void setRoomCallback(NERtcVoiceRoomDef.RoomCallback roomCallback);

    /**
     * 点歌
     */
    public abstract void addMusic(Music music, final RequestCallback<Void> callback);

    /**
     * 发送自定义音乐控制消息
     *
     * @param customMessage
     */
    public abstract void sendCustomMessage(MusicControl customMessage);

    /**
     * 删除已点歌曲
     */
    public abstract void removeMusic(MusicOrderedItem music, final RequestCallback<Void> callback);

    /**
     * 切歌
     *
     * @param callback
     */
    public abstract void nextMusic(final RequestCallback<Void> callback);


    /**
     * 获取已点歌单
     *
     * @param callback
     */
    public abstract void fetchSongs(final RequestCallback<List<MusicOrderedItem>> callback);

    /**
     * 远端队列新增元素处理
     *
     * @param musicString
     */
    public abstract void addSongFromQueue(final String musicString);

    /**
     * 远端队列删除元素处理
     *
     * @param musicString
     */
    public abstract void removeSongFromQueue(final String musicString);

    /**
     * 更新
     */
    public abstract void update();

    /**
     * 更新歌曲的倒计时
     *
     * @param music
     * @param time
     */
    public abstract void updateMusicTime(MusicOrderedItem music, int time);

    /**
     * 更新状态
     *
     * @param music
     * @param status    状态
     * @param timestamp 歌词sei的位置
     */
    public abstract void updateStatusAndTimestamp(MusicOrderedItem music, int status, long timestamp);

    /**
     * 设置歌词进度回调
     *
     * @param lyricListener
     */
    public abstract void setLyricListener(LyricListener lyricListener);

    /**
     * 添加歌曲监听
     *
     * @param musicChangeListener
     */
    public abstract void addMusicChangeListener(MusicChangeListener musicChangeListener);

    /**
     * 删除监听
     *
     * @param musicChangeListener
     */
    public abstract void removeMusicChangeListener(MusicChangeListener musicChangeListener);

    /**
     * 收到sei歌词进度
     *
     * @param time
     */
    public abstract void receiveSEIMsg(long time);

    /**
     * 重置
     */
    public abstract void reset();

    /**
     * 用户下麦
     *
     * @param user
     * @param isSelf 是否是自己下麦
     */
    public abstract void leaveSet(VoiceRoomUser user, boolean isSelf);

}

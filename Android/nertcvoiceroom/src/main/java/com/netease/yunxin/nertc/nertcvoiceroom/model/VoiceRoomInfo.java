package com.netease.yunxin.nertc.nertcvoiceroom.model;

import java.io.Serializable;

/**
 * 语聊房信息
 */
public class VoiceRoomInfo implements Serializable {

    /**
     * 房间id
     */
    private String roomId;

    /**
     * 创建者（主播）账号
     */
    private String creatorAccount;

    /**
     * 房间名
     */
    private String name;

    /**
     * 房间缩略图
     */
    private String thumbnail;

    /**
     * 房间type
     */
    private int roomType;

    /**
     * 房间音质 {@link com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.RoomAudioQuality}
     */
    private int audioQuality = NERtcVoiceRoomDef.RoomAudioQuality.DEFAULT_QUALITY;

    /**
     * 房间在线用户数
     */
    private int onlineUserCount;

    /**
     * 用户昵称
     */
    private String nickname;

    /**
     * 当前歌曲作者
     */
    private String currentMusicAuthor;

    /**
     * 当前正在演唱的歌曲
     */
    private String currentMusicName;

    /**
     * CDN 模式下的推拉流配置信息
     */
    private StreamConfig streamConfig;

    public VoiceRoomInfo() {
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getCreatorAccount() {
        return creatorAccount;
    }

    public void setCreatorAccount(String creatorAccount) {
        this.creatorAccount = creatorAccount;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getThumbnail() {
        return thumbnail;
    }

    public void setThumbnail(String thumbnail) {
        this.thumbnail = thumbnail;
    }

    public int getAudioQuality() {
        return audioQuality;
    }

    public void setAudioQuality(int audioQuality) {
        this.audioQuality = audioQuality;
    }

    public int getOnlineUserCount() {
        return onlineUserCount;
    }

    public void setOnlineUserCount(int onlineUserCount) {
        this.onlineUserCount = onlineUserCount;
    }

    public StreamConfig getStreamConfig() {
        return streamConfig;
    }

    public void setStreamConfig(StreamConfig config) {
        this.streamConfig = config;
    }

    public boolean isSupportCDN() {
        return this.streamConfig != null;
    }

    public void setRoomType(int roomType) {
        this.roomType = roomType;
    }

    public int getRoomType() {
        return roomType;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getCurrentMusicName() {
        return currentMusicName;
    }

    public void setCurrentMusicName(String currentMusicName) {
        this.currentMusicName = currentMusicName;
    }

    public String getCurrentMusicAuthor() {
        return currentMusicAuthor;
    }

    public void setCurrentMusicAuthor(String currentMusicAuthor) {
        this.currentMusicAuthor = currentMusicAuthor;
    }
}

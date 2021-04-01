package com.netease.yunxin.nertc.nertcvoiceroom.model;

import java.util.List;

/**
 * 语聊房定义
 */
public class NERtcVoiceRoomDef {
    /**
     * 房间语音质量
     */
    public interface RoomAudioQuality {
        /**
         * 默认音质
         */
        int DEFAULT_QUALITY = 0;

        /**
         * 高音质
         */
        int HIGH_QUALITY = 1;

        /**
         * 音乐音质
         */
        int MUSIC_QUALITY = 2;
    }

    /**
     * 房间回调
     */
    public interface RoomCallback {
        /**
         * 进入房间
         * 进入聊天室和语音通道
         *
         * @param success 是否成功
         */
        void onEnterRoom(boolean success);

        /**
         * 离开房间
         */
        void onLeaveRoom();

        /**
         * 房间被解散
         */
        void onRoomDismiss();

        /**
         * 当前在线用户数量更新
         *
         * @param onlineUserCount 当前在线用户数量
         */
        void onOnlineUserCount(int onlineUserCount);

        /**
         * 主播信息更新
         *
         * @param user {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 资料信息}
         */
        void onAnchorInfo(VoiceRoomUser user);

        /**
         * 主播静音状态
         *
         * @param muted    是否静音
         */
        void onAnchorMute(boolean muted);

        /**
         * 主播说话音量
         *
         * @param volume 说话音量0-100
         */
        void onAnchorVolume(int volume);

        /**
         * 静音状态
         *
         * @param muted    是否静音
         */
        void onMute(boolean muted);

        /**
         * 更新所有麦位信息
         *
         * @param seats     {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 麦位}
         */
        void updateSeats(List<VoiceRoomSeat> seats);

        /**
         * 更新麦位信息
         *
         * @param seat     {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 麦位}
         */
        void updateSeat(VoiceRoomSeat seat);

        /**
         * 麦位说话音量
         *
         * @param seat     {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 麦位}
         * @param volume 说话音量0-100
         */
        void onSeatVolume(VoiceRoomSeat seat, int volume);

        /**
         * 收到消息
         *
         * @param message {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomMessage 消息}
         */
        void onVoiceRoomMessage(VoiceRoomMessage message);

        /**
         * 演唱歌曲状态变化
         *
         * @param type {@link com.netease.yunxin.nertc.nertcvoiceroom.model.custom.CustomAttachmentType}
         */
        void onMusicStateChange(int type);
    }

    /**
     * 账号映射接口
     */
    public interface AccountMapper {
        /**
         * 为账号分配唯一的数值id
         *
         * @param account
         * @return uid
         */
        long accountToVoiceUid(String account);
    }
}

package com.netease.yunxin.nertc.nertcvoiceroom.model;

import com.netease.nimlib.sdk.RequestCallback;

/**
 * 观众操作接口
 */
public interface Audience {
    /**
     * 申请上麦
     *
     * @param seat     {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 麦位}
     * @param callback {@link com.netease.nimlib.sdk.RequestCallback 回调}
     */
    void applySeat(VoiceRoomSeat seat, RequestCallback<Void> callback);

    /**
     * 取消申请上麦
     *
     * @param callback {@link com.netease.nimlib.sdk.RequestCallback 回调}
     */
    void cancelSeatApply(RequestCallback<Void> callback);

    /**
     * 下麦
     *
     * @param callback {@link com.netease.nimlib.sdk.RequestCallback 回调}
     */
    void leaveSeat(RequestCallback<Void> callback);

    /**
     * 获取当前麦位
     *
     * @return {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 麦位}
     */
    VoiceRoomSeat getSeat();

    /**
     * 获取当前 CDN 模式下播放器控制
     *
     * @return {@link com.netease.yunxin.nertc.nertcvoiceroom.model.AudiencePlay 观众播放器控制}
     */
    AudiencePlay getAudiencePlay();

    /**
     * 根据当前是否在CDN模式下以及是否在麦位上决定是否重新通过播放器拉流
     */
    void restartAudioOrNot();

    /**
     * 刷新当前房间的麦位信息
     */
    void refreshSeat();

    /**
     * 观众回调接口
     */
    interface Callback {
        /**
         * 上麦请求被拒绝
         *
         * @param otherOn 是否被他人占用
         */
        void onSeatApplyDenied(boolean otherOn);

        /**
         * 进入麦位
         *
         * @param last 是否为恢复时
         * @return {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 麦位}
         */
        void onEnterSeat(VoiceRoomSeat seat, boolean last);

        /**
         * 离开麦位
         *
         * @param bySelf 是否为自己下麦
         * @return {@link com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat 麦位}
         */
        void onLeaveSeat(VoiceRoomSeat seat, boolean bySelf);

        /**
         * 麦位被屏蔽语音
         */
        void onSeatMuted();

        /**
         * 麦位被关闭
         */
        void onSeatClosed();

        /**
         * 是否被禁言（发送文字消息）
         */
        void onTextMuted(boolean muted);
    }

    /**
     * 设置观众回调
     *
     * @param callback {@link com.netease.yunxin.nertc.nertcvoiceroom.model.Audience.Callback 回调}
     */
    void setCallback(Callback callback);
}

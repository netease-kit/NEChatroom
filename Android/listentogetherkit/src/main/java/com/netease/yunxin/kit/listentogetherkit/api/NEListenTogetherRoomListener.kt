/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.api

import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomChatTextMessage
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomGiftModel
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomMember
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatItem

/**
 *  房间事件监听
 */
interface NEListenTogetherRoomListener {

    /**
     * 成员进入房间回调
     * @param members 成员列表
     */
    fun onMemberJoinRoom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>)

    /**
     * 成员离开房间回调
     * @param members 成员列表
     */
    fun onMemberLeaveRoom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>)

    /**
     * 成员进入聊天室回调
     * @param members 成员列表
     */
    fun onMemberJoinChatroom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>)

    /**
     * 成员离开聊天室回调
     * @param members 成员列表
     */
    fun onMemberLeaveChatroom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>)

    /**
     * 房间结束回调
     * @param reason 房间结束的原因
     * @see NEVoiceRoomEndReason
     */
    fun onRoomEnded(reason: NEVoiceRoomEndReason)

    /**
     * RTC频道错误回调
     * @param code RTC错误码
     */
    fun onRtcChannelError(code: Int)

    /**
     * 成员音频状态回调
     * @param member 成员
     * @param mute 是否静音。true 静音打开，false 静音关闭
     * @param operateBy 操作者
     */
    fun onMemberAudioMuteChanged(
        member: NEListenTogetherRoomMember,
        mute: Boolean,
        operateBy: NEListenTogetherRoomMember?
    )

    /**
     * 聊天室消息回调
     * @param message 文本消息
     */
    fun onReceiveTextMessage(message: NEListenTogetherRoomChatTextMessage)

    /**
     * 成员下麦，位置为[seatIndex]。
     * @param seatIndex 麦位位置。
     * @param account 下麦成员。
     */
    fun onSeatLeave(seatIndex: Int, account: String)

    /**
     * 麦位变更通知。
     * @param seatItems 麦位列表。
     */
    fun onSeatListChanged(seatItems: List<NEListenTogetherRoomSeatItem>)

    /**
     *  伴音错误状态
     *  @param reason 伴音错误状态码，0 为正常结束
     */
    fun onAudioMixingStateChanged(reason: Int)

    /**
     * 本端音频输出设备变更通知，如切换到扬声器、听筒、耳机等
     * @param device 音频输出类型
     */
    fun onAudioOutputDeviceChanged(device: NEVoiceRoomAudioOutputDevice)

    /**
     * 收到礼物
     * @param rewardMsg 礼物消息
     */
    fun onReceiveGift(rewardMsg: NEListenTogetherRoomGiftModel)

    /**
     * 背景音乐播放回调
     * @param uuid 用户id
     * @param timeStampMS 当前播放时间戳
     */
    fun onAudioEffectTimestampUpdate(uuid: String, timeStampMS: Long)

    /**
     * 本地音效文件播放已结束回调。
     * @param effectId 指定音效的 ID。每个音效均有唯一的 ID
     */
    fun onAudioEffectFinished(effectId: Int)
}

open class NEListenTogetherRoomListenerAdapter : NEListenTogetherRoomListener {
    override fun onMemberJoinRoom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>) {
    }

    override fun onMemberLeaveRoom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>) {
    }

    override fun onMemberJoinChatroom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>) {
    }

    override fun onMemberLeaveChatroom(members: @JvmSuppressWildcards List<NEListenTogetherRoomMember>) {
    }

    override fun onRoomEnded(reason: NEVoiceRoomEndReason) {
    }

    override fun onRtcChannelError(code: Int) {
    }

    override fun onMemberAudioMuteChanged(
        member: NEListenTogetherRoomMember,
        mute: Boolean,
        operateBy: NEListenTogetherRoomMember?
    ) {
    }

    override fun onReceiveTextMessage(message: NEListenTogetherRoomChatTextMessage) {
    }

    override fun onSeatLeave(seatIndex: Int, account: String) {
    }

    override fun onSeatListChanged(seatItems: List<NEListenTogetherRoomSeatItem>) {
    }

    override fun onAudioMixingStateChanged(reason: Int) {
    }

    override fun onAudioOutputDeviceChanged(device: NEVoiceRoomAudioOutputDevice) {
    }

    override fun onReceiveGift(rewardMsg: NEListenTogetherRoomGiftModel) {
    }

    override fun onAudioEffectTimestampUpdate(uuid: String, timeStampMS: Long) {
    }

    override fun onAudioEffectFinished(effectId: Int) {
    }
}

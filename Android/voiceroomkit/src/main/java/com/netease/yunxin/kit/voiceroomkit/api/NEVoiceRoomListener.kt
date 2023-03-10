/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api

import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomChatTextMessage
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatItem

/**
 *  房间事件监听
 */
interface NEVoiceRoomListener {

    /**
     * 成员进入房间回调
     * @param members 成员列表
     */
    fun onMemberJoinRoom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>)

    /**
     * 成员离开房间回调
     * @param members 成员列表
     */
    fun onMemberLeaveRoom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>)

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
        member: NEVoiceRoomMember,
        mute: Boolean,
        operateBy: NEVoiceRoomMember?
    )

    /**
     * 成员音频禁用事件回调
     * @param member 成员
     * @param banned 是否被禁用音频
     */
    fun onMemberAudioBanned(
        member: NEVoiceRoomMember,
        banned: Boolean
    )

    /**
     * 聊天室消息回调
     * @param message 文本消息
     */
    fun onReceiveTextMessage(message: NEVoiceRoomChatTextMessage)

    /**
     * 成员[account]提交了位置为[seatIndex]的麦位申请。
     * @param seatIndex 麦位位置，**-1**表示未指定位置。
     * @param account 申请人的用户ID。
     */
    fun onSeatRequestSubmitted(seatIndex: Int, account: String)

    /**
     * 成员[account]取消了位置为[seatIndex]的麦位申请。
     * @param seatIndex 麦位位置，**-1**表示未指定位置。
     * @param account 申请人的用户ID。
     */
    fun onSeatRequestCancelled(seatIndex: Int, account: String)

    /**
     * 管理员通过了成员[account]的麦位申请，位置为[seatIndex]。
     * @param seatIndex 麦位位置。
     * @param account 申请人的用户ID。
     * @param operateBy 同意该申请的用户ID。
     * @param isAutoAgree 是否为自动通过邀请。当关闭麦位申请的审批模式时，该值为true。
     */
    fun onSeatRequestApproved(
        seatIndex: Int,
        account: String,
        operateBy: String,
        isAutoAgree: Boolean
    )

    /**
     * 管理员拒绝了成员[account]的麦位申请，位置为[seatIndex]。
     * @param seatIndex 麦位位置，**-1**表示未指定位置。
     * @param account 申请人的用户ID。
     * @param operateBy 拒绝该申请的用户ID。
     */
    fun onSeatRequestRejected(seatIndex: Int, account: String, operateBy: String)

    /**
     * 成员下麦，位置为[seatIndex]。
     * @param seatIndex 麦位位置。
     * @param account 下麦成员。
     */
    fun onSeatLeave(seatIndex: Int, account: String)

    /**
     * 成员[account]被[operateBy]从位置为[seatIndex]的麦位踢掉。
     * @param seatIndex 麦位位置。
     * @param account 成员。
     * @param operateBy 操作人。
     */
    fun onSeatKicked(seatIndex: Int, account: String, operateBy: String)

    /**
     * 成员[account]接受了位置为[seatIndex]的上麦邀请。
     * @param seatIndex 麦位位置。
     * @param account  被邀请人。
     * @param isAutoAgree  是否为自动接收邀请。当关闭麦位邀请的确认模式时，该值为true。
     */
    fun onSeatInvitationAccepted(seatIndex: Int, account: String, isAutoAgree: Boolean)

    /**
     * 麦位变更通知。
     * @param seatItems 麦位列表。
     */
    fun onSeatListChanged(seatItems: List<NEVoiceRoomSeatItem>)

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
}

open class NEVoiceRoomListenerAdapter : NEVoiceRoomListener {
    override fun onMemberJoinRoom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>) {
    }

    override fun onMemberLeaveRoom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>) {
    }

    override fun onRoomEnded(reason: NEVoiceRoomEndReason) {
    }

    override fun onRtcChannelError(code: Int) {
    }

    override fun onMemberAudioMuteChanged(
        member: NEVoiceRoomMember,
        mute: Boolean,
        operateBy: NEVoiceRoomMember?
    ) {
    }

    override fun onMemberAudioBanned(member: NEVoiceRoomMember, banned: Boolean) {
    }

    override fun onReceiveTextMessage(message: NEVoiceRoomChatTextMessage) {
    }

    override fun onSeatRequestSubmitted(seatIndex: Int, account: String) {
    }

    override fun onSeatRequestCancelled(seatIndex: Int, account: String) {
    }

    override fun onSeatRequestApproved(
        seatIndex: Int,
        account: String,
        operateBy: String,
        isAutoAgree: Boolean
    ) {
    }

    override fun onSeatRequestRejected(seatIndex: Int, account: String, operateBy: String) {
    }

    override fun onSeatInvitationAccepted(seatIndex: Int, account: String, isAutoAgree: Boolean) {
    }

    override fun onSeatLeave(seatIndex: Int, account: String) {
    }

    override fun onSeatKicked(seatIndex: Int, account: String, operateBy: String) {
    }

    override fun onSeatListChanged(seatItems: List<NEVoiceRoomSeatItem>) {
    }

    override fun onAudioMixingStateChanged(reason: Int) {
    }

    override fun onAudioOutputDeviceChanged(device: NEVoiceRoomAudioOutputDevice) {
    }
}

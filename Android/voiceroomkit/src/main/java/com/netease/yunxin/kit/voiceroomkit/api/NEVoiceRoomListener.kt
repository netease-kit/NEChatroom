/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api

import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomBatchGiftModel
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomChatTextMessage
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMemberVolumeInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeResult
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
     * 成员进入聊天室回调
     * @param members 成员列表
     */
    fun onMemberJoinChatroom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>)

    /**
     * 成员离开聊天室回调
     * @param members 成员列表
     */
    fun onMemberLeaveChatroom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>)

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

    /**
     * 收到批量礼物
     * @param giftModel 礼物消息
     */
    fun onReceiveBatchGift(giftModel: NEVoiceRoomBatchGiftModel)

    /**
     * 背景音乐播放回调
     * @param effectId 音效id
     * @param timeStampMS 当前播放时间戳
     */
    fun onAudioEffectTimestampUpdate(effectId: Long, timeStampMS: Long)

    /**
     * 提示房间内本地用户瞬时音量的回调。 该回调默认为关闭状态。
     * 可以通过 [NEVoiceRoomKit.enableAudioVolumeIndication] 方法开启。
     * 开启后，本地用户说话，SDK 会按该方法中设置的时间间隔触发该回调。
     * @param volume 混音后的总音量，取值范围为 0~100。
     * @param vadFlag 是否检测到人声。
     */
    fun onRtcLocalAudioVolumeIndication(volume: Int, vadFlag: Boolean)

    /**
     * 提示房间内谁正在说话及说话者瞬时音量的回调。该回调默认为关闭状态。
     * 可以通过 [NEVoiceRoomKit.enableAudioVolumeIndication] 方法开启。
     * 开启后，无论房间内是否有人说话，SDK 都会按设置的时间间隔触发该回调。
     * - 如果有 [NEVoiceRoomMemberVolumeInfo.userUuid] 出现在上次返回的列表中，但不在本次返回的列表中，则默认该 userId 对应的远端用户没有说话。
     * - 如果 [NEVoiceRoomMemberVolumeInfo.volume] 为 0，表示该用户没有说话。
     * - 如果列表为空，则表示此时远端没有人说话。
     * - 如果是本地用户的音量回调，则[volumes]中只会包含本端用户
     * @param volumes 每个说话者的用户 ID 和音量信息的列表
     * @param totalVolume 混音后的总音量，取值范围为 0~100。
     */
    fun onRtcRemoteAudioVolumeIndication(volumes: List<NEVoiceRoomMemberVolumeInfo>, totalVolume: Int)

    /**
     * 本地音效文件播放已结束回调。
     * @param effectId 指定音效的 ID。每个音效均有唯一的 ID
     */
    fun onAudioEffectFinished(effectId: Int)
}

open class NEVoiceRoomListenerAdapter : NEVoiceRoomListener {
    override fun onMemberJoinRoom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>) {
    }

    override fun onMemberLeaveRoom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>) {
    }

    override fun onMemberJoinChatroom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>) {
    }

    override fun onMemberLeaveChatroom(members: @JvmSuppressWildcards List<NEVoiceRoomMember>) {
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

    override fun onReceiveBatchGift(giftModel: NEVoiceRoomBatchGiftModel) {
    }
    override fun onAudioEffectTimestampUpdate(effectId: Long, timeStampMS: Long) {
    }

    override fun onRtcLocalAudioVolumeIndication(volume: Int, vadFlag: Boolean) {
    }

    override fun onRtcRemoteAudioVolumeIndication(
        volumes: List<NEVoiceRoomMemberVolumeInfo>,
        totalVolume: Int
    ) {
    }

    override fun onAudioEffectFinished(effectId: Int) {
    }
}

interface NEVoiceRoomPreviewListener {
    /**
     * 通话前网络上下行 last mile 质量状态回调。 该回调描述本地用户在加入房间前的 last mile 网络探测的结果，以打分形式描述上下行网络
     * 质量的主观体验，您可以通过该回调预估本地用户在音视频通话中的网络体验。 在调用 startLastmileProbeTest 之后，SDK 会在约 5 秒内返回该回调。
     * @param quality 网络上下行质量@see[NEVoiceRoomLastmileQuality]，基于上下行网络的丢包率和抖动计算，探测结果主要反映上行网络的状态。
     * QUALITY_UNKNOWN(0)：质量未知
     * QUALITY_EXCELLENT(1)：质量极好
     * QUALITY_GOOD(2)：用户主观感觉和极好差不多，但码率可能略低于极好
     * QUALITY_POOR(3)：用户主观感受有瑕疵但不影响沟通
     * QUALITY_BAD(4)：勉强能沟通但不顺畅
     * QUALITY_VBAD(5)：网络质量非常差，基本不能沟通
     * QUALITY_DOWN(6)：完全无法沟通
     */
    fun onRtcLastmileQuality(quality: Int)

    /**
     * 通话前网络上下行 Last mile 质量探测报告回调。 该回调描述本地用户在加入房间前的 last mile 网络探测详细报告，报告中通过客观数据反馈上下行网络质量，
     * 包括网络抖动、丢包率等数据。您可以通过该回调客观预测本地用户在音视频通话中的网络状态。 在调用 startLastmileProbeTest 之后，SDK 会在约 30 秒内返回该回调。
     *
     * @param result 上下行 Last mile 质量探测结果。
     */
    fun onRtcLastmileProbeResult(result: NEVoiceRoomRtcLastmileProbeResult)
}

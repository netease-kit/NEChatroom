/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api

import android.annotation.SuppressLint
import android.content.Context
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceCreateRoomDefaultInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioEffectOption
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioMixingOption
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomLanguage
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomList
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeConfig
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatRequestItem
import com.netease.yunxin.kit.voiceroomkit.impl.VoiceRoomKitImpl

/**
 * 语聊房Kit
 * @property localMember 本端成员
 * @property allMemberList 远端成员
 * @property isInitialized 是否初始化
 * @property isLoggedIn 是否登录
 */
interface NEVoiceRoomKit {

    companion object {
        /**
         * NEVoiceRoomKit实例
         */
        @SuppressLint("StaticFieldLeak")
        @JvmField
        val instance: NEVoiceRoomKit = VoiceRoomKitImpl()

        /**
         * 获取NEVoiceRoomKit实例
         * @return NEVoiceRoomKit实例
         */
        @JvmStatic
        fun getInstance(): NEVoiceRoomKit = instance
    }

    /**
     * 本端成员信息 [NEVoiceRoomMember]
     * 加入房间后获取
     */
    val localMember: NEVoiceRoomMember?

    /**
     * 所有成员（包括本端）
     * 加入房间后获取
     */
    val allMemberList: List<NEVoiceRoomMember>

    /**
     * NEVoiceRoomKit 初始化
     *
     * @param context 上下文
     * @param config 初始化配置 [NEVoiceRoomKitConfig]
     * @param callback 回调
     */
    fun initialize(
        context: Context,
        config: NEVoiceRoomKitConfig,
        callback: NEVoiceRoomCallback<Unit>? = null
    )

    /**
     * 初始化状态
     *
     * true 已初始化  false 未初始化
     */
    val isInitialized: Boolean

    /**
     * 是否已经登录
     */
    val isLoggedIn: Boolean

    /**
     * 添加登录状态监听
     * @param listener 监听器
     *
     */
    fun addAuthListener(listener: NEVoiceRoomAuthListener)

    /**
     * 移除登录状态监听
     * @param listener 监听器
     */
    fun removeAuthListener(listener: NEVoiceRoomAuthListener)

    /**
     * 注册房间监听
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param listener 监听器
     *
     */
    fun addVoiceRoomListener(listener: NEVoiceRoomListener)

    /**
     * 移除房间监听
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param listener 监听器
     *
     */
    fun removeVoiceRoomListener(listener: NEVoiceRoomListener)

    /**
     * 登录
     *
     * @param account NERoom登录账号
     * @param token NERoom token
     * @param callback 回调
     * <br>相关回调：登录成功后，会触发[NEVoiceRoomAuthListener.onVoiceRoomAuthEvent]回调
     */
    fun login(account: String, token: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 登出
     *
     * @param callback 回调
     * <br>相关回调：登出成功后，会触发[NEVoiceRoomAuthListener.onVoiceRoomAuthEvent]回调
     */
    fun logout(callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 获取房间列表
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param liveState 直播状态 (直播状态) [NEVoiceRoomLiveState]
     * @param pageNum 页码
     * @param pageSize 页大小,一页包含多少条
     * @param callback 回调
     *
     */
    fun getRoomList(
        liveState: NEVoiceRoomLiveState,
        type: Int,
        pageNum: Int,
        pageSize: Int,
        callback: NEVoiceRoomCallback<NEVoiceRoomList>? = null
    )

    /**
     * 创建房间
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param params 创建房间参数配置[NECreateVoiceRoomParams]
     * @param options 进入房间时的必要配置[NECreateVoiceRoomOptions]
     * @param callback 回调
     * <br>注意事项：只有房主能执行该操作
     */
    fun createRoom(
        params: NECreateVoiceRoomParams,
        options: NECreateVoiceRoomOptions,
        callback: NEVoiceRoomCallback<NEVoiceRoomInfo>? = null
    )

    /**
     * 获取创建房间的默认信息
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     */
    fun getCreateRoomDefaultInfo(callback: NEVoiceRoomCallback<NEVoiceCreateRoomDefaultInfo>)

    /**
     * 加入房间
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param params 加入房间参数配置[NEJoinVoiceRoomParams]
     * @param options 进入房间时的必要配置[NEJoinVoiceRoomOptions]
     * @param callback 回调
     * <br>相关回调：加入房间成功后，会触发[NEVoiceRoomListener.onMemberJoinRoom]回调
     */
    fun joinRoom(
        params: NEJoinVoiceRoomParams,
        options: NEJoinVoiceRoomOptions,
        callback: NEVoiceRoomCallback<NEVoiceRoomInfo>? = null
    )

    /**
     * 离开房间
     * <br>使用前提：该方法仅在调用[joinRoom]方法加入房间成功后调用有效
     * @param callback 回调
     * <br>相关回调：离开房间成功后，会触发[NEVoiceRoomListener.onMemberLeaveRoom]回调
     */
    fun leaveRoom(callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 获取房间信息
     * @param liveRecordId 直播Id
     * @param callback 回调
     */
    fun getRoomInfo(liveRecordId: Long, callback: NEVoiceRoomCallback<NEVoiceRoomInfo>)

    /**
     * 获取当前房间信息
     * @return 当前房间信息
     */
    fun getCurrentRoomInfo(): NEVoiceRoomInfo?

    /**
     * 结束房间 房主权限
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     * <br>相关回调：离开房间成功后，会触发[NEVoiceRoomListener.onRoomEnded]回调
     * <br>注意事项：只有房主能执行该操作
     */
    fun endRoom(callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 获取麦位信息。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调。
     *
     */
    fun getSeatInfo(callback: NEVoiceRoomCallback<NEVoiceRoomSeatInfo>? = null)

    /**
     * 获取麦位申请列表。按照申请时间正序排序，先申请的成员排在列表前面。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调。
     *
     */
    fun getSeatRequestList(callback: NEVoiceRoomCallback<List<NEVoiceRoomSeatRequestItem>>? = null)

    /**
     * 房主向成员[account]发送上麦邀请，指定位置为[seatIndex]，非管理员执行该操作会失败。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param seatIndex 麦位位置。
     * @param account 麦上的用户ID。
     * @param callback 回调。
     * <br>相关回调：邀请上麦后，观众同意后（组件默认自动接收邀请），房间内所有成员会触发[NEVoiceRoomListener.onSeatInvitationAccepted]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     */
    fun sendSeatInvitation(
        seatIndex: Int,
        account: String,
        callback: NEVoiceRoomCallback<Unit>? = null
    )

    /**
     * 成员申请指定位置为[seatIndex]的麦位，位置从**1**开始。
     * 如果当前成员为管理员，则会自动通过申请。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param seatIndex 麦位位置。
     * @param exclusive 是否独占的。
     * @param callback 回调。
     * <br>相关回调：申请上麦后，房间内所有成员会触发[NEVoiceRoomListener.onSeatRequestSubmitted]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     */
    fun submitSeatRequest(
        seatIndex: Int,
        exclusive: Boolean,
        callback: NEVoiceRoomCallback<Unit>? = null
    )

    /**
     * 成员申请麦位
     * 如果当前成员为管理员，则会自动通过申请。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调。
     * <br>相关回调：申请上麦后，房间内所有成员会触发[NEVoiceRoomListener.onSeatRequestSubmitted]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     */
    fun submitSeatRequest(
        callback: NEVoiceRoomCallback<Unit>? = null
    )

    /***
     * 取消申请上麦
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     * <br>相关回调：取消申请上麦后，房间内所有成员会触发[NEVoiceRoomListener.onSeatRequestCancelled]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     * <br>注意事项：只有非房主能执行该操作
     */
    fun cancelSeatRequest(callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 同意上麦
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param account 被同意上麦的用户account
     * @param callback 回调
     * <br>相关回调：房主同意申请上麦后，房间内所有成员会触发[NEVoiceRoomListener.onSeatRequestApproved]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     * <br>注意事项：只有房主能执行该操作
     */
    fun approveSeatRequest(account: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 拒绝上麦
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param account 被拒绝上麦的用户account
     * @param callback 回调
     * <br>相关回调：房主拒绝申请上麦后，房间内所有成员会触发[NEVoiceRoomListener.onSeatRequestRejected]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     * <br>注意事项：只有房主能执行该操作
     */
    fun rejectSeatRequest(account: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 踢麦
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param account 被踢用户的uid
     * @param callback 回调
     * <br>相关回调：房主踢麦后，房间内所有成员会触发[NEVoiceRoomListener.onSeatKicked]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     * <br>注意事项：只有房主能执行该操作
     */
    fun kickSeat(account: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 下麦
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     * <br>相关回调：房主踢麦后，房间内所有成员会触发[NEVoiceRoomListener.onSeatLeave]回调和[NEVoiceRoomListener.onSeatListChanged]回调
     */
    fun leaveSeat(callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 禁用指定成员音频
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param account 成员
     * @param callback 回调
     * <br>注意事项：只有房主能执行该操作
     * <br>相关回调：禁用指定成员音频后，房间内所有成员会触发[NEVoiceRoomListener.onMemberAudioBanned]回调
     */
    fun banRemoteAudio(account: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 解禁指定成员的音频
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param account 成员
     * @param callback 回调
     * <br>注意事项：只有房主能执行该操作
     * <br>相关回调：解禁指定成员的音频后，房间内所有成员会触发[NEVoiceRoomListener.onMemberAudioBanned]回调
     */
    fun unbanRemoteAudio(account: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 打开麦位
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param seatIndices 麦位序号
     * @param callback 回调
     * <br>注意事项：只有房主能执行该操作
     * <br>相关回调：打开麦位后，房间内所有成员会触发[NEVoiceRoomListener.onSeatListChanged]回调
     */
    fun openSeats(seatIndices: List<Int>, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 关闭麦位
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     * <br>注意事项：只有房主能执行该操作
     * <br>相关回调：关闭麦位后，房间内所有成员会触发[NEVoiceRoomListener.onSeatListChanged]回调
     */
    fun closeSeats(seatIndices: List<Int>, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 发送聊天室消息
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param content 消息内容
     * @param callback 回调
     * <br>相关回调：调用改方法后，房间内其他成员都会触发[NEVoiceRoomListener.onReceiveTextMessage]回调
     */
    fun sendTextMessage(content: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 关闭自己的麦克风
     * <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
     * @param callback 回调
     * <br>相关回调：调用该方法后，本端和其他上麦用户会触发[NEVoiceRoomListener.onMemberAudioMuteChanged]回调
     */
    fun muteMyAudio(callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 打开自己的麦克风
     * <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
     * @param callback 回调
     * <br>相关回调：调用该方法后，本端和其他上麦用户会触发[NEVoiceRoomListener.onMemberAudioMuteChanged]回调
     */
    fun unmuteMyAudio(callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 开启耳返功能。
     * <br>开启耳返功能后，必须连接上耳机或耳麦，才能正常使用耳返功能。
     * @param volume 设置耳返音量，可设置为 0~100，默认为 100。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun enableEarback(volume: Int): Int

    /**
     * 关闭耳返功能。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun disableEarback(): Int

    /**
     *是否开启耳返功能
     * @return true 开启  false 关闭
     */
    fun isEarbackEnable(): Boolean

    /**
     * 调节人声音量
     * <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
     * @param volume 音量 范围0-100  默认100
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun adjustRecordingSignalVolume(volume: Int): Int

    /**
     * 获取人声音量
     * @return 人声音量
     */
    fun getRecordingSignalVolume(): Int

    /**
     * 开始播放音乐文件。
     * 该方法指定本地或在线音频文件来和录音设备采集的音频流进行混音。
     * 支持的音乐文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地文件或在线 URL。
     * @param option    创建混音任务配置的选项，包括混音任务类型、混音文件全路径或 URL 等，详细信息请参考 audio.NERtcCreateAudioMixingOption。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun startAudioMixing(
        option: NEVoiceRoomCreateAudioMixingOption
    ): Int

    /**
     * 暂停播放音乐文件及混音。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun pauseAudioMixing(): Int

    /**
     * 恢复播放伴奏。
     * 该方法恢复混音，继续播放伴奏。请在房间内调用该方法。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun resumeAudioMixing(): Int

    /**
     * 停止播放伴奏。
     * 该方法停止混音，停止播放伴奏。请在房间内调用该方法。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun stopAudioMixing(): Int

    /**
     * 设置伴奏音量。
     * 该方法调节混音里伴奏的音量大小。 setAudioMixingSendVolume setAudioMixingPlaybackVolume
     * @param volume    伴奏发送音量。取值范围为 0~200。默认 100，即原始文件音量。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun setAudioMixingVolume(volume: Int): Int

    /**
     * 获取伴奏音量
     * @return 伴奏音量
     */
    fun getAudioMixingVolume(): Int

    /**
     * 播放指定音效文件。
     * 该方法播放指定的本地或在线音效文件。
     * 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地 SD 卡中的文件和在线 URL
     * @param effectId    指定音效的 ID。每个音效均应有唯一的 ID。
     * @param option    音效相关参数，包括混音任务类型、混音文件路径等。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun playEffect(
        effectId: Int,
        option: NEVoiceRoomCreateAudioEffectOption
    ): Int

    /**
     * 设置音效音量 setEffectPlaybackVolume setEffectSendVolume
     * @param effectId Int
     * @param volume Int 默认 100
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun setEffectVolume(effectId: Int, volume: Int): Int

    /**
     * 获取音效音量
     * @return 音效音量
     */
    fun getEffectVolume(): Int

    /**
     * 停止所有音效
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun stopAllEffect(): Int

    /**
     * 停止指定id的音效
     * @param effectId 音效Id
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun stopEffect(effectId: Int): Int

    /**
     * 指定播放位置
     * <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功调用有效
     * @param effectId 音效文件id
     * @param position 播放位置
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun setPlayingPosition(effectId: Int, position: Long): Int

    /**
     * 暂停播放音效文件
     * @param effectId 音效文件id
     */
    fun pauseEffect(effectId: Int): Int

    /**
     * 继续播放音效文件
     * @param effectId 音效文件id
     */
    fun resumeEffect(effectId: Int): Int

    /**
     * 启用说话者音量提示。
     * 该方法允许 SDK 定期向 App 反馈本地发流用户和瞬时音量最高的远端用户（最多 3 位）的音量相关信息，
     * 即当前谁在说话以及说话者的音量。启用该方法后，只要房间内有发流用户，无论是否有人说话，
     * SDK 都会在加入房间后根据预设的时间间隔触发 [NEVoiceRoomListener.onRtcRemoteAudioVolumeIndication] 回调
     * @param enable 是否启用说话者音量提示。
     * @param interval 指定音量提示的时间间隔。单位为毫秒。必须设置为 100 毫秒的整数倍值，建议设置为 200 毫秒以上。
     */
    fun enableAudioVolumeIndication(enable: Boolean, interval: Int): Int

    /**
     * 批量发送礼物
     * @param giftId 礼物Id
     * @param giftCount 礼物数量
     * @param userUuids 发送礼物的对象
     * @param callback 回调
     * <br>相关回调：发送礼物成功后，房间内所有人会收到[NEVoiceRoomListener.onReceiveBatchGift]回调
     */
    fun sendBatchGift(giftId: Int, giftCount: Int, userUuids: List<String>, callback: NEVoiceRoomCallback<Unit>?)

    /**
     * 实名认证
     * @param name 用户真实姓名，以身份证上姓名为准，最大长度32
     * @param cardNo 用户身份证号码，目前支持一代/二代身份证，号码必须为18位或15位，末尾为x的需要大写为X，最大长度18
     */
    fun authenticate(name: String, cardNo: String, callback: NEVoiceRoomCallback<Unit>? = null)

    /**
     * 开始网络质量探测。
     * @param config 	Last mile 网络探测配置
     * 开始通话前网络质量探测。 启用该方法后，SDK 会通过回调方式反馈上下行网络的质量状态与质量探测报告，包括带宽、丢包率、网络抖动和往返时延等数据。
     * 一般用于通话前的网络质量探测场景，用户加入房间之前可以通过该方法预估音视频通话中本地用户的主观体验和客观网络状态。 相关回调如下：
     * onLastmileQuality：网络质量状态回调，以打分形式描述上下行网络质量的主观体验。该回调视网络情况在约 5 秒内返回。
     * onLastmileProbeResult：网络质量探测报告回调，报告中通过客观数据反馈上下行网络质量。该回调视网络情况在约 30 秒内返回。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun startLastmileProbeTest(config: NEVoiceRoomRtcLastmileProbeConfig): Int

    /**
     * 停止网络质量探测。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    fun stopLastmileProbeTest(): Int

    /**
     * 添加房间预览监听
     * @param listener 监听器
     */
    fun addPreviewListener(listener: NEVoiceRoomPreviewListener)

    /**
     * 移除房间预览监听
     * @param listener 监听器
     */
    fun removePreviewListener(listener: NEVoiceRoomPreviewListener)

    /**
     * 上传日志
     * @param callback 上传结果的回调,返回产物下载地址
     * @return Int
     */
    fun uploadLog()

    /**
     * 切换语言，组件不会缓存该设置。
     * @param language 目标语言
     */
    fun switchLanguage(language: NEVoiceRoomLanguage): Int
}

interface VoiceRoomInterceptor {
    fun onInComeInterceptor(): Boolean
}

/**
 * NEVoiceRoomKit配置
 * @property appKey NEVoiceRoom 服务的key
 * @property extras 额外参数
 */
data class NEVoiceRoomKitConfig(val appKey: String, val extras: Map<String, Any?> = mapOf()) {
    constructor(appKey: String) :
        this(appKey, mapOf())
}

/**
 * 创建房间参数
 *
 * @property title 房间名，支持中英文大小写、数字、特殊字符
 * @property nick 昵称
 * @property seatCount 麦位个数，默认8个,取值范围为1~20
 * @property seatApplyMode 麦位模式，0：自由模式，1：管理员控制模式
 * @property configId 模版id
 * @property cover 封面，https链接
 * @property liveType 直播类型,参考[NELiveType]
 * @property extraData 扩展字段
 */
data class NECreateVoiceRoomParams(
    val title: String,
    val nick: String,
    val seatCount: Int = 8,
    val seatApplyMode: Int = NEVoiceRoomSeatApplyMode.managerApproval,
    val configId: Int = 0,
    val cover: String?,
    val liveType: Int = NELiveType.LIVE_TYPE_VOICE,
    val extraData: String? = null
) {
    override fun toString(): String {
        return "NECreateVoiceRoomParams(title='$title', nick='$nick', seatCount=$seatCount，seatMode=$seatApplyMode, configId=$configId, cover=$cover, extraData=$extraData)"
    }
}

/**
 * 创建房间选项
 */
class NECreateVoiceRoomOptions

/**
 * 加入房间参数，支持中英文大小写、数字、特殊字符
 *
 * @property roomUuid 房间id
 * @property nick 昵称,最大字符长度64
 * @property avatar 头像
 * @property role 角色，支持HOST、AUDIENCE
 * @property liveRecordId 直播id
 * @property extraData 扩展字段
 */
data class NEJoinVoiceRoomParams(
    val roomUuid: String,
    val nick: String,
    val avatar: String?,
    val role: NEVoiceRoomRole,
    val liveRecordId: Long,
    val extraData: Map<String, String>? = HashMap()
) {
    override fun toString(): String {
        return "NEJoinVoiceRoomParams(roomUuid='$roomUuid', nick='$nick', avatar=$avatar, role=$role, liveRecordId=$liveRecordId, extraData=$extraData)"
    }
}

/**
 * 加入房间选项
 */
class NEJoinVoiceRoomOptions

/**
 * 通用回调
 * @param T 数据
 */
interface NEVoiceRoomCallback<T> {
    /**
     * 成功回调
     * @param t 数据
     */
    fun onSuccess(t: T?)

    /**
     * 失败回调
     * @param code 错误码
     * @param msg 错误信息
     */
    fun onFailure(code: Int, msg: String?)
}

/**
 * 登录监听器
 */
interface NEVoiceRoomAuthListener {
    /**
     * 登录事件回调
     * @param evt 登录事件
     */
    fun onVoiceRoomAuthEvent(evt: NEVoiceRoomAuthEvent)
}

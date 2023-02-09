/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.api

import android.annotation.SuppressLint
import android.content.Context
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherCreateRoomDefaultInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioEffectOption
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioMixingOption
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomMember
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NERoomList
import com.netease.yunxin.kit.listentogetherkit.impl.ListenTogetherKitImpl

/**
 * 一起听Kit
 * @property localMember 本端成员
 * @property allMemberList 远端成员
 * @property isInitialized 是否初始化
 * @property isLoggedIn 是否登录
 */
interface NEListenTogetherKit {

    companion object {
        /**
         * NEVoiceRoomKit实例
         */
        @SuppressLint("StaticFieldLeak")
        @JvmField
        val instance: NEListenTogetherKit = ListenTogetherKitImpl()

        /**
         * 获取NEVoiceRoomKit实例
         * @return NEVoiceRoomKit实例
         */
        @JvmStatic
        fun getInstance(): NEListenTogetherKit = instance
    }

    /**
     * 本端成员信息 [NEListenTogetherRoomMember]
     * 加入房间后获取
     */
    val localMember: NEListenTogetherRoomMember?

    /**
     * 所有成员（包括本端）
     * 加入房间后获取
     */
    val allMemberList: List<NEListenTogetherRoomMember>

    /**
     * NEVoiceRoomKit 初始化
     *
     * @param context 上下文
     * @param config 初始化配置 [NEListenTogetherKitConfig]
     * @param callback 回调
     */
    fun initialize(
        context: Context,
        config: NEListenTogetherKitConfig,
        callback: NEListenTogetherCallback<Unit>? = null
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
    fun addAuthListener(listener: NEListenTogetherRoomAuthListener)

    /**
     * 移除登录状态监听
     * @param listener 监听器
     */
    fun removeAuthListener(listener: NEListenTogetherRoomAuthListener)

    /**
     * 注册房间监听
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param listener 监听器
     *
     */
    fun addRoomListener(listener: NEListenTogetherRoomListener)

    /**
     * 移除房间监听
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param listener 监听器
     *
     */
    fun removeRoomListener(listener: NEListenTogetherRoomListener)

    /**
     * 登录
     *
     * @param account NERoom登录账号
     * @param token NERoom token
     * @param callback 回调
     * <br>相关回调：登录成功后，会触发[NEListenTogetherRoomAuthListener.onListenTogetherRoomAuthEvent]回调
     */
    fun login(account: String, token: String, callback: NEListenTogetherCallback<Unit>? = null)

    /**
     * 登出
     *
     * @param callback 回调
     * <br>相关回调：登出成功后，会触发[NEListenTogetherRoomAuthListener.onListenTogetherRoomAuthEvent]回调
     */
    fun logout(callback: NEListenTogetherCallback<Unit>? = null)

    /**
     * 获取房间列表
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param liveState 直播状态 (直播状态) [NEListenTogetherLiveState]
     * @param liveType 直播类型，2表示语聊房，5表示一起听
     * @param pageNum 页码
     * @param pageSize 页大小,一页包含多少条
     * @param callback 回调
     *
     */
    fun getVoiceRoomList(
        liveState: NEListenTogetherLiveState,
        liveType: Int,
        pageNum: Int,
        pageSize: Int,
        callback: NEListenTogetherCallback<NERoomList>? = null
    )

    /**
     * 创建房间
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param params 创建房间参数配置[NECreateListenTogetherRoomParams]
     * @param options 进入房间时的必要配置[NECreateListenTogetherRoomOptions]
     * @param callback 回调
     * <br>注意事项：只有房主能执行该操作
     */
    fun createRoom(
        params: NECreateListenTogetherRoomParams,
        options: NECreateListenTogetherRoomOptions,
        callback: NEListenTogetherCallback<NEListenTogetherRoomInfo>? = null
    )

    /**
     * 获取创建房间的默认信息
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     */
    fun getCreateRoomDefaultInfo(callback: NEListenTogetherCallback<NEListenTogetherCreateRoomDefaultInfo>)

    /**
     * 加入房间
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param params 加入房间参数配置[NEJoinListenTogetherRoomParams]
     * @param options 进入房间时的必要配置[NEJoinListenTogetherRoomOptions]
     * @param callback 回调
     * <br>相关回调：加入房间成功后，会触发[NEListenTogetherRoomListener.onMemberJoinRoom]回调
     */
    fun joinRoom(
        params: NEJoinListenTogetherRoomParams,
        options: NEJoinListenTogetherRoomOptions,
        callback: NEListenTogetherCallback<NEListenTogetherRoomInfo>? = null
    )

    /**
     * 离开房间
     * <br>使用前提：该方法仅在调用[joinRoom]方法加入房间成功后调用有效
     * @param callback 回调
     * <br>相关回调：离开房间成功后，会触发[NEListenTogetherRoomListener.onMemberLeaveRoom]回调
     */
    fun leaveRoom(callback: NEListenTogetherCallback<Unit>? = null)

    /**
     * 获取房间信息
     * @param liveRecordId 直播Id
     * @param callback 回调
     */
    fun getRoomInfo(liveRecordId: Long, callback: NEListenTogetherCallback<NEListenTogetherRoomInfo>)

    /**
     * 结束房间 房主权限
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     * <br>相关回调：离开房间成功后，会触发[NEListenTogetherRoomListener.onRoomEnded]回调
     * <br>注意事项：只有房主能执行该操作
     */
    fun endRoom(callback: NEListenTogetherCallback<Unit>? = null)

    /**
     * 获取麦位信息。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调。
     *
     */
    fun getSeatInfo(callback: NEListenTogetherCallback<NEListenTogetherRoomSeatInfo>? = null)

    /**
     * 房主向成员[account]发送上麦邀请，指定位置为[seatIndex]，非管理员执行该操作会失败。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param seatIndex 麦位位置。
     * @param account 麦上的用户ID。
     * @param callback 回调。
     * <br>相关回调：邀请上麦后，观众同意后（组件默认自动接收邀请），房间内所有成员会触发[NEListenTogetherRoomListener.onSeatInvitationAccepted]回调和[NEListenTogetherRoomListener.onSeatListChanged]回调
     */
    fun sendSeatInvitation(
        seatIndex: Int,
        account: String,
        callback: NEListenTogetherCallback<Unit>? = null
    )

    /**
     * 成员申请指定位置为[seatIndex]的麦位，位置从**1**开始。
     * 如果当前成员为管理员，则会自动通过申请。
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param seatIndex 麦位位置。
     * @param exclusive 是否独占的。
     * @param callback 回调。
     * <br>相关回调：申请上麦后，房间内所有成员会触发[NEListenTogetherRoomListener.onSeatRequestSubmitted]回调和[NEListenTogetherRoomListener.onSeatListChanged]回调
     */
    fun submitSeatRequest(
        seatIndex: Int,
        exclusive: Boolean,
        callback: NEListenTogetherCallback<Unit>? = null
    )

    /**
     * 下麦
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param callback 回调
     * <br>相关回调：房主踢麦后，房间内所有成员会触发[NEListenTogetherRoomListener.onSeatLeave]回调和[NEListenTogetherRoomListener.onSeatListChanged]回调
     */
    fun leaveSeat(callback: NEListenTogetherCallback<Unit>? = null)

    /**
     * 发送聊天室消息
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param content 消息内容
     * @param callback 回调
     * <br>相关回调：调用改方法后，房间内其他成员都会触发[NEListenTogetherRoomListener.onReceiveTextMessage]回调
     */
    fun sendTextMessage(content: String, callback: NEListenTogetherCallback<Unit>? = null)

    /**
     * 关闭自己的麦克风
     * <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
     * @param callback 回调
     * <br>相关回调：调用该方法后，本端和其他上麦用户会触发[NEListenTogetherRoomListener.onMemberAudioMuteChanged]回调
     */
    fun muteMyAudio(callback: NEListenTogetherCallback<Unit>? = null)

    /**
     * 打开自己的麦克风
     * <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
     * @param callback 回调
     * <br>相关回调：调用该方法后，本端和其他上麦用户会触发[NEListenTogetherRoomListener.onMemberAudioMuteChanged]回调
     */
    fun unmuteMyAudio(callback: NEListenTogetherCallback<Unit>? = null)

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
        option: NEListenTogetherRoomCreateAudioMixingOption
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
        option: NEListenTogetherRoomCreateAudioEffectOption
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
     * 发送礼物
     * @param giftId 礼物id
     * @param callback 发送礼物的回调
     * <br>相关回调：发送礼物成功后，房间内所有人会收到[NEListenTogetherRoomListener.onReceiveGift]回调
     */
    fun sendGift(giftId: Int, callback: NEListenTogetherCallback<Unit>? = null)

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
     * SDK 都会在加入房间后根据预设的时间间隔触发 [NEListenTogetherRoomListener.onRtcAudioVolumeIndication] 回调
     * @param enable 是否启用说话者音量提示。
     * @param interval 指定音量提示的时间间隔。单位为毫秒。必须设置为 100 毫秒的整数倍值，建议设置为 200 毫秒以上。
     */
    fun enableAudioVolumeIndication(enable: Boolean, interval: Int): Int
}

/**
 * NEListenTogetherKitConfig配置
 * @property appKey NEVoiceRoom 服务的key
 * @property extras 额外参数
 */
data class NEListenTogetherKitConfig(val appKey: String, val extras: Map<String, Any?> = mapOf())

/**
 * 创建房间参数
 *
 * @property title 房间名，支持中英文大小写、数字、特殊字符
 * @property nick 昵称
 * @property seatCount 麦位个数，默认8个,取值范围为1~20
 * @property configId 模版id
 * @property cover 封面，https链接
 * @property liveType 直播类型,参考[NELiveType]
 * @property extraData 扩展字段
 */
data class NECreateListenTogetherRoomParams(
    val title: String,
    val nick: String,
    val seatCount: Int = 8,
    val configId: Int = 0,
    val cover: String?,
    val liveType: Int = 2,
    val extraData: String? = null
) {
    override fun toString(): String {
        return "NECreateListenTogetherRoomParams(title='$title', nick='$nick', seatCount=$seatCount, configId=$configId, cover=$cover, extraData=$extraData)"
    }
}

/**
 * 创建房间选项
 */
class NECreateListenTogetherRoomOptions

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
data class NEJoinListenTogetherRoomParams(
    val roomUuid: String,
    val nick: String,
    val avatar: String?,
    val role: NEVoiceRoomRole,
    val liveRecordId: Long,
    val extraData: String? = null
) {
    override fun toString(): String {
        return "NEJoinListenTogetherRoomParams(roomUuid='$roomUuid', nick='$nick', avatar=$avatar, role=$role, liveRecordId=$liveRecordId, extraData=$extraData)"
    }
}

/**
 * 加入房间选项
 */
class NEJoinListenTogetherRoomOptions

/**
 * 通用回调
 * @param T 数据
 */
interface NEListenTogetherCallback<T> {
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
interface NEListenTogetherRoomAuthListener {
    /**
     * 登录事件回调
     * @param evt 登录事件
     */
    fun onListenTogetherRoomAuthEvent(evt: NEVoiceRoomAuthEvent)
}

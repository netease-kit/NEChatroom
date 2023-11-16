/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api

import com.netease.yunxin.kit.voiceroomkit.impl.utils.VoiceRoomLog

/**
 * 房间结束原因枚举
 */
enum class NEVoiceRoomEndReason {
    /**
     * 成员主动离开房间
     */
    LEAVE_BY_SELF,

    /**
     * 数据同步错误
     */
    SYNC_DATA_ERROR,

    /**
     * 多端同时加入同一房间被踢
     */
    KICK_BY_SELF,

    /**
     * 被管理员踢出房间
     */
    KICK_OUT,

    /**
     * 房间被关闭
     */
    CLOSE_BY_MEMBER,

    /**
     * 房间到期关闭
     */
    END_OF_LIFE,

    /**
     * 所有成员退出
     */
    ALL_MEMBERS_OUT,

    /**
     * 后台关闭
     */
    CLOSE_BY_BACKEND,

    /**
     * 账号异常
     */
    LOGIN_STATE_ERROR,

    /**
     * rtc 异常，退出
     */
    END_OF_RTC,

    /**
     * 未知异常
     */
    UNKNOWN;

    companion object {
        fun fromValue(value: String?): NEVoiceRoomEndReason = when (value) {
            LEAVE_BY_SELF.name -> LEAVE_BY_SELF
            SYNC_DATA_ERROR.name -> SYNC_DATA_ERROR
            KICK_BY_SELF.name -> KICK_BY_SELF
            KICK_OUT.name -> KICK_OUT
            CLOSE_BY_MEMBER.name -> CLOSE_BY_MEMBER
            END_OF_LIFE.name -> END_OF_LIFE
            ALL_MEMBERS_OUT.name -> ALL_MEMBERS_OUT
            CLOSE_BY_BACKEND.name -> CLOSE_BY_BACKEND
            LOGIN_STATE_ERROR.name -> LOGIN_STATE_ERROR
            END_OF_RTC.name -> END_OF_RTC
            else -> {
                VoiceRoomLog.e("NEVoiceRoomEndReason", "parse failure， Unable to identify: $value")
                UNKNOWN
            }
        }
    }
}

/**
 * 本地音频输出设备
 */
enum class NEVoiceRoomAudioOutputDevice {
    /**
     * 扬声器
     */
    SPEAKER_PHONE,

    /**
     * 有线耳机
     */
    WIRED_HEADSET,

    /**
     * 听筒
     */
    EARPIECE,

    /**
     * 蓝牙耳机
     */
    BLUETOOTH_HEADSET;

    companion object {
        fun fromValue(value: String?): NEVoiceRoomAudioOutputDevice = when (value) {
            SPEAKER_PHONE.name -> SPEAKER_PHONE
            WIRED_HEADSET.name -> WIRED_HEADSET
            EARPIECE.name -> EARPIECE
            BLUETOOTH_HEADSET.name -> BLUETOOTH_HEADSET
            else -> {
                VoiceRoomLog.e(
                    "NEVoiceRoomAudioOutputDevice",
                    "parse failure， Unable to identify: $value"
                )
                SPEAKER_PHONE
            }
        }
    }
}

/**
 * 登录事件枚举
 */
enum class NEVoiceRoomAuthEvent {
    /**
     * 被踢出登录
     */
    KICK_OUT,

    /**
     * 授权过期或失败
     */
    UNAUTHORIZED,

    /**
     * 服务端禁止登录
     */
    FORBIDDEN,

    /**
     * 账号或密码错误
     */
    ACCOUNT_TOKEN_ERROR,

    /**
     * 登录成功
     */
    LOGGED_IN,

    /**
     * 未登录
     */
    LOGGED_OUT,

    /**
     * Token过期
     */
    TOKEN_EXPIRED,

    /**
     * 授权错误
     */
    INCORRECT_TOKEN;

    companion object {
        fun fromValue(value: String?): NEVoiceRoomAuthEvent = when (value) {
            KICK_OUT.name -> KICK_OUT
            UNAUTHORIZED.name -> UNAUTHORIZED
            FORBIDDEN.name -> FORBIDDEN
            ACCOUNT_TOKEN_ERROR.name -> ACCOUNT_TOKEN_ERROR
            LOGGED_IN.name -> LOGGED_IN
            LOGGED_OUT.name -> LOGGED_OUT
            else -> {
                VoiceRoomLog.e("NEVoiceRoomAuthEvent", "parse failure， Unable to identify: $value")
                LOGGED_OUT
            }
        }
    }
}

/**
 * 错误码
 */
object NEVoiceRoomErrorCode {
    /**
     * 通用失败code码
     */
    const val FAILURE = -1

    /**
     * 成功code码
     */
    const val SUCCESS = 0
}

/**
 * 直播状态
 * @property value 状态
 * @constructor
 */
enum class NEVoiceRoomLiveState(val value: Int) {
    /**
     * 未开始
     */
    NotStart(0),

    /**
     * 直播中
     */
    Live(1),

    /**
     * 关播
     */
    LiveClose(6)
}

/**
 * 麦位状态
 */
object NEVoiceRoomSeatItemStatus {

    /**
     * 麦位初始化（无人，可以上麦）
     */
    const val INITIAL = 0

    /**
     * 该麦位正在等待管理员通过申请或等待成员接受邀请后上麦。
     */
    const val WAITING = 1

    /**
     * 当前麦位已被占用
     */
    const val TAKEN = 2

    /**
     * 当前麦位已关闭，不能操作上麦
     */
    const val CLOSED = -1
}

/**
 * 角色
 * @property value 角色值
 * @constructor
 */
enum class NEVoiceRoomRole(val value: String) {
    /**
     * 房主
     */
    HOST("host"),

    /**
     * 观众
     */
    AUDIENCE("audience");

    companion object {
        fun fromValue(value: String): NEVoiceRoomRole = when (value) {
            "host" -> HOST
            "audience" -> AUDIENCE
            else -> AUDIENCE
        }
    }
}

object NELiveType {
    const val LIVE_TYPE_DEFAULT = 0
    const val LIVE_TYPE_PK = 1 // PK直播
    const val LIVE_TYPE_VOICE = 2 // 语聊房
    const val LIVE_TYPE_KTV = 3 // KTV
    const val LIVE_INTERACTION = 4 // 互动直播
    const val LIVE_TYPE_TOGETHER_LISTEN = 5 // 一起听
    const val LIVE_TYPE_GAME = 6 // 游戏房
}

/**
 * 上麦模式
 */
object NEVoiceRoomSeatApplyMode {
    /**
     * 自由上麦模式
     */
    const val free = 0

    /**
     * 管理员审批上麦模式
     */
    const val managerApproval = 1
}

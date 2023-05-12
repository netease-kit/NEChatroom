/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * 语聊房成员对象
 * @property account 用户id
 * @property name 用户名
 * @property role 用户角色
 * @property isAudioOn 音频是否打开
 * @property isAudioBanned 音频是否被禁用
 * @property avatar 头像
 */
interface NEVoiceRoomMember {
    /**
     * 用户id
     */
    val account: String

    /**
     * 用户名
     */
    val name: String

    /**
     * 用户角色
     */
    val role: String

    /**
     * 音频是否打开
     */
    val isAudioOn: Boolean

    /**
     * 音频是否被禁用
     */
    val isAudioBanned: Boolean

    /**
     * 头像
     */
    val avatar: String?

    /**
     * 自定义属性
     */
    val initialProperties: Map<String, String>?
    // /**
    //  * 是否在RTC房间中
    //  */
    // val isInRtcChannel: Boolean
}

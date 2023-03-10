/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * 聊天室消息
 * @property fromUserUuid 发送端用户ID。如果为空字符串，则说明该用户可能未加入房间内。
 * @property fromNick 发送端昵称
 * @property toUserUuidList 接收端; 为空表示聊天室全体成员
 * @property time 消息时间戳
 * @property text 发送的消息内容
 */
data class NEVoiceRoomChatTextMessage(
    val fromUserUuid: String,
    val fromNick: String,
    val toUserUuidList: List<String>?,
    val time: Long,
    val text: String
)

/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * 麦位信息。
 * @property creator 麦位创建者。
 * @property managers 管理员列表。
 * @property seatItems 麦位列表信息。
 */
data class NEVoiceRoomSeatInfo(
    val creator: String,
    val managers: List<String>,
    val seatItems: List<NEVoiceRoomSeatItem>
)

/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.model

import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomSeatInvitationConfirmMode
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomSeatRequestApprovalMode

data class StartVoiceRoomParam(
    val roomTopic: String,
    val roomName: String,
    val cover: String,
    val liveType: Int,
    val configId: Int = 0,
    val seatCount: Int = 7,
    val seatApplyMode: NEVoiceRoomSeatRequestApprovalMode,
    val seatInviteMode: NEVoiceRoomSeatInvitationConfirmMode
)

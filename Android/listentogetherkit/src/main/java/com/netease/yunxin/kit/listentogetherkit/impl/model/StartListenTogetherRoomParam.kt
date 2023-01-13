/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.impl.model

data class StartListenTogetherRoomParam(
    val roomTopic: String,
    val userName: String,
    val cover: String,
    val liveType: Int,
    val configId: Int = 0,
    val seatCount: Int = 7,
    val seatApplyMode: Int = SeatRequestApprovalMode.ON,
    val seatInviteMode: Int = SeatInvitationConfirmMode.OFF
)

// 上麦申请是否需要管理员同意
internal object SeatRequestApprovalMode {
    const val OFF = 0
    const val ON = 1
}

// 管理员抱麦是否需要成员同意
internal object SeatInvitationConfirmMode {
    const val OFF = 0
    const val ON = 1
}

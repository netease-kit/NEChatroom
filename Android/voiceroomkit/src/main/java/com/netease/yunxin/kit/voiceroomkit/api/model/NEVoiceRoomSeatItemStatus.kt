/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

import com.netease.yunxin.kit.roomkit.api.service.NESeatItemStatus
import com.netease.yunxin.kit.roomkit.api.service.NESeatOnSeatType

object NEVoiceRoomSeatItemStatus {
    /**
     * 麦位初始化（无人，可以上麦）
     */
    const val INITIAL = NESeatItemStatus.INITIAL

    /**
     * 该麦位正在等待管理员通过申请或等待成员接受邀请后上麦。
     */
    const val WAITING = NESeatItemStatus.WAITING

    /**
     * 当前麦位已被占用
     */
    const val TAKEN = NESeatItemStatus.TAKEN

    /**
     * 当前麦位已关闭，不能操作上麦
     */
    const val CLOSED = NESeatItemStatus.CLOSED
}

/**
 * 成员上麦方式
 */
object NEVoiceRoomOnSeatType {
    /**
     * 无效
     */
    const val INVALID = NESeatOnSeatType.INVALID

    /**
     * 用户通过申请上麦
     */
    const val REQUEST = NESeatOnSeatType.REQUEST

    /**
     * 管理员抱成员上麦
     */
    const val INVITATION = NESeatOnSeatType.INVITATION
}

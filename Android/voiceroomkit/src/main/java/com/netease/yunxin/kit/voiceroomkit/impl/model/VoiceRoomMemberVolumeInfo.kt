/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.model

import com.netease.yunxin.kit.roomkit.api.model.NEMemberVolumeInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMemberVolumeInfo

internal class VoiceRoomMemberVolumeInfo(
    private val memberVolumeInfo: NEMemberVolumeInfo
) : NEVoiceRoomMemberVolumeInfo {
    override val userUuid: String
        get() = memberVolumeInfo.userUuid
    override val volume: Int
        get() = memberVolumeInfo.volume
}

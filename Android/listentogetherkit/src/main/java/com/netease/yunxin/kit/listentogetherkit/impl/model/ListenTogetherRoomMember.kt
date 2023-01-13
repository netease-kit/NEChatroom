/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.impl.model

import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomMember
import com.netease.yunxin.kit.listentogetherkit.impl.service.MemberPropertyConstants
import com.netease.yunxin.kit.roomkit.api.NERoomMember

internal class ListenTogetherRoomMember(
    private val roomMember: NERoomMember
) : NEListenTogetherRoomMember {
    override val account: String
        get() = roomMember.uuid

    override val name: String
        get() = roomMember.name

    override val role: String
        get() = roomMember.role.name

    override val isAudioOn: Boolean
        get() = roomMember.isAudioOn &&
            MemberPropertyConstants.MUTE_VOICE_VALUE_ON == roomMember.properties[MemberPropertyConstants.MUTE_VOICE_KEY]

    override val isAudioBanned: Boolean
        get() = roomMember.properties[MemberPropertyConstants.CAN_OPEN_MIC_KEY] == MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO

    override val avatar: String?
        get() = roomMember.avatar

    override fun toString(): String {
        return "VoiceRoomMember(roomMember=$roomMember, account='$account', name='$name', role='$role', isAudioOn=$isAudioOn, isAudioBanned=$isAudioBanned, avatar=$avatar)"
    }

    // override val isInRtcChannel: Boolean
    //     get() = roomMember.isInRtcChannel
}

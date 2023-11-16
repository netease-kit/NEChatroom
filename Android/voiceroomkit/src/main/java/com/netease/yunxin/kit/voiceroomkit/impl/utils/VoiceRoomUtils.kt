/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.utils

import com.netease.yunxin.kit.roomkit.api.service.NESeatInfo
import com.netease.yunxin.kit.roomkit.api.service.NESeatItem
import com.netease.yunxin.kit.roomkit.api.service.NESeatRequestItem
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomAnchor
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomBatchSeatUserReward
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomList
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomLiveModel
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatItem
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatRequestItem
import com.netease.yunxin.kit.voiceroomkit.impl.model.SeatUserReward
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.Operator
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.VoiceRoomList

internal object VoiceRoomUtils {

    fun voiceRoomInfo2NEVoiceRoomInfo(voiceRoomInfo: VoiceRoomInfo): NEVoiceRoomInfo {
        return NEVoiceRoomInfo(
            NEVoiceRoomAnchor(
                voiceRoomInfo.anchor.userUuid,
                voiceRoomInfo.anchor.userName,
                voiceRoomInfo.anchor.icon
            ),
            NEVoiceRoomLiveModel(
                voiceRoomInfo.liveModel.roomUuid,
                voiceRoomInfo.liveModel.roomName,
                voiceRoomInfo.liveModel.liveRecordId,
                voiceRoomInfo.liveModel.userUuid,
                voiceRoomInfo.liveModel.status,
                voiceRoomInfo.liveModel.liveType,
                voiceRoomInfo.liveModel.live,
                voiceRoomInfo.liveModel.liveTopic,
                voiceRoomInfo.liveModel.cover,
                voiceRoomInfo.liveModel.rewardTotal,
                voiceRoomInfo.liveModel.audienceCount,
                voiceRoomInfo.liveModel.onSeatCount,
                voiceRoomInfo.liveModel.liveConfig,
                voiceRoomInfo.liveModel.seatUserReward?.map { seatUserReward2NESeatUserReward(it) },
                voiceRoomInfo.liveModel.gameName
            )
        )
    }

    private fun seatUserReward2NESeatUserReward(seatUserReward: SeatUserReward): NEVoiceRoomBatchSeatUserReward {
        return NEVoiceRoomBatchSeatUserReward(
            seatUserReward.userUuid,
            seatUserReward.userName,
            seatUserReward.icon,
            seatUserReward.seatIndex,
            seatUserReward.rewardTotal
        )
    }

    fun voiceRoomList2NEVoiceRoomList(voiceRoomList: VoiceRoomList): NEVoiceRoomList {
        return NEVoiceRoomList(
            voiceRoomList.pageNum,
            voiceRoomList.hasNextPage,
            voiceRoomList.list?.map {
                voiceRoomInfo2NEVoiceRoomInfo(it)
            }
        )
    }

    fun operator2NEOperator(operator: Operator): NEOperator {
        return NEOperator(operator.userUuid, operator.userName, operator.icon)
    }

    fun voiceRoomSeatItem2NEVoiceRoomSeatItem(seatItem: NESeatItem): NEVoiceRoomSeatItem {
        return NEVoiceRoomSeatItem(
            seatItem.index,
            seatItem.status,
            seatItem.user,
            seatItem.userName,
            seatItem.icon,
            seatItem.onSeatType,
            seatItem.updated
        )
    }

    fun voiceRoomSeatInfo2NEVoiceRoomSeatInfo(seatInfo: NESeatInfo): NEVoiceRoomSeatInfo {
        return NEVoiceRoomSeatInfo(
            seatInfo.creator,
            seatInfo.managers,
            seatInfo.seatItems.map {
                voiceRoomSeatItem2NEVoiceRoomSeatItem(it)
            }
        )
    }

    fun voiceRoomSeatRequestItem2NEVoiceRoomSeatRequestItem(seatRequestItem: NESeatRequestItem): NEVoiceRoomSeatRequestItem {
        return NEVoiceRoomSeatRequestItem(
            seatRequestItem.index,
            seatRequestItem.user,
            seatRequestItem.userName,
            seatRequestItem.icon
        )
    }
}

/**
 * 操作者
 * @property userUuid 用户id
 * @property userName 用户名
 * @property icon 头像
 * @constructor
 */
data class NEOperator(
    val userUuid: String?,
    val userName: String?,
    val icon: String?
)

/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.impl.utils

import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomAnchor
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomGiftModel
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomLiveModel
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatItem
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatRequestItem
import com.netease.yunxin.kit.listentogetherkit.api.model.NERoomList
import com.netease.yunxin.kit.listentogetherkit.impl.model.ListenTogetherRoomGiftModel
import com.netease.yunxin.kit.listentogetherkit.impl.model.ListenTogetherRoomInfo
import com.netease.yunxin.kit.listentogetherkit.impl.model.response.Operator
import com.netease.yunxin.kit.listentogetherkit.impl.model.response.VoiceRoomList
import com.netease.yunxin.kit.roomkit.api.service.NESeatInfo
import com.netease.yunxin.kit.roomkit.api.service.NESeatItem
import com.netease.yunxin.kit.roomkit.api.service.NESeatRequestItem

internal object VoiceRoomUtils {

    fun voiceRoomInfo2NEVoiceRoomInfo(voiceRoomInfo: ListenTogetherRoomInfo): NEListenTogetherRoomInfo {
        return NEListenTogetherRoomInfo(
            NEListenTogetherRoomAnchor(
                voiceRoomInfo.anchor.userUuid,
                voiceRoomInfo.anchor.userName,
                voiceRoomInfo.anchor.icon
            ),
            NEListenTogetherRoomLiveModel(
                voiceRoomInfo.liveModel.appId, voiceRoomInfo.liveModel.roomUuid, voiceRoomInfo.liveModel.liveRecordId, voiceRoomInfo.liveModel.userUuid,
                voiceRoomInfo.liveModel.liveType, voiceRoomInfo.liveModel.live, voiceRoomInfo.liveModel.liveTopic, voiceRoomInfo.liveModel.cover, voiceRoomInfo.liveModel.rewardTotal,
                voiceRoomInfo.liveModel.audienceCount, voiceRoomInfo.liveModel.onSeatCount, voiceRoomInfo.liveModel.liveConfig
            )
        )
    }
    fun voiceRoomList2NEVoiceRoomList(voiceRoomList: VoiceRoomList): NERoomList {
        return NERoomList(
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

    fun voiceRoomSeatItem2NEVoiceRoomSeatItem(seatItem: NESeatItem): NEListenTogetherRoomSeatItem {
        return NEListenTogetherRoomSeatItem(
            seatItem.index,
            seatItem.status,
            seatItem.user,
            seatItem.userName,
            seatItem.icon,
            seatItem.onSeatType,
            seatItem.updated
        )
    }

    fun voiceRoomSeatInfo2NEVoiceRoomSeatInfo(seatInfo: NESeatInfo): NEListenTogetherRoomSeatInfo {
        return NEListenTogetherRoomSeatInfo(
            seatInfo.creator,
            seatInfo.managers,
            seatInfo.seatItems.map {
                voiceRoomSeatItem2NEVoiceRoomSeatItem(it)
            }
        )
    }

    fun voiceRoomSeatRequestItem2NEVoiceRoomSeatRequestItem(seatRequestItem: NESeatRequestItem): NEListenTogetherRoomSeatRequestItem {
        return NEListenTogetherRoomSeatRequestItem(
            seatRequestItem.index,
            seatRequestItem.user,
            seatRequestItem.userName,
            seatRequestItem.icon
        )
    }

    fun voiceRoomGiftModel2NEVoiceRoomGiftModel(karaokeGiftModel: ListenTogetherRoomGiftModel): NEListenTogetherRoomGiftModel {
        return NEListenTogetherRoomGiftModel(
            karaokeGiftModel.rewarderUserUuid,
            karaokeGiftModel.rewarderUserName,
            karaokeGiftModel.giftId
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

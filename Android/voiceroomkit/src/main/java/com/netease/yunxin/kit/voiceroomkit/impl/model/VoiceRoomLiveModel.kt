/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.model

import java.io.Serializable

data class VoiceRoomLiveModel(
    val roomUuid: String, // 房间Id
    val roomName: String?, // 房间名
    val liveRecordId: Long, // 直播Id
    val userUuid: String,
    val status: Int, // 直播记录是否有效 1: 有效 -1 无效
    val liveType: Int, // 	直播状态
    val live: Int, // 直播标题
    val liveTopic: String, // 直播封面
    val cover: String?, // 	打赏总额
    var rewardTotal: Long?, // 	观众人数
    val audienceCount: Int?, // 	上麦人数
    val onSeatCount: Int?,
    var liveConfig: String?,
    var seatUserReward: List<SeatUserReward>?,
    val gameName: String? // 麦上的打赏信息){}, val roomArchiveId: kotlin.String?){}){}
) : Serializable

data class SeatUserReward(
    val userUuid: String,
    val userName: String?,
    val icon: String?,
    val seatIndex: Int,
    val rewardTotal: Int
)

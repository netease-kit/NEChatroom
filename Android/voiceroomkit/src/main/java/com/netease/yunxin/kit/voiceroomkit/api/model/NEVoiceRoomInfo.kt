/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * 房间信息
 * @property anchor 主播信息
 * @property liveModel 直播模式
 * @constructor
 */
data class NEVoiceRoomInfo(
    val anchor: NEVoiceRoomAnchor,
    val liveModel: NEVoiceRoomLiveModel
)

/**
 * 主播信息
 * @property account 账号
 * @property nick 昵称
 * @property avatar 头像
 * @constructor
 */
data class NEVoiceRoomAnchor(
    val account: String,
    val nick: String?,
    val avatar: String?
)

/**
 * 直播模式
 * @property appId 应用Id
 * @property roomUuid 房间Id
 * @property liveRecordId 直播Id
 * @property userUuId String
 * @property liveType Int
 * @property live 直播状态
 * @property liveTopic 直播标题
 * @property cover 直播封面
 * @property rewardTotal 打赏总额
 * @property audienceCount 观众人数
 * @property onSeatCount 上麦人数
 * @property liveConfig 拉流配置
 * @property seatUserReward 麦上的打赏信息
 * @constructor
 */
data class NEVoiceRoomLiveModel(
    val appId: String,
    val roomUuid: String,
    val liveRecordId: Long,
    val userUuId: String,
    val liveType: Int,
    val live: Int,
    val liveTopic: String,
    val cover: String?,
    var rewardTotal: Long?,
    val audienceCount: Int?,
    val onSeatCount: Int?,
    var liveConfig: String?,
    var seatUserReward: List<NEVoiceRoomBatchSeatUserReward>?
)

/**
 * 打赏详情
 * @property userUuid 麦上用户uuid
 * @property userName 麦上用户名称
 * @property icon 麦上用户头像
 * @property seatIndex 麦位
 * @property rewardTotal 打赏
 */
data class NEVoiceRoomBatchSeatUserReward(
    val userUuid: String,
    val userName: String?,
    val icon: String?,
    val seatIndex: Int,
    val rewardTotal: Int
)

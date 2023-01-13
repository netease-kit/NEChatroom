/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.api.model

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
 * @constructor
 */
data class NEListenTogetherRoomLiveModel(
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
    var liveConfig: String?
)

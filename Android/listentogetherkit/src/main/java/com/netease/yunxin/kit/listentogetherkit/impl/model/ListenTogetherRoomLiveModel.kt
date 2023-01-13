/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.impl.model

import java.io.Serializable

data class ListenTogetherRoomLiveModel(
    val appId: String, // 应用Id
    val roomUuid: String, // 房间Id
    val liveRecordId: Long, // 直播Id
    val userUuid: String,
    val liveType: Int,
    val live: Int, // 	直播状态
    val liveTopic: String, // 直播标题
    val cover: String?, // 直播封面
    var rewardTotal: Long?, // 	打赏总额
    val audienceCount: Int?, // 	观众人数
    val onSeatCount: Int?, // 	上麦人数
    var liveConfig: String? // 拉流配置
) : Serializable

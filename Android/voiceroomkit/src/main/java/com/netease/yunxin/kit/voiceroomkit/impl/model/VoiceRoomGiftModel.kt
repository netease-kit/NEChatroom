/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.model

import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomBatchGiftModel

class VoiceRoomGiftModel(
    val rewarderUserUuid: String, // 	打赏者用户编号
    val rewarderUserName: String, // 	打赏者昵称
    val memberTotal: Long, // 	房间人数
    val anchorReward: AnchorRewardInfo, // 	被打赏主播打赏信息
    val giftId: Int // 	礼物编号
)

data class VoiceRoomBatchGiftModel(
    val data: NEVoiceRoomBatchGiftModel
)

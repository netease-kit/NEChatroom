/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * 批量礼物模型
 * @property senderUserUuid 消息发送者用户id
 * @property sendTime 发送礼物时间
 * @property rewarderUserUuid 打赏者用户id
 * @property rewarderUserName 打赏者昵称
 * @property rewardeeUserUuid 被打赏者用户id
 * @property rewardeeUserName 被打赏者昵称
 * @property giftId 礼物id
 * @property giftCount 礼物个数
 * @property seatUserReward 麦上主播或者观众打赏信息
 * @constructor
 */
data class NEVoiceRoomBatchGiftModel(
    val senderUserUuid: String,
    val sendTime: String,
    val rewarderUserUuid: String,
    val rewarderUserName: String,
    val rewardeeUserUuid: String,
    val rewardeeUserName: String,
    val giftId: Int,
    val giftCount: Int,
    val seatUserReward: List<NEVoiceRoomBatchSeatUserReward>
)

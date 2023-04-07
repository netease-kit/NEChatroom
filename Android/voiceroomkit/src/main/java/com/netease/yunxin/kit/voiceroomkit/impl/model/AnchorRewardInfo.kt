/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.model

import java.io.Serializable

data class AnchorRewardInfo(
    val userUuid: String, // 	用户编号
    val rewardTotal: Long // 	直播打赏总额
) : Serializable

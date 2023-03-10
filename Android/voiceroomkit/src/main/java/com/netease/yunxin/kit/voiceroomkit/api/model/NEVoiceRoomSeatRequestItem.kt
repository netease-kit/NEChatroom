/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * 成员麦位申请信息。
 * @property index 麦位位置。如果为**-1**，表示未指定位置。
 * @property user 申请人。
 * @property userName 用户名。
 * @property user 用户头像。
 */
data class NEVoiceRoomSeatRequestItem(
    val index: Int,
    val user: String,
    val userName: String?,
    val icon: String?
)

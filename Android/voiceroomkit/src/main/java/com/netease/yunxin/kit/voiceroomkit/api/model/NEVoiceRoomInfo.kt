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

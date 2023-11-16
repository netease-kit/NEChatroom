/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * @property topic 随机直播主题
 * @property livePicture 直播房间背景
 */
data class NEVoiceCreateRoomDefaultInfo(
    val topic: String?,
    val livePicture: String?,
    val defaultPictures: List<String>?
)

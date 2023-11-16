/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.voiceroomkit.impl.model

import com.google.gson.annotations.SerializedName

data class VoiceRoomDefaultConfig(
    @SerializedName("topic")
    val topic: String?, // 主题
    @SerializedName("livePicture")
    val livePicture: String?, // 背景图
    val defaultPictures: List<String>? // 默认背景图列表
)

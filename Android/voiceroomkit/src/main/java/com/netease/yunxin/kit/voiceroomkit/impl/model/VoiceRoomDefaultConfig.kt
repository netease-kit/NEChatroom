/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.voiceroomkit.impl.model

import com.google.gson.annotations.SerializedName
import java.io.Serializable

class VoiceRoomDefaultConfig : Serializable {
    @SerializedName("topic")
    lateinit var topic: String // 主题

    @SerializedName("livePicture")
    lateinit var livePicture: String // 背景图
}

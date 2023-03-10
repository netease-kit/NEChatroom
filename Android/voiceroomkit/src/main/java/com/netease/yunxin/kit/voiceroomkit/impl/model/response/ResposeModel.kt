/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.voiceroomkit.impl.model.response
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo

/**
 * 直播主页面列表返回值
 */
class VoiceRoomList {

    var pageNum: Int = 0 // 当前页码

    var hasNextPage = false // boolean	是否有下一页

    var list: MutableList<VoiceRoomInfo>? = null // 直播房间列表
}

data class Operator(
    val userUuid: String?,
    val userName: String?,
    val icon: String?
)

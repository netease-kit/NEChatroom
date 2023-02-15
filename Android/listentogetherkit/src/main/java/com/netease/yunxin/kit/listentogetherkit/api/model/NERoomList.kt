/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.api.model

/**
 * 房间列表
 * @property pageNum 当前页码
 * @property hasNextPage 是否有下一页
 * @property list 直播房间列表
 * @constructor
 */
data class NERoomList(
    var pageNum: Int = 0,
    var hasNextPage: Boolean = false,
    var list: List<NEListenTogetherRoomInfo>? = null
)

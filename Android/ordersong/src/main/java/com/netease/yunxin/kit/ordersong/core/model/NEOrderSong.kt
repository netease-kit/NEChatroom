/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.ordersong.core.model

/**
 * 已点歌曲信息
 * @constructor
 */
data class NEOrderSong(
    var orderSong: Song,
    var orderSongUser: NEOperator
)

/**
 * 操作者
 * @property userUuid 用户id
 * @property userName 用户名
 * @property icon 头像
 * @constructor
 */
data class NEOperator(
    val userUuid: String?,
    val userName: String?,
    val icon: String?
)

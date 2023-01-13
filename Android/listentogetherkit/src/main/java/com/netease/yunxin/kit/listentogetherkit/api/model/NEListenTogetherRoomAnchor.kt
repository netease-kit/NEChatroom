/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.api.model

/**
 * 主播信息
 * @property account 账号
 * @property nick 昵称
 * @property avatar 头像
 * @constructor
 */
data class NEListenTogetherRoomAnchor(
    val account: String,
    val nick: String?,
    val avatar: String?
)

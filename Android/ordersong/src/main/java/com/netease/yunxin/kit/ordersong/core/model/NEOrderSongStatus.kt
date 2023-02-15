/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.ordersong.core.model

/**
 * 点歌状态状态 -2 已唱 -1 删除 0:等待播 1 播放中
 */
object NEOrderSongStatus {

    /**
     * 已唱
     */
    const val STATUS_DONE = -2

    /**
     * 删除
     */
    const val STATUS_CANCELED = -1

    /**
     * 等待播
     */
    const val STATUS_WAIT = 0

    /**
     * 播放中
     */
    const val STATUS_SINGING = 1

    /**
     * 暂停中
     */
    const val STATUS_PAUSING = 2
}

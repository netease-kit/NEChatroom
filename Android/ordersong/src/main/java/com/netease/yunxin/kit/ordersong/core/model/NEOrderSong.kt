/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.ordersong.core.model

import java.io.Serializable

/**
 * 已点歌曲信息
 * @property orderId 点歌编号
 * @property appId 应用编号
 * @property roomUuid k歌房间编号
 * @property userUuid 用户编号
 * @property userName 用户名称
 * @property icon 用户头像
 * @property status 点歌状态状态 -2 已唱 -1 删除 0:等待唱 1 唱歌中
 * @property songId 歌曲编号
 * @property songName 歌曲名
 * @property songCover 歌曲封面
 * @property songTime 歌曲时长
 * @property singer 歌曲演唱者
 * @property singerCover 歌手封面
 * @property setTop 是否置顶（1 置顶 0 否）
 * @property channel 版权渠道 1 云音乐 2 咪咕
 * @property operator 操作者
 * @constructor
 */
class NEOrderSong(
    var orderId: Long = 0,
    var appId: String = "",
    var roomUuid: String = "",
    var userUuid: String?,
    var userName: String?,
    var icon: String?,
    var status: Int,
    var songId: String = "",
    var songName: String?,
    var songCover: String?,
    var songTime: Long?,
    var singer: String?,
    var singerCover: String?,
    var setTop: Int = 0,
    var channel: Int = 1,
    var operator: NEOperator?
) : Serializable {
    constructor(
        songId: String,
        songName: String,
        songCover: String?,
        songTime: Long?,
        channel: Int
    ) : this(
        0,
        "",
        "",
        "",
        "",
        "",
        1,
        songId,
        songName,
        songCover,
        songTime,
        "",
        "",
        0,
        channel,
        null
    )

    override fun toString(): String {
        return "OrderSong(orderId=$orderId, appId='$appId', " +
            "roomUuid='$roomUuid', userUuid='$userUuid', " +
            "userName='$userName', icon='$icon', status=$status, " +
            "songId='$songId', songName='$songName'," +
            " songCover='$songCover', singer='$singer', " +
            "singerCover='$singerCover', setTop=$setTop, channel=$channel, operator=$operator)"
    }
}

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

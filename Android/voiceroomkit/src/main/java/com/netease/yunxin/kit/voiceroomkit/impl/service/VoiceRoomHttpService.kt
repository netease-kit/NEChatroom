/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.service

import android.content.Context
import com.netease.yunxin.kit.common.network.NetRequestCallback
import com.netease.yunxin.kit.voiceroomkit.impl.model.StartVoiceRoomParam
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomDefaultConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.VoiceRoomList
import kotlinx.coroutines.flow.Flow

interface HttpErrorReporter {

    /**
     * 网络错误事件
     * @property code 错误码
     * @property msg 信息
     * @property requestId 请求id
     * @constructor
     */
    data class ErrorEvent(
        val code: Int,
        val msg: String?,
        val requestId: String
    )

    fun reportHttpErrorEvent(error: ErrorEvent)

    val httpErrorEvents: Flow<ErrorEvent>
}

/**
 * 语聊房 服务端接口对应service
 */
interface VoiceRoomHttpService : HttpErrorReporter {

    fun initialize(context: Context, url: String)

    fun addHeader(key: String, value: String)

    fun getVoiceRoomList(
        type: Int,
        live: Int,
        pageNum: Int,
        pageSize: Int,
        callback:
        NetRequestCallback<VoiceRoomList>
    )

    /**
     * 创建一个语聊房房间
     *
     */
    fun startVoiceRoom(param: StartVoiceRoomParam, callback: NetRequestCallback<VoiceRoomInfo>)

    /**
     * 获取房间 信息
     */
    fun getRoomInfo(liveRecordId: Long, callback: NetRequestCallback<VoiceRoomInfo>)

    /**
     * 结束语聊房房间
     */
    fun stopVoiceRoom(liveRecodeId: Long, callback: NetRequestCallback<Unit>)

    fun getDefaultLiveInfo(callback: NetRequestCallback<VoiceRoomDefaultConfig>)

    fun batchReward(
        liveRecodeId: Long,
        giftId: Int,
        giftCount: Int,
        userUuids: List<String>,
        callback: NetRequestCallback<Unit>
    )

    fun realNameAuthentication(name: String, cardNo: String, callback: NetRequestCallback<Unit>)
}

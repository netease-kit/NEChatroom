/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.ordersong.core.http

import android.text.TextUtils
import com.netease.yunxin.kit.common.network.Response
import com.netease.yunxin.kit.common.network.ServiceCreator
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSong
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSongDynamicToken
import com.netease.yunxin.kit.ordersong.core.model.OrderSong
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class OrderSongRepository {
    companion object {
        const val PLAY = 1
        const val PAUSE = 2
    }
    private val orderSongApi by lazy { ServiceCreator.create(OrderSongApi::class.java) }

    suspend fun getSongToken(appKey: String): Response<NEOrderSongDynamicToken> = withContext(Dispatchers.IO) {
        orderSongApi.getMusicToken(appKey)
    }

    suspend fun orderSong(
        roomUuid: String,
        songId: String,
        songName: String?,
        songCover: String?,
        songTime: Long?,
        channel: Int,
        singer: String
    ): Response<NEOrderSong> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "songId" to songId,
            "songName" to songName,
            "songCover" to songCover,
            "songTime" to songTime,
            "channel" to channel,
            "singer" to singer
        )
        orderSongApi.orderSong(NEOrderSongService.appKey, roomUuid, params)
    }

    suspend fun switchSong(
        roomUuid: String,
        currentOrderId: Long,
        attachment: String?
    ): Response<Boolean> = withContext(Dispatchers.IO) {
        if (!TextUtils.isEmpty(attachment)) {
            val params = mapOf<String, Any?>(
                "currentOrderId" to currentOrderId,
                "attachment" to attachment
            )
            orderSongApi.switchSong(NEOrderSongService.appKey, roomUuid, params)
        } else {
            val params = mapOf<String, Any?>(
                "currentOrderId" to currentOrderId
            )
            orderSongApi.switchSong(NEOrderSongService.appKey, roomUuid, params)
        }
    }

    suspend fun getOrderSongs(
        roomUuid: String
    ): Response<List<NEOrderSong>> = withContext(Dispatchers.IO) {
        orderSongApi.orderSongs(NEOrderSongService.appKey, roomUuid)
    }

    suspend fun cancelOrderSong(
        roomUuid: String,
        orderId: Long
    ): Response<Boolean> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "orderId" to orderId
        )
        orderSongApi.cancelOrderSong(NEOrderSongService.appKey, roomUuid, params)
    }

    suspend fun reportReady(
        roomUuid: String,
        orderId: Long
    ): Response<Boolean> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "orderId" to orderId
        )
        orderSongApi.reportReady(NEOrderSongService.appKey, roomUuid, params)
    }

    suspend fun queryPlayingSongInfo(
        roomUuid: String
    ): Response<OrderSong> = withContext(Dispatchers.IO) {
        orderSongApi.queryPlayingSongInfo(NEOrderSongService.appKey, roomUuid)
    }

    suspend fun reportResume(appKey: String, roomUuid: String, orderId: Long): Response<Boolean> =
        withContext(Dispatchers.IO) {
            val params = mapOf<String, Any?>(
                "orderId" to orderId,
                "action" to PLAY
            )
            orderSongApi.reportResume(appKey, roomUuid, params)
        }

    suspend fun reportPause(appKey: String, roomUuid: String, orderId: Long): Response<Boolean> =
        withContext(Dispatchers.IO) {
            val params = mapOf<String, Any?>(
                "orderId" to orderId,
                "action" to PAUSE
            )
            orderSongApi.reportPause(appKey, roomUuid, params)
        }
}

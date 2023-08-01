/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.ordersong.core.http

import android.content.Context
import android.text.TextUtils
import com.netease.yunxin.kit.common.network.Response
import com.netease.yunxin.kit.common.network.ServiceCreator
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSong
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSongDynamicToken
import com.netease.yunxin.kit.ordersong.core.model.OrderSong
import com.netease.yunxin.kit.roomkit.api.NERoomKit
import java.util.Locale
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class OrderSongRepository {
    companion object {
        const val PLAY = 1
        const val PAUSE = 2
    }

    private val serviceCreator: ServiceCreator = ServiceCreator()
    private val playSongServiceCreator: ServiceCreator = ServiceCreator()

    private lateinit var orderSongApi: OrderSongApi

    fun initialize(context: Context, orderSongServerUrl: String) {
        serviceCreator.init(
            context,
            orderSongServerUrl,
//            if (BuildConfig.DEBUG) ServiceCreator.LOG_LEVEL_BODY else ServiceCreator.LOG_LEVEL_BASIC,
            ServiceCreator.LOG_LEVEL_BODY, // todo 目前测试包打的都是release包，新临时改下网络日志等级，方便排查问题
            NERoomKit.getInstance().deviceId
        )
        serviceCreator.addHeader(ServiceCreator.ACCEPT_LANGUAGE_KEY, Locale.getDefault().language)
        orderSongApi = serviceCreator.create(OrderSongApi::class.java)
    }

    fun addHeader(key: String, value: String) {
        serviceCreator.addHeader(key, value)
        playSongServiceCreator.addHeader(key, value)
    }

    suspend fun getSongToken(): Response<NEOrderSongDynamicToken> = withContext(
        Dispatchers.IO
    ) {
        orderSongApi.getMusicToken()
    }

    suspend fun orderSong(
        liveRecordId: Long,
        songId: String,
        songName: String?,
        songCover: String?,
        songTime: Long?,
        channel: Int,
        singer: String
    ): Response<NEOrderSong> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "liveRecordId" to liveRecordId,
            "songId" to songId,
            "songName" to songName,
            "songCover" to songCover,
            "songTime" to songTime,
            "channel" to channel,
            "singer" to singer
        )
        orderSongApi.orderSong(params)
    }

    suspend fun switchSong(
        liveRecordId: Long,
        currentOrderId: Long,
        attachment: String?
    ): Response<Boolean> = withContext(Dispatchers.IO) {
        if (!TextUtils.isEmpty(attachment)) {
            val params = mapOf<String, Any?>(
                "liveRecordId" to liveRecordId,
                "currentOrderId" to currentOrderId,
                "attachment" to attachment
            )
            orderSongApi.switchSong(params)
        } else {
            val params = mapOf<String, Any?>(
                "liveRecordId" to liveRecordId,
                "currentOrderId" to currentOrderId
            )
            orderSongApi.switchSong(params)
        }
    }

    suspend fun getOrderSongs(liveRecordId: Long): Response<List<NEOrderSong>> = withContext(
        Dispatchers.IO
    ) {
        orderSongApi.orderSongs(liveRecordId)
    }

    suspend fun cancelOrderSong(
        liveRecordId: Long,
        orderId: Long
    ): Response<Boolean> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "orderId" to orderId,
            "liveRecordId" to liveRecordId
        )
        orderSongApi.cancelOrderSong(params)
    }

    suspend fun reportReady(
        liveRecordId: Long,
        orderId: Long
    ): Response<Boolean> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "orderId" to orderId,
            "liveRecordId" to liveRecordId
        )
        orderSongApi.reportReady(params)
    }

    suspend fun queryPlayingSongInfo(
        liveRecordId: Long
    ): Response<OrderSong> = withContext(Dispatchers.IO) {
        orderSongApi.queryPlayingSongInfo(liveRecordId)
    }

    suspend fun reportResume(liveRecordId: Long, orderId: Long): Response<Boolean> =
        withContext(Dispatchers.IO) {
            val params = mapOf<String, Any?>(
                "orderId" to orderId,
                "liveRecordId" to liveRecordId,
                "action" to PLAY
            )
            orderSongApi.reportResume(params)
        }

    suspend fun reportPause(liveRecordId: Long, orderId: Long): Response<Boolean> =
        withContext(Dispatchers.IO) {
            val params = mapOf<String, Any?>(
                "orderId" to orderId,
                "liveRecordId" to liveRecordId,
                "action" to PAUSE
            )
            orderSongApi.reportPause(params)
        }
}

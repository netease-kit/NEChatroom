/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.ordersong.core.http

import com.netease.yunxin.kit.common.network.Response
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSong
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSongDynamicToken
import com.netease.yunxin.kit.ordersong.core.model.OrderSong
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

interface OrderSongApi {
    /**
     * 获取版权曲库API鉴权的token
     */
    @POST("nemo/entertainmentLive/live/song/getMusicToken")
    suspend fun getMusicToken(): Response<NEOrderSongDynamicToken>

    /**
     * 点歌
     */
    @POST("nemo/entertainmentLive/live/song/orderSong")
    suspend fun orderSong(
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<NEOrderSong>

    /**
     * 切歌
     */
    @POST("nemo/entertainmentLive/live/song/switchSong")
    suspend fun switchSong(
        @Body body: Map<String, @JvmSuppressWildcards Any?>
    ): Response<Boolean>

    /**
     * 点歌列表查询
     */
    @GET("nemo/entertainmentLive/live/song/getOrderSongs")
    suspend fun orderSongs(@Query("liveRecordId") liveRecordId: Long): Response<List<NEOrderSong>>

    /**
     * 已点歌曲删除
     */
    @POST("nemo/entertainmentLive/live/song/cancelOrderSong")
    suspend fun cancelOrderSong(
        @Body body: Map<String, @JvmSuppressWildcards Any?>
    ): Response<Boolean>

    /**
     * 上报歌曲已经ready，可以准备一起播
     * 如果房间内只有1人，1人上报ready后，服务端就会下发cmd=135的聊天室消息 @see[OrderSongCmd.START_PLAY_CMD]
     * 如果房间内有2人，则需要2人都上报下载ready，服务端就会下发cmd=135的聊天室消息 @see[OrderSongCmd.START_PLAY_CMD]
     */
    @POST("nemo/entertainmentLive/music/ready")
    suspend fun reportReady(
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<Boolean>

    /**
     * 查询当前正在播放的歌曲
     */
    @GET("nemo/entertainmentLive/music/info")
    suspend fun queryPlayingSongInfo(@Query("liveRecordId") liveRecordId: Long): Response<OrderSong>

    /**
     * 恢复播放歌曲
     * 上报resume后，服务端就会下发cmd=138的聊天室消息 @see[OrderSongCmd.RESUME_PLAY_CMD]
     */
    @POST("nemo/entertainmentLive/music/action")
    suspend fun reportResume(
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<Boolean>

    /**
     * 暂停歌曲
     * 上报pause后，服务端就会下发cmd=136的聊天室消息 @see[OrderSongCmd.PAUSE_PLAY_CMD]
     */
    @POST("nemo/entertainmentLive/music/action")
    suspend fun reportPause(
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<Boolean>
}

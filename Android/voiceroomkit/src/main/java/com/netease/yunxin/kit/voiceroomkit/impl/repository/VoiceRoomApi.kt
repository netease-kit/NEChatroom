/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.voiceroomkit.impl.repository

import com.netease.yunxin.kit.common.network.Response
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomDefaultConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.VoiceRoomList
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST

interface VoiceRoomApi {

    /**
     * 获取语聊房房间列表
     */
    @POST("nemo/entertainmentLive/live/list")
    suspend fun getVoiceRoomList(
        @Body body: Map<String, @JvmSuppressWildcards Any?>
    ): Response<VoiceRoomList>

    /**
     * 创建语聊房 房间
     */
    @POST("nemo/entertainmentLive/live/createLive")
    suspend fun startVoiceRoom(
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<VoiceRoomInfo>

    /**
     * 结束 语聊房 房间
     */
    @POST("nemo/entertainmentLive/live/destroyLive")
    suspend fun stopVoiceRoom(
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<Unit>

    @POST("nemo/entertainmentLive/live/info")
    suspend fun getRoomInfo(
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<VoiceRoomInfo>

    @GET("nemo/entertainmentLive/live/getDefaultLiveInfo")
    suspend fun getDefaultLiveInfo(): Response<VoiceRoomDefaultConfig>

    /**
     * 批量打赏
     */
    @POST("nemo/entertainmentLive/live/batch/reward")
    suspend fun batchReward(
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<Unit>

    /**
     * 实名认证
     */
    @POST("nemo/entertainmentLive/real-name-authentication")
    suspend fun realNameAuthentication(
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<Unit>
}

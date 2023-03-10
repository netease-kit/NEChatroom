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
import retrofit2.http.Path

interface VoiceRoomApi {

    /**
     * 获取语聊房房间列表
     */
    @POST("/scene/apps/{appKey}/ent/live/v1/list")
    suspend fun getVoiceRoomList(
        @Path("appKey") appKey: String,
        @Body body: Map<String, @JvmSuppressWildcards Any?>
    ): Response<VoiceRoomList>

    /**
     * 创建卡拉ok 房间
     */
    @POST("/scene/apps/{appKey}/ent/live/v1/createLive")
    suspend fun startVoiceRoom(
        @Path("appKey") appKey: String,
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<VoiceRoomInfo>

    /**
     * 结束 ktv 房间
     */
    @POST("/scene/apps/{appKey}/ent/live/v1/destroyLive")
    suspend fun stopVoiceRoom(
        @Path("appKey") appKey: String,
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<Unit>

    @POST("/scene/apps/{appKey}/ent/live/v1/info")
    suspend fun getRoomInfo(
        @Path("appKey") appKey: String,
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<VoiceRoomInfo>

    @GET("/scene/apps/{appKey}/ent/live/v1/getDefaultLiveInfo")
    suspend fun getDefaultLiveInfo(
        @Path("appKey") appKey: String
    ): Response<VoiceRoomDefaultConfig>
}

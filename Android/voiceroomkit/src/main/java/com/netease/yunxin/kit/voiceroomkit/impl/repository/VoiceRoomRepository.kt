/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.repository

import android.content.Context
import com.netease.yunxin.kit.common.network.Response
import com.netease.yunxin.kit.common.network.ServiceCreator
import com.netease.yunxin.kit.roomkit.api.NERoomKit
import com.netease.yunxin.kit.roomkit.impl.repository.ServerConfig
import com.netease.yunxin.kit.voiceroomkit.BuildConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomDefaultConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.VoiceRoomList
import java.util.Locale
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class VoiceRoomRepository {
    companion object {
        lateinit var serverConfig: ServerConfig
    }
    private val serviceCreator: ServiceCreator = ServiceCreator()

    private lateinit var voiceRoomApi: VoiceRoomApi

    fun initialize(context: Context, url: String) {
        serviceCreator.init(
            context,
            url,
            if (BuildConfig.DEBUG) ServiceCreator.LOG_LEVEL_BODY else ServiceCreator.LOG_LEVEL_BASIC,
            NERoomKit.getInstance().deviceId
        )
        val localLanguage = Locale.getDefault().language
        serviceCreator.addHeader(ServiceCreator.ACCEPT_LANGUAGE_KEY, localLanguage)
        voiceRoomApi = serviceCreator.create(VoiceRoomApi::class.java)
    }

    fun addHeader(key: String, value: String) {
        serviceCreator.addHeader(key, value)
    }

    suspend fun getVoiceRoomList(
        liveType: Int,
        live: Int,
        pageNum: Int,
        pageSize: Int
    ): Response<VoiceRoomList> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "liveType" to liveType,
            "live" to live,
            "pageNum" to pageNum,
            "pageSize" to pageSize
        )
        voiceRoomApi.getVoiceRoomList(params)
    }

    suspend fun startVoiceRoom(
        liveTopic: String?,
        cover: String?,
        liveType: Int,
        configId: Int,
        roomName: String?,
        seatCount: Int,
        seatApplyMode: Int,
        seatInviteMode: Int
    ): Response<VoiceRoomInfo> =
        withContext(Dispatchers.IO) {
            val params = mapOf<String, Any?>(
                "liveTopic" to liveTopic,
                "cover" to cover,
                "liveType" to liveType,
                "configId" to configId,
                "roomName" to roomName,
                "seatCount" to seatCount,
                "seatApplyMode" to seatApplyMode,
                "seatInviteMode" to seatInviteMode
            )
            voiceRoomApi.startVoiceRoom(params)
        }

    suspend fun stopVoiceRoom(liveRecordId: Long): Response<Unit> = withContext(Dispatchers.IO) {
        val params = mapOf(
            "liveRecordId" to liveRecordId
        )
        voiceRoomApi.stopVoiceRoom(params)
    }

    suspend fun getRoomInfo(liveRecordId: Long): Response<VoiceRoomInfo> = withContext(
        Dispatchers.IO
    ) {
        val params = mapOf(
            "liveRecordId" to liveRecordId
        )
        voiceRoomApi.getRoomInfo(params)
    }

    suspend fun getDefaultLiveInfo(): Response<VoiceRoomDefaultConfig> = withContext(Dispatchers.IO) {
        voiceRoomApi.getDefaultLiveInfo()
    }

    suspend fun batchReward(liveRecordId: Long, giftId: Int, giftCount: Int, userUuids: List<String>): Response<Unit> = withContext(
        Dispatchers.IO
    ) {
        val params = mapOf(
            "liveRecordId" to liveRecordId,
            "giftId" to giftId,
            "giftCount" to giftCount,
            "targets" to userUuids
        )
        voiceRoomApi.batchReward(params)
    }

    suspend fun realNameAuthentication(name: String, cardNo: String): Response<Unit> = withContext(
        Dispatchers.IO
    ) {
        val params = mapOf(
            "name" to name,
            "cardNo" to cardNo
        )
        voiceRoomApi.realNameAuthentication(params)
    }
}

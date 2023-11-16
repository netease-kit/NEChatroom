/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl.service

import android.content.Context
import com.netease.yunxin.kit.common.network.NetRequestCallback
import com.netease.yunxin.kit.common.network.Request
import com.netease.yunxin.kit.roomkit.api.NEErrorCode
import com.netease.yunxin.kit.roomkit.api.NEErrorMsg
import com.netease.yunxin.kit.voiceroomkit.impl.model.StartVoiceRoomParam
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomDefaultConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.VoiceRoomList
import com.netease.yunxin.kit.voiceroomkit.impl.repository.VoiceRoomRepository
import com.netease.yunxin.kit.voiceroomkit.impl.utils.VoiceRoomLog
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

object VoiceRoomHttpServiceImpl : VoiceRoomHttpService {

    private const val TAG = "VoiceRoomHttpServiceImpl"

    private var voiceRoomRepository = VoiceRoomRepository()

    private var voiceRoomScope: CoroutineScope? = null

    init {
        voiceRoomScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    }

    override fun initialize(context: Context, url: String) {
        voiceRoomRepository.initialize(context, url)
    }

    override fun addHeader(key: String, value: String) {
        voiceRoomRepository.addHeader(key, value)
    }

    override fun getVoiceRoomList(
        type: Int,
        live: Int,
        pageNum: Int,
        pageSize: Int,
        callback: NetRequestCallback<VoiceRoomList>
    ) {
        voiceRoomScope?.launch {
            Request.request(
                {
                    voiceRoomRepository.getVoiceRoomList(type, live, pageNum, pageSize)
                },
                success = {
                    callback.success(it)
                },
                error = { code, msg ->
                    reportHttpErrorEvent(HttpErrorReporter.ErrorEvent(code, msg, ""))
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     *  创建房间
     *
     */
    override fun startVoiceRoom(
        param: StartVoiceRoomParam,
        callback: NetRequestCallback<VoiceRoomInfo>
    ) {
        voiceRoomScope?.launch {
            Request.request(
                {
                    voiceRoomRepository.startVoiceRoom(
                        param.roomTopic,
                        param.cover,
                        param.liveType,
                        param.configId,
                        param.roomName,
                        param.seatCount,
                        param.seatApplyMode,
                        param.seatInviteMode
                    )
                },
                success = {
                    it?.let {
                        callback.success(it)
                    }
                },
                error = { code, msg ->
                    reportHttpErrorEvent(HttpErrorReporter.ErrorEvent(code, msg, ""))
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * 获取房间 信息
     */
    override fun getRoomInfo(liveRecordId: Long, callback: NetRequestCallback<VoiceRoomInfo>) {
        voiceRoomScope?.launch {
            Request.request(
                { voiceRoomRepository.getRoomInfo(liveRecordId) },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    reportHttpErrorEvent(HttpErrorReporter.ErrorEvent(code, msg, ""))
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * 结束 语聊房房间
     */
    override fun stopVoiceRoom(liveRecodeId: Long, callback: NetRequestCallback<Unit>) {
        voiceRoomScope?.launch {
            Request.request(
                { voiceRoomRepository.stopVoiceRoom(liveRecodeId) },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    reportHttpErrorEvent(HttpErrorReporter.ErrorEvent(code, msg, ""))
                    callback.error(code, msg)
                }
            )
        }
    }

    override fun getDefaultLiveInfo(callback: NetRequestCallback<VoiceRoomDefaultConfig>) {
        voiceRoomScope?.launch {
            Request.request(
                { voiceRoomRepository.getDefaultLiveInfo() },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    reportHttpErrorEvent(HttpErrorReporter.ErrorEvent(code, msg, ""))
                    callback.error(code, msg)
                }
            )
        }
    }

    override fun batchReward(
        liveRecodeId: Long,
        giftId: Int,
        giftCount: Int,
        userUuids: List<String>,
        callback: NetRequestCallback<Unit>
    ) {
        voiceRoomScope?.launch {
            Request.request(
                { voiceRoomRepository.batchReward(liveRecodeId, giftId, giftCount, userUuids) },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    reportHttpErrorEvent(HttpErrorReporter.ErrorEvent(code, msg, ""))
                    callback.error(code, msg)
                }
            )
        }
    }

    override fun realNameAuthentication(name: String, cardNo: String, callback: NetRequestCallback<Unit>) {
        voiceRoomScope?.launch {
            Request.request(
                { voiceRoomRepository.realNameAuthentication(name, cardNo) },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    reportHttpErrorEvent(HttpErrorReporter.ErrorEvent(code, msg, ""))
                    callback.error(code, msg)
                }
            )
        }
    }

    override fun reportHttpErrorEvent(error: HttpErrorReporter.ErrorEvent) {
        if (error.code != NEErrorCode.SUCCESS) {
            VoiceRoomLog.e(TAG, "report http error: $error")
        }
        httpErrorEvents.value = error
    }

    override val httpErrorEvents =
        MutableStateFlow(HttpErrorReporter.ErrorEvent(NEErrorCode.SUCCESS, NEErrorMsg.SUCCESS, "0"))

    fun destroy() {
        voiceRoomScope?.cancel()
        voiceRoomScope = null
    }
}

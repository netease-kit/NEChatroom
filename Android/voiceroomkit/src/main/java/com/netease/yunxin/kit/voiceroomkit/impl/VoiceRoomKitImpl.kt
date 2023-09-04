/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl

import android.content.Context
import android.text.TextUtils
import com.netease.yunxin.kit.common.network.NetRequestCallback
import com.netease.yunxin.kit.roomkit.api.NECallback2
import com.netease.yunxin.kit.roomkit.api.NEErrorCode
import com.netease.yunxin.kit.roomkit.api.NEPreviewRoomContext
import com.netease.yunxin.kit.roomkit.api.NEPreviewRoomListener
import com.netease.yunxin.kit.roomkit.api.NERoomKit
import com.netease.yunxin.kit.roomkit.api.NERoomKitOptions
import com.netease.yunxin.kit.roomkit.api.NERoomLanguage
import com.netease.yunxin.kit.roomkit.api.model.NEIMServerConfig
import com.netease.yunxin.kit.roomkit.api.model.NERoomKitServerConfig
import com.netease.yunxin.kit.roomkit.api.model.NERoomRtcLastmileProbeConfig
import com.netease.yunxin.kit.roomkit.api.model.NERoomRtcLastmileProbeResult
import com.netease.yunxin.kit.roomkit.api.model.NEServerConfig
import com.netease.yunxin.kit.roomkit.api.service.NEAuthEvent
import com.netease.yunxin.kit.roomkit.api.service.NEAuthListener
import com.netease.yunxin.kit.roomkit.api.service.NEAuthService
import com.netease.yunxin.kit.roomkit.api.service.NEPreviewRoomOptions
import com.netease.yunxin.kit.roomkit.api.service.NEPreviewRoomParams
import com.netease.yunxin.kit.roomkit.api.service.NESeatInfo
import com.netease.yunxin.kit.roomkit.api.service.NESeatRequestItem
import com.netease.yunxin.kit.roomkit.impl.repository.ServerConfig
import com.netease.yunxin.kit.roomkit.impl.utils.CoroutineRunner
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomOptions
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomParams
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomOptions
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomParams
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAudioOutputDevice
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAuthEvent
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAuthListener
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomEndReason
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomErrorCode
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKitConfig
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListener
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomLiveState
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomPreviewListener
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomSeatInvitationConfirmMode
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomSeatRequestApprovalMode
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceCreateRoomDefaultInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomBatchGiftModel
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomChatTextMessage
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioEffectOption
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioMixingOption
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomLanguage
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomList
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMemberVolumeInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeConfig
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeOneWayResult
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeResult
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatItem
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatRequestItem
import com.netease.yunxin.kit.voiceroomkit.impl.model.StartVoiceRoomParam
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomDefaultConfig
import com.netease.yunxin.kit.voiceroomkit.impl.model.VoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.impl.model.response.VoiceRoomList
import com.netease.yunxin.kit.voiceroomkit.impl.repository.VoiceRoomRepository
import com.netease.yunxin.kit.voiceroomkit.impl.service.VoiceRoomHttpService
import com.netease.yunxin.kit.voiceroomkit.impl.service.VoiceRoomHttpServiceImpl
import com.netease.yunxin.kit.voiceroomkit.impl.service.VoiceRoomService
import com.netease.yunxin.kit.voiceroomkit.impl.utils.ScreenUtil
import com.netease.yunxin.kit.voiceroomkit.impl.utils.VoiceRoomLog
import com.netease.yunxin.kit.voiceroomkit.impl.utils.VoiceRoomUtils
import java.util.Locale
import java.util.concurrent.CopyOnWriteArrayList

internal class VoiceRoomKitImpl : NEVoiceRoomKit, CoroutineRunner() {
    private val voiceRoomHttpService: VoiceRoomHttpService by lazy { VoiceRoomHttpServiceImpl }
    private var createVoiceRoomInfo: VoiceRoomInfo? = null
    private var joinedVoiceRoomInfo: VoiceRoomInfo? = null
    private val myRoomService = VoiceRoomService()
    private val authListeners: CopyOnWriteArrayList<NEVoiceRoomAuthListener> by lazy {
        CopyOnWriteArrayList()
    }
    private lateinit var context: Context
    private var hasLogin: Boolean = false
    private var previewRoomContext: NEPreviewRoomContext? = null
    private val previewRoomListeners: CopyOnWriteArrayList<NEVoiceRoomPreviewListener> by lazy {
        CopyOnWriteArrayList<NEVoiceRoomPreviewListener>()
    }
    private val listeners: CopyOnWriteArrayList<NEVoiceRoomListener> by lazy {
        CopyOnWriteArrayList<NEVoiceRoomListener>()
    }
    companion object {
        private const val tag = "NEVoiceRoomKit"
        private const val ACCEPT_LANGUAGE_KEY = "Accept-Language"
        private const val SERVER_URL_KEY = "serverUrl"
        private const val BASE_URL_KEY = "baseUrl"
        private const val HTTP_PREFIX = "http"
        private const val TEST_URL_VALUE = "test"
        private const val OVER_URL_VALUE = "oversea"
        private const val OVERSEA_SERVER_URL = "https://roomkit-sg.netease.im/"

        // IM 海外环境  https://doc.yunxin.163.com/TM5MzM5Njk/docs/zA5OTg4Njc?platform=android#Android%20%E7%AB%AF
        private const val LINK = "link-sg.netease.im:7000"
        private const val LBS = "https://lbs.netease.im/lbs/conf.jsp"
        private const val NOS_LBS = "http://wannos.127.net/lbs"
        private const val NOS_UPLOADER = "https://nosup-hz1.127.net"
        private const val NOS_DOWNLOADER = "{bucket}-nosdn.netease.im/{object}"
        private const val NOS_UPLOADER_HOST = "nosup-hz1.127.net"
        private const val LANGUAGE_EN = "en"
        private const val LANGUAGE_ZH = "zh"
    }

    override val localMember: NEVoiceRoomMember?
        get() = myRoomService.getLocalMember()

    override val allMemberList: List<NEVoiceRoomMember>
        get() {
            return myRoomService.getLocalMember()?.let {
                val list = mutableListOf(it)
                list.addAll(myRoomService.getRemoteMembers())
                list
            } ?: emptyList()
        }

    private var config: NEVoiceRoomKitConfig? = null
    private var baseUrl: String = ""
    override fun initialize(
        context: Context,
        config: NEVoiceRoomKitConfig,
        callback: NEVoiceRoomCallback<Unit>?
    ) {
        VoiceRoomLog.logApi("initialize")
        this.context = context
        this.config = config
        ScreenUtil.init(context)
        var realRoomServerUrl = ""
        var isOversea = false
        val realExtras = HashMap<String, Any?>()
        realExtras.putAll(config.extras)
        if (config.extras[SERVER_URL_KEY] != null) {
            val serverUrl: String = config.extras[SERVER_URL_KEY] as String
            baseUrl = config.extras[BASE_URL_KEY] as String
            VoiceRoomLog.i(tag, "serverUrl:$serverUrl")
            VoiceRoomLog.i(tag, "baseUrl:$baseUrl")
            if (!TextUtils.isEmpty(serverUrl)) {
                when {
                    TEST_URL_VALUE == serverUrl -> {
                        realRoomServerUrl = serverUrl
                    }
                    OVER_URL_VALUE == serverUrl -> {
                        realRoomServerUrl = OVERSEA_SERVER_URL
                        isOversea = true
                    }
                    serverUrl.startsWith(HTTP_PREFIX) -> {
                        realRoomServerUrl = serverUrl
                    }
                }
            }
        }
        realExtras[SERVER_URL_KEY] = realRoomServerUrl
        val serverConfig =
            ServerConfig.selectServer(config.appKey, realRoomServerUrl)
        VoiceRoomRepository.serverConfig = serverConfig
        NERoomKit.getInstance()
            .initialize(
                context,
                options = NERoomKitOptions(
                    appKey = config.appKey,
                    extras = realExtras,
                    serverConfig = if (isOversea) {
                        NEServerConfig().apply {
                            imServerConfig = NEIMServerConfig().apply {
                                link = LINK
                                lbs = LBS
                                nosLbs = NOS_LBS
                                nosUploader = NOS_UPLOADER
                                nosDownloader = NOS_DOWNLOADER
                                nosUploaderHost = NOS_UPLOADER_HOST
                                httpsEnabled = true
                            }
                            roomKitServerConfig = NERoomKitServerConfig().apply {
                                roomServer = realRoomServerUrl
                            }
                        }
                    } else {
                        null
                    }
                )
            ) { code, message, _ ->
                if (code == NEErrorCode.SUCCESS) {
                    voiceRoomHttpService.initialize(context, baseUrl)
                    voiceRoomHttpService.addHeader("appkey", config.appKey)
                    NERoomKit.getInstance().roomService.previewRoom(
                        NEPreviewRoomParams(),
                        NEPreviewRoomOptions(),
                        object : NECallback2<NEPreviewRoomContext>() {
                            override fun onSuccess(data: NEPreviewRoomContext?) {
                                super.onSuccess(data)
                                previewRoomContext = data
                                previewRoomContext?.addPreviewRoomListener(object :
                                    NEPreviewRoomListener {
                                    override fun onRtcVirtualBackgroundSourceEnabled(
                                        enabled: Boolean,
                                        reason: Int
                                    ) {
                                    }

                                    override fun onRtcLastmileQuality(quality: Int) {
                                        for (previewRoomListener in previewRoomListeners) {
                                            previewRoomListener.onRtcLastmileQuality(quality)
                                        }
                                    }

                                    override fun onRtcLastmileProbeResult(result: NERoomRtcLastmileProbeResult) {
                                        for (previewRoomListener in previewRoomListeners) {
                                            previewRoomListener.onRtcLastmileProbeResult(
                                                NEVoiceRoomRtcLastmileProbeResult(
                                                    state = result.state,
                                                    rtt = result.rtt,
                                                    uplinkReport = NEVoiceRoomRtcLastmileProbeOneWayResult(
                                                        packetLossRate = result.uplinkReport.packetLossRate,
                                                        jitter = result.uplinkReport.jitter,
                                                        availableBandwidth = result.uplinkReport.availableBandwidth
                                                    ),
                                                    downlinkReport = NEVoiceRoomRtcLastmileProbeOneWayResult(
                                                        packetLossRate = result.downlinkReport.packetLossRate,
                                                        jitter = result.downlinkReport.jitter,
                                                        availableBandwidth = result.downlinkReport.availableBandwidth
                                                    )
                                                )
                                            )
                                        }
                                    }
                                })
                            }

                            override fun onError(code: Int, message: String?) {
                                super.onError(code, message)
                                VoiceRoomLog.e(tag, "previewRoom error,code:$code,message:$message")
                            }
                        }
                    )
                    callback?.onSuccess(Unit)
                } else {
                    callback?.onFailure(code, message)
                }
            }

        NERoomKit.getInstance().getService(NEAuthService::class.java).addAuthListener(object :
            NEAuthListener {
            override fun onAuthEvent(evt: NEAuthEvent) {
                VoiceRoomLog.i(tag, "onAuthEvent evt = $evt")
                hasLogin = evt == NEAuthEvent.LOGGED_IN
                authListeners.forEach {
                    it.onVoiceRoomAuthEvent(
                        NEVoiceRoomAuthEvent.fromValue(evt.name.uppercase(Locale.getDefault()))
                    )
                }
            }
        })

        initRoomServiceListener()
        launch {
            voiceRoomHttpService.httpErrorEvents.collect { evt ->
                if (evt.code == NEErrorCode.UNAUTHORIZED ||
                    evt.code == NEErrorCode.INCORRECT_TOKEN
                ) {
                    authListeners.forEach {
                        it.onVoiceRoomAuthEvent(NEVoiceRoomAuthEvent.UNAUTHORIZED)
                    }
                } else if (evt.code == NEErrorCode.TOKEN_EXPIRED) {
                    authListeners.forEach {
                        it.onVoiceRoomAuthEvent(NEVoiceRoomAuthEvent.ACCOUNT_TOKEN_ERROR)
                    }
                }
            }
        }
    }

    private fun initRoomServiceListener() {
        myRoomService.addListener(object : NEVoiceRoomListener {
            override fun onMemberJoinRoom(members: List<NEVoiceRoomMember>) {
                listeners.forEach {
                    it.onMemberJoinRoom(members)
                }
            }

            override fun onMemberLeaveRoom(members: List<NEVoiceRoomMember>) {
                listeners.forEach {
                    it.onMemberLeaveRoom(members)
                }
            }

            override fun onMemberJoinChatroom(members: List<NEVoiceRoomMember>) {
                listeners.forEach {
                    it.onMemberJoinChatroom(members)
                }
            }

            override fun onMemberLeaveChatroom(members: List<NEVoiceRoomMember>) {
                listeners.forEach {
                    it.onMemberLeaveChatroom(members)
                }
            }

            override fun onRoomEnded(reason: NEVoiceRoomEndReason) {
                joinedVoiceRoomInfo = null
                createVoiceRoomInfo = null
                listeners.forEach {
                    it.onRoomEnded(reason)
                }
            }

            override fun onRtcChannelError(code: Int) {
                listeners.forEach {
                    it.onRtcChannelError(code)
                }
            }

            override fun onMemberAudioMuteChanged(member: NEVoiceRoomMember, mute: Boolean, operateBy: NEVoiceRoomMember?) {
                listeners.forEach {
                    it.onMemberAudioMuteChanged(member, mute, operateBy)
                }
            }

            override fun onMemberAudioBanned(member: NEVoiceRoomMember, banned: Boolean) {
                listeners.forEach {
                    it.onMemberAudioBanned(member, banned)
                }
            }

            override fun onReceiveTextMessage(message: NEVoiceRoomChatTextMessage) {
                listeners.forEach {
                    it.onReceiveTextMessage(message)
                }
            }

            override fun onSeatRequestSubmitted(seatIndex: Int, account: String) {
                listeners.forEach {
                    it.onSeatRequestSubmitted(seatIndex, account)
                }
            }

            override fun onSeatRequestCancelled(seatIndex: Int, account: String) {
                listeners.forEach {
                    it.onSeatRequestCancelled(seatIndex, account)
                }
            }

            override fun onSeatRequestApproved(seatIndex: Int, account: String, operateBy: String, isAutoAgree: Boolean) {
                listeners.forEach {
                    it.onSeatRequestApproved(seatIndex, account, operateBy, isAutoAgree)
                }
            }

            override fun onSeatRequestRejected(seatIndex: Int, account: String, operateBy: String) {
                listeners.forEach {
                    it.onSeatRequestRejected(seatIndex, account, operateBy)
                }
            }

            override fun onSeatLeave(seatIndex: Int, account: String) {
                listeners.forEach {
                    it.onSeatLeave(seatIndex, account)
                }
            }

            override fun onSeatKicked(seatIndex: Int, account: String, operateBy: String) {
                listeners.forEach {
                    it.onSeatKicked(seatIndex, account, operateBy)
                }
            }

            override fun onSeatInvitationAccepted(seatIndex: Int, account: String, isAutoAgree: Boolean) {
                listeners.forEach {
                    it.onSeatInvitationAccepted(seatIndex, account, isAutoAgree)
                }
            }

            override fun onSeatListChanged(seatItems: List<NEVoiceRoomSeatItem>) {
                listeners.forEach {
                    it.onSeatListChanged(seatItems)
                }
            }

            override fun onAudioMixingStateChanged(reason: Int) {
                listeners.forEach {
                    it.onAudioMixingStateChanged(reason)
                }
            }

            override fun onAudioOutputDeviceChanged(device: NEVoiceRoomAudioOutputDevice) {
                listeners.forEach {
                    it.onAudioOutputDeviceChanged(device)
                }
            }

            override fun onReceiveBatchGift(giftModel: NEVoiceRoomBatchGiftModel) {
                listeners.forEach {
                    it.onReceiveBatchGift(giftModel)
                }
            }

            override fun onAudioEffectTimestampUpdate(effectId: Long, timeStampMS: Long) {
                listeners.forEach {
                    it.onAudioEffectTimestampUpdate(effectId, timeStampMS)
                }
            }

            override fun onRtcLocalAudioVolumeIndication(volume: Int, vadFlag: Boolean) {
                listeners.forEach {
                    it.onRtcLocalAudioVolumeIndication(volume, vadFlag)
                }
            }

            override fun onRtcRemoteAudioVolumeIndication(volumes: List<NEVoiceRoomMemberVolumeInfo>, totalVolume: Int) {
                listeners.forEach {
                    it.onRtcRemoteAudioVolumeIndication(volumes, totalVolume)
                }
            }

            override fun onAudioEffectFinished(effectId: Int) {
                listeners.forEach {
                    it.onAudioEffectFinished(effectId)
                }
            }
        })
    }

    override val isInitialized: Boolean
        get() = NERoomKit.getInstance().isInitialized

    override val isLoggedIn: Boolean
        get() = hasLogin

    override fun login(account: String, token: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("login: account = $account,token = $token")
        if (hasLogin) {
            callback?.onSuccess(Unit)
        } else if (NERoomKit.getInstance().getService(NEAuthService::class.java).isLoggedIn) {
            VoiceRoomLog.i(tag, "login but isLoggedIn = true")
            voiceRoomHttpService.addHeader("user", account)
            voiceRoomHttpService.addHeader("token", token)
            callback?.onSuccess(Unit)
        } else {
            NERoomKit.getInstance().getService(NEAuthService::class.java).login(
                account,
                token,
                object : NECallback2<Unit>() {
                    override fun onSuccess(data: Unit?) {
                        VoiceRoomLog.i(tag, "login success")
                        voiceRoomHttpService.addHeader("user", account)
                        voiceRoomHttpService.addHeader("token", token)
                        hasLogin = true
                        callback?.onSuccess(data)
                    }

                    override fun onError(code: Int, message: String?) {
                        VoiceRoomLog.e(tag, "login error: code=$code, message=$message")
                        callback?.onFailure(code, message)
                        hasLogin = false
                    }
                }
            )
        }
    }

    override fun logout(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("logout")
        hasLogin = false
        NERoomKit.getInstance().getService(NEAuthService::class.java)
            .logout(object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    VoiceRoomLog.i(tag, "logout success")
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "logout error: code=$code, message=$message")
                    callback?.onFailure(code, message)
                }
            })
    }

    /**
     * 获取房间列表
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param liveState 直播状态 (直播状态) [NEVoiceRoomLiveState]
     * @param pageNum 页码
     * @param pageSize 页大小,一页包含多少条
     * @param callback 房间列表回调
     *
     */
    override fun getRoomList(
        liveState: NEVoiceRoomLiveState,
        type: Int,
        pageNum: Int,
        pageSize: Int,
        callback: NEVoiceRoomCallback<NEVoiceRoomList>?
    ) {
        VoiceRoomLog.logApi(
            "getVoiceRoomRoomList: liveState=$liveState, pageNum=$pageNum, pageSize=$pageSize"
        )
        voiceRoomHttpService.getVoiceRoomList(
            type,
            liveState.value,
            pageNum,
            pageSize,
            object :
                NetRequestCallback<VoiceRoomList> {
                override fun error(code: Int, msg: String?) {
                    VoiceRoomLog.e(tag, "getVoiceRoomRoomList error: code = $code msg = $msg")
                    callback?.onFailure(code, msg)
                }

                override fun success(info: VoiceRoomList?) {
                    VoiceRoomLog.i(tag, "getVoiceRoomRoomList success info = $info")
                    callback?.onSuccess(
                        info?.let {
                            VoiceRoomUtils.voiceRoomList2NEVoiceRoomList(
                                it
                            )
                        }
                    )
                }
            }
        )
    }

    override fun addAuthListener(listener: NEVoiceRoomAuthListener) {
        VoiceRoomLog.logApi("addAuthListener: listener=$listener")
        authListeners.add(listener)
    }

    override fun removeAuthListener(listener: NEVoiceRoomAuthListener) {
        VoiceRoomLog.logApi("removeAuthListener: listener=$listener")
        authListeners.remove(listener)
    }

    override fun createRoom(
        params: NECreateVoiceRoomParams,
        options: NECreateVoiceRoomOptions,
        callback: NEVoiceRoomCallback<NEVoiceRoomInfo>?
    ) {
        VoiceRoomLog.logApi("createRoom: params=$params")
        val createRoomParam = StartVoiceRoomParam(
            roomTopic = params.title,
            roomName = params.title,
            liveType = params.liveType,
            configId = params.configId,
            cover = params.cover ?: "",
            seatCount = params.seatCount,
            seatInviteMode = NEVoiceRoomSeatInvitationConfirmMode.OFF,
            seatApplyMode = NEVoiceRoomSeatRequestApprovalMode.ON
        )
        voiceRoomHttpService.startVoiceRoom(
            createRoomParam,
            object : NetRequestCallback<VoiceRoomInfo> {
                override fun error(code: Int, msg: String?) {
                    VoiceRoomLog.e(tag, "createRoom error: code=$code message=$msg")
                    callback?.onFailure(code, msg)
                }

                override fun success(info: VoiceRoomInfo?) {
                    createVoiceRoomInfo = info
                    VoiceRoomLog.i(tag, "createRoom success info = $info")
                    callback?.onSuccess(
                        info?.let {
                            VoiceRoomUtils.voiceRoomInfo2NEVoiceRoomInfo(
                                it
                            )
                        }
                    )
                }
            }
        )
    }

    override fun getCreateRoomDefaultInfo(
        callback: NEVoiceRoomCallback<NEVoiceCreateRoomDefaultInfo>
    ) {
        voiceRoomHttpService.getDefaultLiveInfo(object :
            NetRequestCallback<VoiceRoomDefaultConfig> {
            override fun success(info: VoiceRoomDefaultConfig?) {
                VoiceRoomLog.i(tag, "getRoomDefault success info = $info")
                callback.onSuccess(
                    info?.let {
                        NEVoiceCreateRoomDefaultInfo(it.topic, it.livePicture)
                    }
                )
            }

            override fun error(code: Int, msg: String?) {
                VoiceRoomLog.e(tag, "getRoomDefault error: code=$code message=$msg")
                callback.onFailure(code, msg)
            }
        })
    }

    override fun joinRoom(
        params: NEJoinVoiceRoomParams,
        options: NEJoinVoiceRoomOptions,
        callback: NEVoiceRoomCallback<NEVoiceRoomInfo>?
    ) {
        VoiceRoomLog.logApi("joinRoom: params=$params")
        myRoomService.joinRoom(
            params.roomUuid,
            params.role.value,
            params.nick,
            params.avatar,
            params.extraData,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    VoiceRoomLog.i(tag, "joinRoom success")

                    voiceRoomHttpService.getRoomInfo(
                        params.liveRecordId,
                        object : NetRequestCallback<VoiceRoomInfo> {
                            override fun success(info: VoiceRoomInfo?) {
                                VoiceRoomLog.i(
                                    tag,
                                    "joinRoom  getRoomInfo success"
                                )
                                joinedVoiceRoomInfo = info
                                callback?.onSuccess(
                                    info?.let {
                                        VoiceRoomUtils.voiceRoomInfo2NEVoiceRoomInfo(
                                            it
                                        )
                                    }
                                )
                            }

                            override fun error(code: Int, msg: String?) {
                                VoiceRoomLog.e(
                                    tag,
                                    "get room info after join room error: code = $code message = $msg"
                                )
                                callback?.onFailure(code, msg)
                            }
                        }
                    )
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "joinRoom error: code=$code message=$message")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun endRoom(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("endRoom")

        val liveRecordId = createVoiceRoomInfo?.liveModel?.liveRecordId
            ?: joinedVoiceRoomInfo?.liveModel?.liveRecordId

        liveRecordId?.let {
            voiceRoomHttpService.stopVoiceRoom(
                it,
                object : NetRequestCallback<Unit> {
                    override fun success(info: Unit?) {
                        VoiceRoomLog.i(tag, "stopVoiceRoom success")
                        callback?.onSuccess(info)
                    }

                    override fun error(code: Int, msg: String?) {
                        VoiceRoomLog.e(tag, "stopVoiceRoom error: code = $code message = $msg")
                        callback?.onFailure(code, msg)
                    }
                }
            )
        } ?: callback?.onFailure(NEErrorCode.FAILURE, "roomInfo info is empty")

        myRoomService.endRoom(object : NECallback2<Unit>() {
            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "endRoom error: code = $code message = $message")
            }

            override fun onSuccess(data: Unit?) {
                VoiceRoomLog.i(tag, "endRoom success")
            }
        })
        joinedVoiceRoomInfo = null
        createVoiceRoomInfo = null
        listeners.clear()
    }

    override fun leaveRoom(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("leaveRoom")
        myRoomService.leaveRoom(object : NECallback2<Unit>() {
            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "leaveRoom: error code = $code message = $message")
                callback?.onFailure(code, message)
            }

            override fun onSuccess(data: Unit?) {
                VoiceRoomLog.i(tag, "leaveRoom success")
                callback?.onSuccess(null)
            }
        })
        joinedVoiceRoomInfo = null
        listeners.clear()
    }

    override fun getRoomInfo(liveRecordId: Long, callback: NEVoiceRoomCallback<NEVoiceRoomInfo>) {
        voiceRoomHttpService.getRoomInfo(
            liveRecordId,
            object : NetRequestCallback<VoiceRoomInfo> {
                override fun success(info: VoiceRoomInfo?) {
                    callback.onSuccess(
                        info?.let {
                            VoiceRoomUtils.voiceRoomInfo2NEVoiceRoomInfo(
                                it
                            )
                        }
                    )
                }

                override fun error(code: Int, msg: String?) {
                    callback.onFailure(code, msg)
                }
            }
        )
    }

    override fun getCurrentRoomInfo(): NEVoiceRoomInfo? {
        return joinedVoiceRoomInfo?.let { VoiceRoomUtils.voiceRoomInfo2NEVoiceRoomInfo(it) }
    }

    override fun getSeatInfo(callback: NEVoiceRoomCallback<NEVoiceRoomSeatInfo>?) {
        VoiceRoomLog.logApi("getSeatInfo")
        myRoomService.getSeatInfo(object : NECallback2<NESeatInfo>() {
            override fun onSuccess(data: NESeatInfo?) {
                VoiceRoomLog.i(tag, "getSeatInfo success")
                callback?.onSuccess(
                    data?.let {
                        VoiceRoomUtils.voiceRoomSeatInfo2NEVoiceRoomSeatInfo(
                            it
                        )
                    }
                )
            }

            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "getSeatInfo error:code = $code message = $message")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun getSeatRequestList(
        callback: NEVoiceRoomCallback<List<NEVoiceRoomSeatRequestItem>>?
    ) {
        VoiceRoomLog.logApi("getSeatRequestList")
        myRoomService.getSeatRequestList(object : NECallback2<List<NESeatRequestItem>>() {
            override fun onSuccess(data: List<NESeatRequestItem>?) {
                VoiceRoomLog.i(tag, "getSeatRequestList success")
                callback?.onSuccess(
                    data?.map {
                        VoiceRoomUtils.voiceRoomSeatRequestItem2NEVoiceRoomSeatRequestItem(
                            it
                        )
                    }
                )
            }

            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "getSeatRequestList error:code = $code message = $message")
                callback?.onFailure(code, message)
            }
        })
    }

    /**
     * 房主向成员[account]发送上麦邀请，指定位置为[seatIndex]，非管理员执行该操作会失败。
     * @param seatIndex 麦位位置。
     * @param account 麦上的用户ID。
     * @param callback 回调。
     */
    override fun sendSeatInvitation(
        seatIndex: Int,
        account: String,
        callback: NEVoiceRoomCallback<Unit>?
    ) {
        VoiceRoomLog.logApi("sendSeatInvitation,seatIndex:$seatIndex,account:$account")
        myRoomService.sendSeatInvitation(
            seatIndex,
            account,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "sendSeatInvitation onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun submitSeatRequest(
        seatIndex: Int,
        exclusive: Boolean,
        callback: NEVoiceRoomCallback<Unit>?
    ) {
        VoiceRoomLog.logApi("submitSeatRequest seatIndex:$seatIndex")
        myRoomService.submitSeatRequest(
            seatIndex,
            exclusive,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "submitSeatRequest onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun cancelSeatRequest(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("cancelSeatRequest")
        myRoomService.cancelSeatRequest(object : NECallback2<Unit>() {
            override fun onSuccess(data: Unit?) {
                callback?.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "cancelSeatRequest onError code:$code")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun approveSeatRequest(account: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("approveSeatRequest: account=$account")
        myRoomService.approveSeatRequest(
            account,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "approveSeatRequest onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun rejectSeatRequest(account: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("rejectSeatRequest: account=$account")
        myRoomService.rejectSeatRequest(
            account,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "rejectSeatRequest onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun kickSeat(account: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("kickSeat: account=$account")
        myRoomService.kickSeat(
            account,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "kickSeat onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun leaveSeat(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("leaveSeat")
        myRoomService.leaveSeat(object : NECallback2<Unit>() {
            override fun onSuccess(data: Unit?) {
                callback?.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "leaveSeat onError code:$code")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun banRemoteAudio(account: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("banRemoteAudio: account=$account")
        myRoomService.banRemoteAudio(
            account,
            object : NECallback2<Unit>() {

                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "banRemoteAudio onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun unbanRemoteAudio(account: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("unbanRemoteAudio: account=$account")
        myRoomService.unbanRemoteAudio(
            account,
            object : NECallback2<Unit>() {

                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "unbanRemoteAudio onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    /**
     * 打开麦位
     * @param seatIndices 麦位序号
     * @param callback 打开麦位回调
     */
    override fun openSeats(seatIndices: List<Int>, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("openSeat")
        myRoomService.openSeats(
            seatIndices,
            object : NECallback2<Unit>() {

                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "openSeats onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    /**
     * 关闭麦位
     * @param callback 关闭麦位回调
     */
    override fun closeSeats(seatIndices: List<Int>, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("closeSeat")
        myRoomService.closeSeats(
            seatIndices,
            object : NECallback2<Unit>() {

                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "closeSeats onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun sendTextMessage(content: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("sendTextMessage")
        myRoomService.sendTextMessage(
            content,
            object : NECallback2<Unit>() {

                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    VoiceRoomLog.e(tag, "sendTextMessage onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun muteMyAudio(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("muteMyAudio")
        myRoomService.muteMyAudio(object : NECallback2<Unit>() {

            override fun onSuccess(data: Unit?) {
                callback?.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "muteMyAudio onError code:$code")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun unmuteMyAudio(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("unmuteMyAudio")
        myRoomService.unmuteMyAudio(object : NECallback2<Unit>() {

            override fun onSuccess(data: Unit?) {
                callback?.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "unmuteMyAudio onError code:$code")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun adjustRecordingSignalVolume(volume: Int): Int {
        VoiceRoomLog.logApi("adjustRecordingSignalVolume: volume=$volume ")
        return myRoomService.adjustRecordingSignalVolume(volume)
    }

    /**
     * 获取人声音量
     * @return 人声音量
     */
    override fun getRecordingSignalVolume(): Int {
        VoiceRoomLog.logApi("getRecordingSignalVolume")
        return myRoomService.getRecordingSignalVolume()
    }

    /**
     * 开始播放音乐文件。
     * 该方法指定本地或在线音频文件来和录音设备采集的音频流进行混音。
     * 支持的音乐文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地文件或在线 URL。
     * @param option    创建混音任务配置的选项，包括混音任务类型、混音文件全路径或 URL 等，详细信息请参考 audio.NERtcCreateAudioMixingOption。
     */
    override fun startAudioMixing(option: NEVoiceRoomCreateAudioMixingOption): Int {
        VoiceRoomLog.logApi("startAudioMixing")
        return myRoomService.startAudioMixing(option)
    }

    /**
     * 暂停播放音乐文件及混音。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    override fun pauseAudioMixing(): Int {
        VoiceRoomLog.logApi("pauseAudioMixing")
        return myRoomService.pauseAudioMixing()
    }

    /**
     * 恢复播放伴奏。
     * 该方法恢复混音，继续播放伴奏。请在房间内调用该方法。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    override fun resumeAudioMixing(): Int {
        VoiceRoomLog.logApi("resumeAudioMixing")
        return myRoomService.resumeAudioMixing()
    }

    override fun stopAudioMixing(): Int {
        VoiceRoomLog.logApi("stopAudioMixing")
        return myRoomService.stopAudioMixing()
    }

    /**
     * 设置伴奏音量。
     * 该方法调节混音里伴奏的音量大小。 setAudioMixingSendVolume setAudioMixingPlaybackVolume
     * @param volume    伴奏发送音量。取值范围为 0~100。默认 100，即原始文件音量。
     */
    override fun setAudioMixingVolume(volume: Int): Int {
        VoiceRoomLog.logApi("startAudioMixing")
        return myRoomService.setAudioMixingVolume(volume)
    }

    /**
     * 获取伴奏音量
     * @return Int
     */
    override fun getAudioMixingVolume(): Int {
        VoiceRoomLog.logApi("getAudioMixingVolume")
        return myRoomService.getAudioMixingVolume()
    }

    /**
     * 播放指定音效文件。
     * 该方法播放指定的本地或在线音效文件。
     * 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地 SD 卡中的文件和在线 URL
     * @param effectId    指定音效的 ID。每个音效均应有唯一的 ID。
     * @param option    音效相关参数，包括混音任务类型、混音文件路径等。
     */
    override fun playEffect(effectId: Int, option: NEVoiceRoomCreateAudioEffectOption): Int {
        VoiceRoomLog.logApi("playEffect")
        return myRoomService.playEffect(effectId, option)
    }

    /**
     * 设置音效音量 setEffectPlaybackVolume setEffectSendVolume
     * @param effectId Int
     * @param volume Int
     * @return 0：方法调用成功。其他：方法调用失败
     */
    override fun setEffectVolume(effectId: Int, volume: Int): Int {
        VoiceRoomLog.logApi("setEffectVolume,effectId:$effectId,volume:$volume")
        return myRoomService.setEffectVolume(effectId, volume)
    }

    /**
     * 获取音效音量
     * @return 音效音量
     */
    override fun getEffectVolume(): Int {
        VoiceRoomLog.logApi("getEffectVolume")
        return myRoomService.getEffectVolume()
    }

    override fun stopAllEffect(): Int {
        VoiceRoomLog.logApi("stopAllEffect")
        return myRoomService.stopAllEffect()
    }

    override fun stopEffect(effectId: Int): Int {
        VoiceRoomLog.logApi("stopEffect effectId:$effectId")
        return myRoomService.stopEffect(effectId)
    }

    override fun setPlayingPosition(effectId: Int, position: Long): Int {
        return myRoomService.setPlayingPosition(effectId, position)
    }

    override fun pauseEffect(effectId: Int): Int {
        return myRoomService.pauseEffect(effectId)
    }

    override fun resumeEffect(effectId: Int): Int {
        return myRoomService.resumeEffect(effectId)
    }

    override fun enableAudioVolumeIndication(enable: Boolean, interval: Int): Int {
        return myRoomService.enableAudioVolumeIndication(enable, interval)
    }

    override fun enableEarback(volume: Int): Int {
        VoiceRoomLog.logApi("enableEarBack: volume=$volume")
        return myRoomService.enableEarBack(volume)
    }

    override fun disableEarback(): Int {
        VoiceRoomLog.logApi("disableEarBack")
        return myRoomService.disableEarBack()
    }

    override fun isEarbackEnable(): Boolean {
        VoiceRoomLog.logApi("isEarBackEnable")
        return myRoomService.isEarBackEnable()
    }

    override fun addVoiceRoomListener(listener: NEVoiceRoomListener) {
        VoiceRoomLog.logApi("addVoiceRoomListener: listener=$listener")
        listeners.add(listener)
    }

    override fun removeVoiceRoomListener(listener: NEVoiceRoomListener) {
        VoiceRoomLog.logApi("removeVoiceRoomListener: listener=$listener")
        listeners.remove(listener)
    }

    override fun sendBatchGift(
        giftId: Int,
        giftCount: Int,
        userUuids: List<String>,
        callback: NEVoiceRoomCallback<Unit>?
    ) {
        VoiceRoomLog.logApi(
            "sendBatchGift giftId:$giftId,giftCount:$giftCount,userUuids:$userUuids"
        )
        if (joinedVoiceRoomInfo?.liveModel?.liveRecordId == null) {
            VoiceRoomLog.e(tag, "liveRecordId==null")
            return
        }

        voiceRoomHttpService.batchReward(
            joinedVoiceRoomInfo?.liveModel?.liveRecordId!!,
            giftId,
            giftCount,
            userUuids,
            object : NetRequestCallback<Unit> {
                override fun success(info: Unit?) {
                    VoiceRoomLog.i(tag, "batchReward success")
                    callback?.onSuccess(info)
                }

                override fun error(code: Int, msg: String?) {
                    VoiceRoomLog.e(tag, "batchReward error: code = $code message = $msg")
                    callback?.onFailure(code, msg)
                }
            }
        )
    }

    override fun authenticate(name: String, cardNo: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("realNameAuthentication name:$name,cardNo:$cardNo")
        voiceRoomHttpService.realNameAuthentication(
            name,
            cardNo,
            object : NetRequestCallback<Unit> {
                override fun success(info: Unit?) {
                    VoiceRoomLog.i(tag, "realNameAuthentication success")
                    callback?.onSuccess(info)
                }

                override fun error(code: Int, msg: String?) {
                    VoiceRoomLog.e(tag, "realNameAuthentication error: code = $code message = $msg")
                    callback?.onFailure(code, msg)
                }
            }
        )
    }

    override fun startLastmileProbeTest(config: NEVoiceRoomRtcLastmileProbeConfig): Int {
        if (previewRoomContext == null || previewRoomContext?.previewController == null) {
            VoiceRoomLog.e(tag, "startLastmileProbeTest failed,config:$config")
            return NEVoiceRoomErrorCode.FAILURE
        }
        VoiceRoomLog.i(tag, "startLastmileProbeTest,config:$config")
        return previewRoomContext!!.previewController.startLastmileProbeTest(
            NERoomRtcLastmileProbeConfig(
                probeDownlink = config.probeDownlink,
                probeUplink = config.probeUplink,
                expectedDownlinkBitrate = config.expectedDownlinkBitrate,
                expectedUplinkBitrate = config.expectedUplinkBitrate
            )
        )
    }

    override fun stopLastmileProbeTest(): Int {
        if (previewRoomContext == null || previewRoomContext?.previewController == null) {
            VoiceRoomLog.e(tag, "stopLastmileProbeTest failed")
            return NEVoiceRoomErrorCode.FAILURE
        }
        VoiceRoomLog.i(tag, "stopLastmileProbeTest")
        return previewRoomContext!!.previewController.stopLastmileProbeTest()
    }

    override fun addPreviewListener(listener: NEVoiceRoomPreviewListener) {
        VoiceRoomLog.i(tag, "addPreviewListener,listener:$listener")
        previewRoomListeners.add(listener)
    }

    override fun removePreviewListener(listener: NEVoiceRoomPreviewListener) {
        VoiceRoomLog.i(tag, "removePreviewListener,listener:$listener")
        previewRoomListeners.remove(listener)
    }

    override fun uploadLog() {
        VoiceRoomLog.i(tag, "uploadLog")
        return NERoomKit.getInstance().uploadLog(null)
    }

    override fun switchLanguage(language: NEVoiceRoomLanguage): Int {
        when (language) {
            NEVoiceRoomLanguage.AUTOMATIC -> {
                val localLanguage = Locale.getDefault().language
                voiceRoomHttpService.addHeader(
                    ACCEPT_LANGUAGE_KEY,
                    if (!localLanguage.contains(LANGUAGE_ZH)) LANGUAGE_EN else LANGUAGE_ZH
                )
                return NERoomKit.getInstance().switchLanguage(NERoomLanguage.AUTOMATIC)
            }
            NEVoiceRoomLanguage.CHINESE -> {
                voiceRoomHttpService.addHeader(ACCEPT_LANGUAGE_KEY, LANGUAGE_ZH)
                return NERoomKit.getInstance().switchLanguage(NERoomLanguage.CHINESE)
            }
            NEVoiceRoomLanguage.ENGLISH -> {
                voiceRoomHttpService.addHeader(ACCEPT_LANGUAGE_KEY, LANGUAGE_EN)
                return NERoomKit.getInstance().switchLanguage(NERoomLanguage.ENGLISH)
            }
            else -> return NEVoiceRoomErrorCode.FAILURE
        }
    }
}

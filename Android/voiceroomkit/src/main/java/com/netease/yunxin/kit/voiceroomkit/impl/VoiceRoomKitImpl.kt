/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.impl

import android.content.Context
import android.text.TextUtils
import com.netease.yunxin.kit.common.network.ContextRegistry
import com.netease.yunxin.kit.common.network.NetRequestCallback
import com.netease.yunxin.kit.common.network.ServiceCreator
import com.netease.yunxin.kit.roomkit.api.NECallback2
import com.netease.yunxin.kit.roomkit.api.NEErrorCode
import com.netease.yunxin.kit.roomkit.api.NERoomKit
import com.netease.yunxin.kit.roomkit.api.NERoomKitOptions
import com.netease.yunxin.kit.roomkit.api.model.NEIMServerConfig
import com.netease.yunxin.kit.roomkit.api.model.NEServerConfig
import com.netease.yunxin.kit.roomkit.api.service.NEAuthEvent
import com.netease.yunxin.kit.roomkit.api.service.NEAuthListener
import com.netease.yunxin.kit.roomkit.api.service.NEAuthService
import com.netease.yunxin.kit.roomkit.api.service.NESeatInfo
import com.netease.yunxin.kit.roomkit.api.service.NESeatRequestItem
import com.netease.yunxin.kit.roomkit.impl.repository.ServerConfig
import com.netease.yunxin.kit.roomkit.impl.utils.CoroutineRunner
import com.netease.yunxin.kit.voiceroomkit.BuildConfig
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomOptions
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomParams
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomOptions
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomParams
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAuthEvent
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAuthListener
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKitConfig
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListener
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomLiveState
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceCreateRoomDefaultInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioEffectOption
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioMixingOption
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomList
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatInfo
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

internal class VoiceRoomKitImpl : NEVoiceRoomKit, CoroutineRunner() {
    private val roomMode = 2 // 房间类型（1：互动直播 2：语聊房 3：Karaoke）
    private val voiceRoomHttpService: VoiceRoomHttpService by lazy { VoiceRoomHttpServiceImpl }
    private var voiceRoomInfo: VoiceRoomInfo? = null
    private val myRoomService = VoiceRoomService()
    private val authListeners: ArrayList<NEVoiceRoomAuthListener> by lazy { ArrayList() }
    private lateinit var context: Context
    private var hasLogin: Boolean = false

    companion object {
        private const val tag = "NEVoiceRoomKit"
        private const val ACCEPT_LANGUAGE_KEY = "Accept-Language"
        private const val SERVER_URL_KEY = "serverUrl"
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

    override fun initialize(
        context: Context,
        config: NEVoiceRoomKitConfig,
        callback: NEVoiceRoomCallback<Unit>?
    ) {
        VoiceRoomLog.logApi("initialize")
        this.context = context
        this.config = config
        ContextRegistry.context = context
        ScreenUtil.init(context)
        var realServerUrl = ""
        var isOversea = false
        val realExtras = HashMap<String, String>()
        if (config.extras[SERVER_URL_KEY] != null) {
            val serverUrl: String = config.extras[SERVER_URL_KEY] as String
            VoiceRoomLog.d(tag, "serverUrl:$serverUrl")
            if (!TextUtils.isEmpty(serverUrl)) {
                when {
                    TEST_URL_VALUE == serverUrl -> {
                        realServerUrl = serverUrl
                    }
                    OVER_URL_VALUE == serverUrl -> {
                        realServerUrl = OVERSEA_SERVER_URL
                        isOversea = true
                    }
                    serverUrl.startsWith(HTTP_PREFIX) -> {
                        realServerUrl = serverUrl
                    }
                }
            }
        }
        realExtras[SERVER_URL_KEY] = realServerUrl
        val serverConfig =
            ServerConfig.selectServer(config.appKey, realServerUrl)
        VoiceRoomRepository.serverConfig = serverConfig
        val localLanguage = Locale.getDefault().language
        val collectHeaders: Map<String, String> = mapOf(ACCEPT_LANGUAGE_KEY to localLanguage)
        ServiceCreator.collectHeaders = collectHeaders
        ServiceCreator.init(
            context,
            serverConfig.serverUrl,
            if (BuildConfig.DEBUG) ServiceCreator.LOG_LEVEL_BODY else ServiceCreator.LOG_LEVEL_BASIC
        )

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
                        }
                    } else {
                        null
                    }
                )
            ) { code, message, _ ->
                if (code == NEErrorCode.SUCCESS) {
                    callback?.onSuccess(Unit)
                } else {
                    callback?.onFailure(code, message)
                }
            }

        NERoomKit.getInstance().getService(NEAuthService::class.java).addAuthListener(object :
                NEAuthListener {
                override fun onAuthEvent(evt: NEAuthEvent) {
                    VoiceRoomLog.i(tag, "onAuthEvent evt = $evt")
                    authListeners.forEach {
                        it.onVoiceRoomAuthEvent(NEVoiceRoomAuthEvent.fromValue(evt.name.uppercase(Locale.getDefault())))
                    }
                }
            })
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

    override val isInitialized: Boolean
        get() = NERoomKit.getInstance().isInitialized

    override val isLoggedIn: Boolean
        get() = hasLogin

    override fun login(account: String, token: String, callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("login: account = $account,token = $token")
        if (ServiceCreator.user == account && ServiceCreator.token == token) {
            callback?.onSuccess(Unit)
        } else {
            NERoomKit.getInstance().getService(NEAuthService::class.java).login(
                account,
                token,
                object : NECallback2<Unit>() {
                    override fun onSuccess(data: Unit?) {
                        VoiceRoomLog.i(tag, "login success")
                        ServiceCreator.user = account
                        ServiceCreator.token = token
                        callback?.onSuccess(data)
                        hasLogin = true
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
        ServiceCreator.user = null
        ServiceCreator.token = null
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
    override fun getVoiceRoomList(
        liveState: NEVoiceRoomLiveState,
        pageNum: Int,
        pageSize: Int,
        callback: NEVoiceRoomCallback<NEVoiceRoomList>?
    ) {
        VoiceRoomLog.logApi("getVoiceRoomRoomList: liveState=$liveState, pageNum=$pageNum, pageSize=$pageSize")
        voiceRoomHttpService.getVoiceRoomList(
            roomMode,
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
                    VoiceRoomLog.d(tag, "getVoiceRoomRoomList success info = $info")
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
            params.title,
            params.nick,
            liveType = roomMode,
            configId = params.configId,
            cover = params.cover ?: "",
            seatCount = params.seatCount
        )
        voiceRoomHttpService.startVoiceRoom(
            createRoomParam,
            object : NetRequestCallback<VoiceRoomInfo> {
                override fun error(code: Int, msg: String?) {
                    VoiceRoomLog.e(tag, "createRoom error: code=$code message=$msg")
                    callback?.onFailure(code, msg)
                }

                override fun success(info: VoiceRoomInfo?) {
                    voiceRoomInfo = info
                    VoiceRoomLog.d(tag, "createRoom success info = $info")
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

    override fun getCreateRoomDefaultInfo(callback: NEVoiceRoomCallback<NEVoiceCreateRoomDefaultInfo>) {
        voiceRoomHttpService.getDefaultLiveInfo(object :
                NetRequestCallback<VoiceRoomDefaultConfig> {
                override fun success(info: VoiceRoomDefaultConfig?) {
                    VoiceRoomLog.d(tag, "getRoomDefault success info = $info")
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
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    VoiceRoomLog.i(tag, "joinRoom success")

                    voiceRoomHttpService.getRoomInfo(
                        params.liveRecordId,
                        object : NetRequestCallback<VoiceRoomInfo> {
                            override fun success(info: VoiceRoomInfo?) {
                                VoiceRoomLog.d(
                                    tag,
                                    "joinRoom  getRoomInfo success"
                                )
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
                    VoiceRoomLog.d(tag, "joinRoom error: code=$code message=$message")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun endRoom(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("endRoom")
        voiceRoomInfo?.let {
            voiceRoomHttpService.stopVoiceRoom(
                it.liveModel.liveRecordId,
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
    }

    override fun leaveRoom(callback: NEVoiceRoomCallback<Unit>?) {
        VoiceRoomLog.logApi("leaveRoom")
        myRoomService.leaveRoom(object : NECallback2<Unit>() {
            override fun onError(code: Int, message: String?) {
                VoiceRoomLog.e(tag, "leaveRoom: error code = $code message = $message")
                callback?.onFailure(code, message)
            }

            override fun onSuccess(data: Unit?) {
                VoiceRoomLog.d(tag, "leaveRoom success")
                callback?.onSuccess(null)
            }
        })
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

    override fun getSeatRequestList(callback: NEVoiceRoomCallback<List<NEVoiceRoomSeatRequestItem>>?) {
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
        myRoomService.addListener(listener)
    }

    override fun removeVoiceRoomListener(listener: NEVoiceRoomListener) {
        VoiceRoomLog.logApi("removeVoiceRoomListener: listener=$listener")
        myRoomService.removeListener(listener)
    }
}

/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.impl

import android.content.Context
import android.text.TextUtils
import com.netease.yunxin.kit.common.network.ContextRegistry
import com.netease.yunxin.kit.common.network.NetRequestCallback
import com.netease.yunxin.kit.common.network.ServiceCreator
import com.netease.yunxin.kit.listentogetherkit.BuildConfig
import com.netease.yunxin.kit.listentogetherkit.api.NECreateListenTogetherRoomOptions
import com.netease.yunxin.kit.listentogetherkit.api.NECreateListenTogetherRoomParams
import com.netease.yunxin.kit.listentogetherkit.api.NEJoinListenTogetherRoomOptions
import com.netease.yunxin.kit.listentogetherkit.api.NEJoinListenTogetherRoomParams
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherCallback
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKitConfig
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherLiveState
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherRoomAuthListener
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherRoomListener
import com.netease.yunxin.kit.listentogetherkit.api.NEVoiceRoomAuthEvent
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherCreateRoomDefaultInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioEffectOption
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioMixingOption
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomMember
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomSeatInfo
import com.netease.yunxin.kit.listentogetherkit.api.model.NERoomList
import com.netease.yunxin.kit.listentogetherkit.impl.model.ListenTogetherRoomDefaultConfig
import com.netease.yunxin.kit.listentogetherkit.impl.model.ListenTogetherRoomInfo
import com.netease.yunxin.kit.listentogetherkit.impl.model.StartListenTogetherRoomParam
import com.netease.yunxin.kit.listentogetherkit.impl.model.response.VoiceRoomList
import com.netease.yunxin.kit.listentogetherkit.impl.repository.ListenTogetherRepository
import com.netease.yunxin.kit.listentogetherkit.impl.service.ListenTogetherHttpServiceImpl
import com.netease.yunxin.kit.listentogetherkit.impl.service.ListenTogetherService
import com.netease.yunxin.kit.listentogetherkit.impl.service.VoiceRoomHttpService
import com.netease.yunxin.kit.listentogetherkit.impl.utils.ListenTogetherLog
import com.netease.yunxin.kit.listentogetherkit.impl.utils.ScreenUtil
import com.netease.yunxin.kit.listentogetherkit.impl.utils.VoiceRoomUtils
import com.netease.yunxin.kit.roomkit.api.NECallback2
import com.netease.yunxin.kit.roomkit.api.NEErrorCode
import com.netease.yunxin.kit.roomkit.api.NERoomKit
import com.netease.yunxin.kit.roomkit.api.NERoomKitOptions
import com.netease.yunxin.kit.roomkit.api.model.NEIMServerConfig
import com.netease.yunxin.kit.roomkit.api.model.NERoomKitServerConfig
import com.netease.yunxin.kit.roomkit.api.model.NEServerConfig
import com.netease.yunxin.kit.roomkit.api.service.NEAuthEvent
import com.netease.yunxin.kit.roomkit.api.service.NEAuthListener
import com.netease.yunxin.kit.roomkit.api.service.NEAuthService
import com.netease.yunxin.kit.roomkit.api.service.NESeatInfo
import com.netease.yunxin.kit.roomkit.impl.repository.ServerConfig
import com.netease.yunxin.kit.roomkit.impl.utils.CoroutineRunner
import java.util.Locale

internal class ListenTogetherKitImpl : NEListenTogetherKit, CoroutineRunner() {
    private val voiceRoomHttpService: VoiceRoomHttpService by lazy { ListenTogetherHttpServiceImpl }
    private var voiceRoomInfo: ListenTogetherRoomInfo? = null
    private val myRoomService = ListenTogetherService()
    private val authListeners: ArrayList<NEListenTogetherRoomAuthListener> by lazy { ArrayList() }
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

    override val localMember: NEListenTogetherRoomMember?
        get() = myRoomService.getLocalMember()

    override val allMemberList: List<NEListenTogetherRoomMember>
        get() {
            return myRoomService.getLocalMember()?.let {
                val list = mutableListOf(it)
                list.addAll(myRoomService.getRemoteMembers())
                list
            } ?: emptyList()
        }

    private var config: NEListenTogetherKitConfig? = null

    override fun initialize(
        context: Context,
        config: NEListenTogetherKitConfig,
        callback: NEListenTogetherCallback<Unit>?
    ) {
        ListenTogetherLog.logApi("initialize")
        this.context = context
        this.config = config
        ContextRegistry.context = context
        ScreenUtil.init(context)
        var realServerUrl = ""
        var isOversea = false
        val realExtras = HashMap<String, String>()
        if (config.extras[SERVER_URL_KEY] != null) {
            val serverUrl: String = config.extras[SERVER_URL_KEY] as String
            ListenTogetherLog.d(tag, "serverUrl:$serverUrl")
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
        ListenTogetherRepository.serverConfig = serverConfig
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
                                roomServer = realServerUrl
                            }
                        }
                    } else {
                        null
                    }
                )
            ) { code, message, _ ->
                if (code == NEErrorCode.SUCCESS) {
                    val localLanguage = Locale.getDefault().language
                    val collectHeaders: Map<String, String> = mapOf(
                        ACCEPT_LANGUAGE_KEY to localLanguage
                    )
                    ServiceCreator.collectHeaders = collectHeaders
                    ServiceCreator.init(
                        context,
                        serverConfig.serverUrl,
                        if (BuildConfig.DEBUG) ServiceCreator.LOG_LEVEL_BODY else ServiceCreator.LOG_LEVEL_BASIC,
                        NERoomKit.getInstance().deviceId
                    )
                    callback?.onSuccess(Unit)
                } else {
                    callback?.onFailure(code, message)
                }
            }

        NERoomKit.getInstance().getService(NEAuthService::class.java).addAuthListener(object :
                NEAuthListener {
                override fun onAuthEvent(evt: NEAuthEvent) {
                    ListenTogetherLog.i(tag, "onAuthEvent evt = $evt")
                    authListeners.forEach {
                        it.onListenTogetherRoomAuthEvent(
                            NEVoiceRoomAuthEvent.fromValue(evt.name.uppercase(Locale.getDefault()))
                        )
                    }
                }
            })
        launch {
            voiceRoomHttpService.httpErrorEvents.collect { evt ->
                if (evt.code == NEErrorCode.UNAUTHORIZED ||
                    evt.code == NEErrorCode.INCORRECT_TOKEN
                ) {
                    authListeners.forEach {
                        it.onListenTogetherRoomAuthEvent(NEVoiceRoomAuthEvent.UNAUTHORIZED)
                    }
                } else if (evt.code == NEErrorCode.TOKEN_EXPIRED) {
                    authListeners.forEach {
                        it.onListenTogetherRoomAuthEvent(NEVoiceRoomAuthEvent.ACCOUNT_TOKEN_ERROR)
                    }
                }
            }
        }
    }

    override val isInitialized: Boolean
        get() = NERoomKit.getInstance().isInitialized

    override val isLoggedIn: Boolean
        get() = hasLogin

    override fun login(account: String, token: String, callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("login: account = $account,token = $token")
        if (ServiceCreator.user == account && ServiceCreator.token == token) {
            callback?.onSuccess(Unit)
        } else {
            NERoomKit.getInstance().getService(NEAuthService::class.java).login(
                account,
                token,
                object : NECallback2<Unit>() {
                    override fun onSuccess(data: Unit?) {
                        ListenTogetherLog.i(tag, "login success")
                        ServiceCreator.user = account
                        ServiceCreator.token = token
                        callback?.onSuccess(data)
                        hasLogin = true
                    }

                    override fun onError(code: Int, message: String?) {
                        ListenTogetherLog.e(tag, "login error: code=$code, message=$message")
                        callback?.onFailure(code, message)
                        hasLogin = false
                    }
                }
            )
        }
    }

    override fun logout(callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("logout")
        ServiceCreator.user = null
        ServiceCreator.token = null
        NERoomKit.getInstance().getService(NEAuthService::class.java)
            .logout(object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    ListenTogetherLog.i(tag, "logout success")
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    ListenTogetherLog.e(tag, "logout error: code=$code, message=$message")
                    callback?.onFailure(code, message)
                }
            })
    }

    /**
     * 获取房间列表
     * <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
     * @param liveState 直播状态 (直播状态) [NEListenTogetherLiveState]
     * @param liveType 直播类型
     * @param pageNum 页码
     * @param pageSize 页大小,一页包含多少条
     * @param callback 房间列表回调
     *
     */
    override fun getVoiceRoomList(
        liveState: NEListenTogetherLiveState,
        liveType: Int,
        pageNum: Int,
        pageSize: Int,
        callback: NEListenTogetherCallback<NERoomList>?
    ) {
        ListenTogetherLog.logApi(
            "getVoiceRoomRoomList: liveState=$liveState, pageNum=$pageNum, pageSize=$pageSize"
        )
        voiceRoomHttpService.getVoiceRoomList(
            liveType,
            liveState.value,
            pageNum,
            pageSize,
            object :
                NetRequestCallback<VoiceRoomList> {
                override fun error(code: Int, msg: String?) {
                    ListenTogetherLog.e(tag, "getVoiceRoomRoomList error: code = $code msg = $msg")
                    callback?.onFailure(code, msg)
                }

                override fun success(info: VoiceRoomList?) {
                    ListenTogetherLog.d(tag, "getVoiceRoomRoomList success info = $info")
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

    override fun addAuthListener(listener: NEListenTogetherRoomAuthListener) {
        ListenTogetherLog.logApi("addAuthListener: listener=$listener")
        authListeners.add(listener)
    }

    override fun removeAuthListener(listener: NEListenTogetherRoomAuthListener) {
        ListenTogetherLog.logApi("removeAuthListener: listener=$listener")
        authListeners.remove(listener)
    }

    override fun createRoom(
        params: NECreateListenTogetherRoomParams,
        options: NECreateListenTogetherRoomOptions,
        callback: NEListenTogetherCallback<NEListenTogetherRoomInfo>?
    ) {
        ListenTogetherLog.logApi("createRoom: params=$params")
        val createRoomParam = StartListenTogetherRoomParam(
            params.title,
            params.nick,
            liveType = params.liveType,
            configId = params.configId,
            cover = params.cover ?: "",
            seatCount = params.seatCount
        )
        voiceRoomHttpService.startVoiceRoom(
            createRoomParam,
            object : NetRequestCallback<ListenTogetherRoomInfo> {
                override fun error(code: Int, msg: String?) {
                    ListenTogetherLog.e(tag, "createRoom error: code=$code message=$msg")
                    callback?.onFailure(code, msg)
                }

                override fun success(info: ListenTogetherRoomInfo?) {
                    voiceRoomInfo = info
                    ListenTogetherLog.d(tag, "createRoom success info = $info")
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
        callback: NEListenTogetherCallback<NEListenTogetherCreateRoomDefaultInfo>
    ) {
        voiceRoomHttpService.getDefaultLiveInfo(object :
                NetRequestCallback<ListenTogetherRoomDefaultConfig> {
                override fun success(info: ListenTogetherRoomDefaultConfig?) {
                    ListenTogetherLog.d(tag, "getRoomDefault success info = $info")
                    callback.onSuccess(
                        info?.let {
                            NEListenTogetherCreateRoomDefaultInfo(it.topic, it.livePicture)
                        }
                    )
                }

                override fun error(code: Int, msg: String?) {
                    ListenTogetherLog.e(tag, "getRoomDefault error: code=$code message=$msg")
                    callback.onFailure(code, msg)
                }
            })
    }

    override fun joinRoom(
        params: NEJoinListenTogetherRoomParams,
        options: NEJoinListenTogetherRoomOptions,
        callback: NEListenTogetherCallback<NEListenTogetherRoomInfo>?
    ) {
        ListenTogetherLog.logApi("joinRoom: params=$params")
        myRoomService.joinRoom(
            params.roomUuid,
            params.role.value,
            params.nick,
            params.avatar,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    ListenTogetherLog.i(tag, "joinRoom success")

                    voiceRoomHttpService.getRoomInfo(
                        params.liveRecordId,
                        object : NetRequestCallback<ListenTogetherRoomInfo> {
                            override fun success(info: ListenTogetherRoomInfo?) {
                                ListenTogetherLog.d(
                                    tag,
                                    "joinRoom  getRoomInfo success"
                                )
                                voiceRoomInfo = info
                                callback?.onSuccess(
                                    info?.let {
                                        VoiceRoomUtils.voiceRoomInfo2NEVoiceRoomInfo(
                                            it
                                        )
                                    }
                                )
                            }

                            override fun error(code: Int, msg: String?) {
                                ListenTogetherLog.e(
                                    tag,
                                    "get room info after join room error: code = $code message = $msg"
                                )
                                callback?.onFailure(code, msg)
                            }
                        }
                    )
                }

                override fun onError(code: Int, message: String?) {
                    ListenTogetherLog.d(tag, "joinRoom error: code=$code message=$message")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun endRoom(callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("endRoom")
        voiceRoomInfo?.let {
            voiceRoomHttpService.stopVoiceRoom(
                it.liveModel.liveRecordId,
                object : NetRequestCallback<Unit> {
                    override fun success(info: Unit?) {
                        ListenTogetherLog.i(tag, "stopVoiceRoom success")
                        callback?.onSuccess(info)
                    }

                    override fun error(code: Int, msg: String?) {
                        ListenTogetherLog.e(tag, "stopVoiceRoom error: code = $code message = $msg")
                        callback?.onFailure(code, msg)
                    }
                }
            )
        } ?: callback?.onFailure(NEErrorCode.FAILURE, "roomInfo info is empty")

        myRoomService.endRoom(object : NECallback2<Unit>() {
            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(tag, "endRoom error: code = $code message = $message")
            }

            override fun onSuccess(data: Unit?) {
                ListenTogetherLog.i(tag, "endRoom success")
            }
        })
    }

    override fun leaveRoom(callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("leaveRoom")
        myRoomService.leaveRoom(object : NECallback2<Unit>() {
            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(tag, "leaveRoom: error code = $code message = $message")
                callback?.onFailure(code, message)
            }

            override fun onSuccess(data: Unit?) {
                ListenTogetherLog.d(tag, "leaveRoom success")
                callback?.onSuccess(null)
            }
        })
    }

    override fun getRoomInfo(liveRecordId: Long, callback: NEListenTogetherCallback<NEListenTogetherRoomInfo>) {
        voiceRoomHttpService.getRoomInfo(
            liveRecordId,
            object : NetRequestCallback<ListenTogetherRoomInfo> {
                override fun success(info: ListenTogetherRoomInfo?) {
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

    override fun getSeatInfo(callback: NEListenTogetherCallback<NEListenTogetherRoomSeatInfo>?) {
        ListenTogetherLog.logApi("getSeatInfo")
        myRoomService.getSeatInfo(object : NECallback2<NESeatInfo>() {
            override fun onSuccess(data: NESeatInfo?) {
                ListenTogetherLog.i(tag, "getSeatInfo success")
                callback?.onSuccess(
                    data?.let {
                        VoiceRoomUtils.voiceRoomSeatInfo2NEVoiceRoomSeatInfo(
                            it
                        )
                    }
                )
            }

            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(tag, "getSeatInfo error:code = $code message = $message")
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
        callback: NEListenTogetherCallback<Unit>?
    ) {
        ListenTogetherLog.logApi("sendSeatInvitation,seatIndex:$seatIndex,account:$account")
        myRoomService.sendSeatInvitation(
            seatIndex,
            account,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    ListenTogetherLog.e(tag, "sendSeatInvitation onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun submitSeatRequest(
        seatIndex: Int,
        exclusive: Boolean,
        callback: NEListenTogetherCallback<Unit>?
    ) {
        ListenTogetherLog.logApi("submitSeatRequest seatIndex:$seatIndex")
        myRoomService.submitSeatRequest(
            seatIndex,
            exclusive,
            object : NECallback2<Unit>() {
                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    ListenTogetherLog.e(tag, "submitSeatRequest onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun leaveSeat(callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("leaveSeat")
        myRoomService.leaveSeat(object : NECallback2<Unit>() {
            override fun onSuccess(data: Unit?) {
                callback?.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(tag, "leaveSeat onError code:$code")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun sendTextMessage(content: String, callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("sendTextMessage")
        myRoomService.sendTextMessage(
            content,
            object : NECallback2<Unit>() {

                override fun onSuccess(data: Unit?) {
                    callback?.onSuccess(data)
                }

                override fun onError(code: Int, message: String?) {
                    ListenTogetherLog.e(tag, "sendTextMessage onError code:$code")
                    callback?.onFailure(code, message)
                }
            }
        )
    }

    override fun muteMyAudio(callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("muteMyAudio")
        myRoomService.muteMyAudio(object : NECallback2<Unit>() {

            override fun onSuccess(data: Unit?) {
                callback?.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(tag, "muteMyAudio onError code:$code")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun unmuteMyAudio(callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("unmuteMyAudio")
        myRoomService.unmuteMyAudio(object : NECallback2<Unit>() {

            override fun onSuccess(data: Unit?) {
                callback?.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(tag, "unmuteMyAudio onError code:$code")
                callback?.onFailure(code, message)
            }
        })
    }

    override fun adjustRecordingSignalVolume(volume: Int): Int {
        ListenTogetherLog.logApi("adjustRecordingSignalVolume: volume=$volume ")
        return myRoomService.adjustRecordingSignalVolume(volume)
    }

    /**
     * 获取人声音量
     * @return 人声音量
     */
    override fun getRecordingSignalVolume(): Int {
        ListenTogetherLog.logApi("getRecordingSignalVolume")
        return myRoomService.getRecordingSignalVolume()
    }

    /**
     * 开始播放音乐文件。
     * 该方法指定本地或在线音频文件来和录音设备采集的音频流进行混音。
     * 支持的音乐文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地文件或在线 URL。
     * @param option    创建混音任务配置的选项，包括混音任务类型、混音文件全路径或 URL 等，详细信息请参考 audio.NERtcCreateAudioMixingOption。
     */
    override fun startAudioMixing(option: NEListenTogetherRoomCreateAudioMixingOption): Int {
        ListenTogetherLog.logApi("startAudioMixing")
        return myRoomService.startAudioMixing(option)
    }

    /**
     * 暂停播放音乐文件及混音。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    override fun pauseAudioMixing(): Int {
        ListenTogetherLog.logApi("pauseAudioMixing")
        return myRoomService.pauseAudioMixing()
    }

    /**
     * 恢复播放伴奏。
     * 该方法恢复混音，继续播放伴奏。请在房间内调用该方法。
     * @return 0：方法调用成功。其他：方法调用失败
     */
    override fun resumeAudioMixing(): Int {
        ListenTogetherLog.logApi("resumeAudioMixing")
        return myRoomService.resumeAudioMixing()
    }

    override fun stopAudioMixing(): Int {
        ListenTogetherLog.logApi("stopAudioMixing")
        return myRoomService.stopAudioMixing()
    }

    /**
     * 设置伴奏音量。
     * 该方法调节混音里伴奏的音量大小。 setAudioMixingSendVolume setAudioMixingPlaybackVolume
     * @param volume    伴奏发送音量。取值范围为 0~100。默认 100，即原始文件音量。
     */
    override fun setAudioMixingVolume(volume: Int): Int {
        ListenTogetherLog.logApi("startAudioMixing")
        return myRoomService.setAudioMixingVolume(volume)
    }

    /**
     * 获取伴奏音量
     * @return Int
     */
    override fun getAudioMixingVolume(): Int {
        ListenTogetherLog.logApi("getAudioMixingVolume")
        return myRoomService.getAudioMixingVolume()
    }

    /**
     * 播放指定音效文件。
     * 该方法播放指定的本地或在线音效文件。
     * 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地 SD 卡中的文件和在线 URL
     * @param effectId    指定音效的 ID。每个音效均应有唯一的 ID。
     * @param option    音效相关参数，包括混音任务类型、混音文件路径等。
     */
    override fun playEffect(effectId: Int, option: NEListenTogetherRoomCreateAudioEffectOption): Int {
        ListenTogetherLog.logApi("playEffect")
        return myRoomService.playEffect(effectId, option)
    }

    /**
     * 设置音效音量 setEffectPlaybackVolume setEffectSendVolume
     * @param effectId Int
     * @param volume Int
     * @return 0：方法调用成功。其他：方法调用失败
     */
    override fun setEffectVolume(effectId: Int, volume: Int): Int {
        ListenTogetherLog.logApi("setEffectVolume,effectId:$effectId,volume:$volume")
        return myRoomService.setEffectVolume(effectId, volume)
    }

    /**
     * 获取音效音量
     * @return 音效音量
     */
    override fun getEffectVolume(): Int {
        ListenTogetherLog.logApi("getEffectVolume")
        return myRoomService.getEffectVolume()
    }

    override fun stopAllEffect(): Int {
        ListenTogetherLog.logApi("stopAllEffect")
        return myRoomService.stopAllEffect()
    }

    override fun stopEffect(effectId: Int): Int {
        ListenTogetherLog.logApi("stopEffect effectId:$effectId")
        return myRoomService.stopEffect(effectId)
    }

    override fun sendGift(giftId: Int, callback: NEListenTogetherCallback<Unit>?) {
        ListenTogetherLog.logApi("sendGift giftId:$giftId")
        if (voiceRoomInfo?.liveModel?.liveRecordId == null) {
            ListenTogetherLog.e(tag, "liveRecordId==null")
            return
        }

        voiceRoomHttpService.reward(
            voiceRoomInfo?.liveModel?.liveRecordId!!,
            giftId,
            object : NetRequestCallback<Unit> {
                override fun success(info: Unit?) {
                    ListenTogetherLog.i(tag, "reward success")
                    callback?.onSuccess(info)
                }

                override fun error(code: Int, msg: String?) {
                    ListenTogetherLog.e(tag, "reward error: code = $code message = $msg")
                    callback?.onFailure(code, msg)
                }
            }
        )
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

    override fun enableEarback(volume: Int): Int {
        ListenTogetherLog.logApi("enableEarBack: volume=$volume")
        return myRoomService.enableEarBack(volume)
    }

    override fun disableEarback(): Int {
        ListenTogetherLog.logApi("disableEarBack")
        return myRoomService.disableEarBack()
    }

    override fun isEarbackEnable(): Boolean {
        ListenTogetherLog.logApi("isEarBackEnable")
        return myRoomService.isEarBackEnable()
    }

    override fun addRoomListener(listener: NEListenTogetherRoomListener) {
        ListenTogetherLog.logApi("addVoiceRoomListener: listener=$listener")
        myRoomService.addListener(listener)
    }

    override fun removeRoomListener(listener: NEListenTogetherRoomListener) {
        ListenTogetherLog.logApi("removeVoiceRoomListener: listener=$listener")
        myRoomService.removeListener(listener)
    }
}

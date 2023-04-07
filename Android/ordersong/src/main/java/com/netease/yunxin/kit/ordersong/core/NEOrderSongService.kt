/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.ordersong.core

import android.content.Context
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.common.network.NetRequestCallback
import com.netease.yunxin.kit.common.network.Request
import com.netease.yunxin.kit.copyrightedmedia.api.NECopyrightedMedia
import com.netease.yunxin.kit.copyrightedmedia.api.SongScene
import com.netease.yunxin.kit.ordersong.core.constant.OrderSongCmd
import com.netease.yunxin.kit.ordersong.core.http.OrderSongRepository
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSong
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSongDynamicToken
import com.netease.yunxin.kit.ordersong.core.model.OrderSong
import com.netease.yunxin.kit.ordersong.core.model.OrderSongEvent
import com.netease.yunxin.kit.ordersong.core.model.OrderSongModel
import com.netease.yunxin.kit.ordersong.core.model.SongPlayEvent
import com.netease.yunxin.kit.ordersong.core.util.GsonUtils
import com.netease.yunxin.kit.ordersong.core.util.NERoomListenerWrapper
import com.netease.yunxin.kit.ordersong.core.util.TimerTaskUtil
import com.netease.yunxin.kit.roomkit.api.NERoomChatMessage
import com.netease.yunxin.kit.roomkit.api.NERoomKit
import com.netease.yunxin.kit.roomkit.api.service.NERoomService
import com.netease.yunxin.kit.roomkit.impl.model.RoomCustomMessages
import kotlin.math.pow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import org.json.JSONObject

/**
 * 点歌台服务
 */
object NEOrderSongService {
    private var hasAddRoomListen = false
    private var roomUuid: String? = null
    const val TAG = "NEOrderSongService"

    private var orderSongRepository = OrderSongRepository()

    private var coroutineScope: CoroutineScope? = null
    private val copyrightedMedia = NECopyrightedMedia.getInstance()
    private const val refreshTokenTaskId = 430
    private const val tokenWillExpiredTaskId = 431
    private const val refreshTokenRetryTimes = 3
    private const val aheadTimeRefreshToken = 180
    var appKey = ""
    private val roomListener = object : NERoomListenerWrapper() {
        override fun onReceiveChatroomMessages(messages: List<NERoomChatMessage>) {
            messages.forEach {
                if (it is RoomCustomMessages) {
                    val jsonObject = JSONObject(it.attachStr)
                    val data = jsonObject.opt("data")
                    if (data != null) {
                        val dataJsonObject = data as JSONObject
                        when (dataJsonObject.optInt("cmd")) {
                            OrderSongCmd.ORDER_SONG_CMD -> {
                                val event =
                                    GsonUtils.fromJson(it.attachStr, OrderSongEvent::class.java)
                                ALog.i(TAG, "onSongOrdered,event:$event")
                                listeners.forEach { listener ->
                                    listener.onSongOrdered(event.data.data)
                                }
                            }
                            OrderSongCmd.CANCEL_ORDER_SONG_CMD -> {
                                val event =
                                    GsonUtils.fromJson(it.attachStr, OrderSongEvent::class.java)
                                ALog.i(TAG, "onSongDeleted,event:$event")
                                listeners.forEach { listener ->
                                    listener.onSongDeleted(event.data.data)
                                }
                            }
                            OrderSongCmd.SWITCH_SONG_CMD -> {
                                val event =
                                    GsonUtils.fromJson(it.attachStr, OrderSongEvent::class.java)
                                ALog.i(TAG, "onSongSwitched,event:$event")
                                listeners.forEach { listener ->
                                    listener.onSongSwitched(event.data.data)
                                }
                            }

                            OrderSongCmd.ORDERED_SONG_LIST_CHANGED_CMD -> {
                                ALog.i(TAG, "onOrderedSongListChanged")
                                listeners.forEach { listener ->
                                    listener.onOrderedSongListChanged()
                                }
                            }
                            OrderSongCmd.START_PLAY_CMD -> {
                                val event =
                                    GsonUtils.fromJson(it.attachStr, SongPlayEvent::class.java)
                                val song = event.data.data.playMusicInfo
                                song.operator = event.data.data.operatorInfo
                                ALog.i(TAG, "onSongStarted")
                                listeners.forEach { listener ->
                                    listener.onSongStarted(song)
                                }
                            }
                            OrderSongCmd.PAUSE_PLAY_CMD -> {
                                val event =
                                    GsonUtils.fromJson(it.attachStr, SongPlayEvent::class.java)
                                val song = event.data.data.playMusicInfo
                                song.operator = event.data.data.operatorInfo
                                ALog.i(TAG, "onSongPaused")
                                listeners.forEach { listener ->
                                    listener.onSongPaused(song)
                                }
                            }
                            OrderSongCmd.RESUME_PLAY_CMD -> {
                                val event =
                                    GsonUtils.fromJson(it.attachStr, SongPlayEvent::class.java)
                                val song = event.data.data.playMusicInfo
                                song.operator = event.data.data.operatorInfo
                                ALog.i(TAG, "onSongResumed")
                                listeners.forEach { listener ->
                                    listener.onSongResumed(song)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    init {
        coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    }

    fun initialize(context: Context, appKey: String, serverUrl: String, account: String) {
        NEOrderSongService.appKey = appKey
        TimerTaskUtil.init()
        orderSongRepository.initialize(context, serverUrl)
        getSongDynamicTokenUntilSuccess(object :
            NetRequestCallback<NEOrderSongDynamicToken> {
            override fun success(info: NEOrderSongDynamicToken?) {
                copyrightedMedia.initialize(
                    context,
                    appKey,
                    info!!.accessToken,
                    account,
                    mapOf("serverUrl" to serverUrl)
                )
            }

            override fun error(code: Int, msg: String?) {
            }
        })
    }

    fun addHeader(key: String, value: String) {
        orderSongRepository.addHeader(key, value)
    }

    fun setSongScene(songScene: SongScene) {
        copyrightedMedia.setSongScene(songScene)
    }

    private fun onTokenWillExpired() {
        getSongDynamicTokenUntilSuccess(null)
    }

    fun getSongDynamicTokenUntilSuccess(callback: NetRequestCallback<NEOrderSongDynamicToken>?) {
        val runnable: Runnable = object : Runnable {
            var count = 0
            override fun run() {
                getSongToken(
                    object : NetRequestCallback<NEOrderSongDynamicToken> {
                        override fun success(token: NEOrderSongDynamicToken?) {
                            if (token != null) {
                                copyrightedMedia.renewToken(token.accessToken)

                                // 设置token延时任务
                                val tokenWillExpiredTask = Runnable {
                                    onTokenWillExpired()
                                }
                                var delaySeconds = (token.expiresIn - aheadTimeRefreshToken) * 1000
                                if (delaySeconds < 0) delaySeconds = 0
                                TimerTaskUtil.addTask(
                                    tokenWillExpiredTaskId,
                                    tokenWillExpiredTask,
                                    delaySeconds
                                )
                                callback?.success(token)
                            }
                        }

                        override fun error(code: Int, msg: String?) {
                            count++
                            if (count < refreshTokenRetryTimes) {
                                retryTask()
                            } else {
                                callback?.error(code, msg)
                            }
                        }
                    }
                )
            }

            fun retryTask() {
                TimerTaskUtil.addTask(
                    refreshTokenTaskId,
                    this,
                    (2.0.pow(count.toDouble()) * 1000).toLong()
                )
            }
        }
        TimerTaskUtil.addTask(refreshTokenTaskId, runnable, 0)
    }

    private fun getSongToken(callback: NetRequestCallback<NEOrderSongDynamicToken>) {
        coroutineScope?.launch {
            Request.request(
                {
                    orderSongRepository.getSongToken(appKey)
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun orderSong(
        songModel: OrderSongModel,
        callback: NetRequestCallback<NEOrderSong>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    val singers = songModel.singers
                    val singer = StringBuilder()
                    if (singers.isNotEmpty()) {
                        singers.forEachIndexed { index, neCopyrightedSinger ->
                            if (index != singers.size - 1) {
                                singer.append(neCopyrightedSinger.singerName).append("/")
                            } else {
                                singer.append(neCopyrightedSinger.singerName)
                            }
                        }
                    }

                    roomUuid?.let {
                        orderSongRepository.orderSong(
                            it,
                            songModel.songId,
                            songModel.songName,
                            songModel.songCover,
                            songModel.songTime,
                            songModel.channel,
                            singer.toString()
                        )
                    }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun switchSong(
        currentOrderId: Long,
        attachment: String?,
        callback: NetRequestCallback<Boolean>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    roomUuid?.let { orderSongRepository.switchSong(it, currentOrderId, attachment) }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun getOrderedSongs(
        callback: NetRequestCallback<List<NEOrderSong>>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    roomUuid?.let { orderSongRepository.getOrderSongs(it) }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun deleteSong(
        orderId: Long,
        callback: NetRequestCallback<Boolean>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    roomUuid?.let { orderSongRepository.cancelOrderSong(it, orderId) }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun reportReady(
        orderId: Long,
        callback: NetRequestCallback<Boolean>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    roomUuid?.let { orderSongRepository.reportReady(it, orderId) }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun queryPlayingSongInfo(
        callback: NetRequestCallback<OrderSong>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    roomUuid?.let { orderSongRepository.queryPlayingSongInfo(it) }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun reportResume(
        orderId: Long,
        callback: NetRequestCallback<Boolean>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    roomUuid?.let { orderSongRepository.reportResume(appKey, it, orderId) }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    fun reportPause(
        orderId: Long,
        callback: NetRequestCallback<Boolean>
    ) {
        coroutineScope?.launch {
            Request.request(
                {
                    roomUuid?.let { orderSongRepository.reportPause(appKey, it, orderId) }
                },
                success = {
                    callback.success(it)
                },
                error = { code: Int, msg: String ->
                    callback.error(code, msg)
                }
            )
        }
    }

    private val listeners: ArrayList<NEOrderSongListener> = ArrayList()

    fun setRoomUuid(roomUuid: String) {
        this.roomUuid = roomUuid
    }

    fun addListener(listener: NEOrderSongListener) {
        listeners.add(listener)
        roomUuid?.let {
            val roomContext =
                NERoomKit.instance.getService(NERoomService::class.java).getRoomContext(roomUuid!!)
            if (roomContext != null) {
                roomContext.addRoomListener(roomListener)
                hasAddRoomListen = true
            } else {
                ALog.e(TAG, "addListener roomContext==null")
            }
        }
    }

    fun removeListener(listener: NEOrderSongListener) {
        listeners.remove(listener)
        if (listeners.isEmpty() && hasAddRoomListen) {
            roomUuid?.let {
                val roomContext =
                    NERoomKit.instance.getService(NERoomService::class.java)
                        .getRoomContext(roomUuid!!)
                if (roomContext != null) {
                    roomContext.removeRoomListener(roomListener)
                    hasAddRoomListen = false
                } else {
                    ALog.e(TAG, "removeListener roomContext==null")
                }
            }
        }
    }
}

/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.listentogetherkit.impl.service

import android.net.NetworkInfo
import android.net.Uri
import android.text.TextUtils
import com.google.gson.JsonObject
import com.netease.yunxin.kit.common.utils.NetworkUtils
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherRoomListener
import com.netease.yunxin.kit.listentogetherkit.api.NEVoiceRoomAudioOutputDevice
import com.netease.yunxin.kit.listentogetherkit.api.NEVoiceRoomEndReason
import com.netease.yunxin.kit.listentogetherkit.api.NEVoiceRoomErrorCode
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomChatTextMessage
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioEffectOption
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioMixingOption
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomMember
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomRtcAudioStreamType
import com.netease.yunxin.kit.listentogetherkit.impl.model.ListenTogetherRoomGiftModel
import com.netease.yunxin.kit.listentogetherkit.impl.model.ListenTogetherRoomMember
import com.netease.yunxin.kit.listentogetherkit.impl.utils.GsonUtils
import com.netease.yunxin.kit.listentogetherkit.impl.utils.ListenTogetherLog
import com.netease.yunxin.kit.listentogetherkit.impl.utils.VoiceRoomUtils
import com.netease.yunxin.kit.roomkit.api.NECallback
import com.netease.yunxin.kit.roomkit.api.NECallback2
import com.netease.yunxin.kit.roomkit.api.NEErrorCode
import com.netease.yunxin.kit.roomkit.api.NERoomChatMessage
import com.netease.yunxin.kit.roomkit.api.NERoomChatTextMessage
import com.netease.yunxin.kit.roomkit.api.NERoomContext
import com.netease.yunxin.kit.roomkit.api.NERoomEndReason
import com.netease.yunxin.kit.roomkit.api.NERoomKit
import com.netease.yunxin.kit.roomkit.api.NERoomListener
import com.netease.yunxin.kit.roomkit.api.NERoomLiveState
import com.netease.yunxin.kit.roomkit.api.NERoomMember
import com.netease.yunxin.kit.roomkit.api.NERoomRole
import com.netease.yunxin.kit.roomkit.api.NEUnitCallback
import com.netease.yunxin.kit.roomkit.api.NEValueCallback
import com.netease.yunxin.kit.roomkit.api.model.NEAudioOutputDevice
import com.netease.yunxin.kit.roomkit.api.model.NEMemberVolumeInfo
import com.netease.yunxin.kit.roomkit.api.model.NERoomCreateAudioEffectOption
import com.netease.yunxin.kit.roomkit.api.model.NERoomCreateAudioMixingOption
import com.netease.yunxin.kit.roomkit.api.model.NERoomRtcAudioProfile
import com.netease.yunxin.kit.roomkit.api.model.NERoomRtcAudioScenario
import com.netease.yunxin.kit.roomkit.api.model.NERoomRtcAudioStreamType
import com.netease.yunxin.kit.roomkit.api.model.NERoomRtcChannelProfile
import com.netease.yunxin.kit.roomkit.api.model.NERoomRtcClientRole
import com.netease.yunxin.kit.roomkit.api.service.NEJoinRoomOptions
import com.netease.yunxin.kit.roomkit.api.service.NEJoinRoomParams
import com.netease.yunxin.kit.roomkit.api.service.NERoomService
import com.netease.yunxin.kit.roomkit.api.service.NESeatEventListener
import com.netease.yunxin.kit.roomkit.api.service.NESeatInfo
import com.netease.yunxin.kit.roomkit.api.service.NESeatItem
import com.netease.yunxin.kit.roomkit.api.service.NESeatItemStatus
import com.netease.yunxin.kit.roomkit.api.service.NESeatRequestItem
import com.netease.yunxin.kit.roomkit.impl.model.RoomCustomMessages
import java.util.Locale

internal class ListenTogetherService {

    private var currentRoomContext: NERoomContext? = null
    private val listeners = ArrayList<NEListenTogetherRoomListener>()
    private var roomListener: NERoomListener? = null
    private var seatListener: NESeatEventListener? = null
    private var isEarBackEnable: Boolean = false
    private var currentSeatItems: List<NESeatItem>? = null
    private var recordingSignalVolume: Int = 100
    private var audioMixingVolume: Int = 100
    private var effectVolume: Int = 100
    private val networkStateListener: NetworkUtils.NetworkStateListener =
        object : NetworkUtils.NetworkStateListener {
            private var isFirst = true
            override fun onAvailable(networkInfo: NetworkInfo?) {
                if (!isFirst) {
                    ListenTogetherLog.d(TAG, "onNetworkAvailable")
                    getSeatInfo(object : NECallback2<NESeatInfo>() {
                        override fun onSuccess(data: NESeatInfo?) {
                            super.onSuccess(data)
                            data?.let {
                                handleSeatListItemChanged(data.seatItems)
                                listeners.forEach {
                                    it.onSeatListChanged(
                                        data.seatItems.map { neSeatItem ->
                                            VoiceRoomUtils.voiceRoomSeatItem2NEVoiceRoomSeatItem(
                                                neSeatItem
                                            )
                                        }
                                    )
                                }
                            }
                        }
                    })
                }
                isFirst = false
            }
            override fun onLost(networkInfo: NetworkInfo?) {
                ListenTogetherLog.e(TAG, "onNetworkUnavailable")
                isFirst = false
            }
        }

    companion object {
        private const val TAG = "VoiceRoomService"
        private const val ERROR_MSG_ROOM_NOT_EXISTS = "Room not exists"
        private const val ERROR_MSG_MEMBER_NOT_EXISTS = "Member not exists"
        private const val ERROR_MSG_MEMBER_AUDIO_BANNED = "Member audio banned"
        const val TYPE_GIFT = 1001 // 礼物
    }

    fun getRoomUuid(): String? {
        return currentRoomContext?.roomUuid
    }

    fun getLocalMember(): NEListenTogetherRoomMember? {
        return currentRoomContext?.let { mapMember(it.localMember) }
    }

    fun getRemoteMembers(): List<NEListenTogetherRoomMember> {
        return currentRoomContext?.remoteMembers?.map {
            mapMember(it)
        } ?: emptyList()
    }

    fun getMember(account: String) = currentRoomContext?.getMember(account)?.let {
        mapMember(it)
    }

    fun isEarBackEnable() = isEarBackEnable

    private fun setAudioProfile() {
        currentRoomContext?.rtcController?.setAudioProfile(
            NERoomRtcAudioProfile.HIGH_QUALITY_STEREO,
            NERoomRtcAudioScenario.MUSIC
        )
        currentRoomContext?.rtcController?.setChannelProfile(
            NERoomRtcChannelProfile.liveBroadcasting
        )
    }

    fun joinRoom(
        roomUuid: String,
        role: String,
        userName: String,
        avatar: String?,
        callback: NECallback2<Unit>
    ) {
        NERoomKit.getInstance().getService(NERoomService::class.java).joinRoom(
            NEJoinRoomParams(roomUuid = roomUuid, userName = userName, avatar = avatar, role = role),
            NEJoinRoomOptions(),
            object : NECallback2<NERoomContext>() {
                override fun onSuccess(data: NERoomContext?) {
                    currentRoomContext = data!!
                    setAudioProfile()
                    addRoomListener()
                    addSeatListener()
                    NetworkUtils.registerNetworkStatusChangedListener(networkStateListener)
                    ListenTogetherLog.d(TAG, "joinRoom roomUuid = $roomUuid success")
                    currentRoomContext?.rtcController?.setClientRole(NERoomRtcClientRole.AUDIENCE)

                    joinRtcChannel(object : NECallback2<Unit>() {
                        override fun onSuccess(data: Unit?) {
                            ListenTogetherLog.d(TAG, "joinRtcChannel roomUuid = $roomUuid success")
                            joinChatroomChannel(object : NECallback2<Unit>() {
                                override fun onSuccess(data: Unit?) {
                                    ListenTogetherLog.d(
                                        TAG,
                                        "joinChatroomChannel roomUuid = $roomUuid success"
                                    )
                                    callback.onSuccess(data)
                                }

                                override fun onError(code: Int, message: String?) {
                                    ListenTogetherLog.e(
                                        TAG,
                                        "joinChatroomChannel roomUuid = $roomUuid error code = $code message = $message"
                                    )

                                    leaveRtcChannel(object : NECallback2<Unit>() {
                                        override fun onSuccess(data: Unit?) {
                                            ListenTogetherLog.d(
                                                TAG,
                                                "leaveRtcChannel roomUuid = $roomUuid success"
                                            )
                                        }

                                        override fun onError(code: Int, message: String?) {
                                            ListenTogetherLog.e(
                                                TAG,
                                                "leaveRtcChannel failed roomUuid = $roomUuid error code = $code message = $message"
                                            )
                                        }
                                    })
                                    callback.onError(code, message)
                                }
                            })
                        }

                        override fun onError(code: Int, message: String?) {
                            ListenTogetherLog.e(
                                TAG,
                                "joinRtcChannel failed roomUuid = $roomUuid error code = $code message = $message"
                            )
                            callback.onError(code, message)
                        }
                    })
                }

                override fun onError(code: Int, message: String?) {
                    ListenTogetherLog.e(
                        TAG,
                        "joinRoom roomUuid = $roomUuid error code = $code message = $message"
                    )
                    callback.onResult(code, message, null)
                }
            }
        )
    }

    fun joinRtcChannel(callback: NECallback2<Unit>) {
        currentRoomContext?.rtcController?.joinRtcChannel(object : NECallback2<Unit>() {
            override fun onSuccess(data: Unit?) {
                ListenTogetherLog.d(TAG, "joinRtcChannel success")
                callback.onResult(NEErrorCode.SUCCESS, "", null)
            }

            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(TAG, "joinRtcChannel error code = $code message = $message")
                callback.onError(code, message)
            }
        })
    }

    fun leaveRtcChannel(callback: NECallback2<Unit>) {
        currentRoomContext?.rtcController?.leaveRtcChannel(object : NECallback2<Unit>() {
            override fun onSuccess(data: Unit?) {
                ListenTogetherLog.d(TAG, "leaveRtcChannel success")
                callback.onResult(NEErrorCode.SUCCESS, "", null)
            }

            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(TAG, "leaveRtcChannel error code = $code message = $message")
                callback.onError(code, message)
            }
        })
    }

    fun joinChatroomChannel(callback: NECallback2<Unit>) {
        currentRoomContext?.chatController?.joinChatroom(object : NECallback2<Unit>() {
            override fun onSuccess(data: Unit?) {
                ListenTogetherLog.d(TAG, "joinChatroomChannel success")
                callback.onResult(NEErrorCode.SUCCESS, "", null)
            }

            override fun onError(code: Int, message: String?) {
                ListenTogetherLog.e(TAG, "joinChatroomChannel error code = $code message = $message")
                callback.onError(code, message)
            }
        })
    }

    /**
     * 移除监听 --- 离开房间，结束房间
     */
    private fun removeListener() {
        ListenTogetherLog.d(TAG, "removeRoomListener,roomListener:$roomListener")
        ListenTogetherLog.d(TAG, "removeSeatListener,seatListener:$seatListener")
        roomListener?.apply { currentRoomContext?.removeRoomListener(roomListener!!) }
        seatListener?.apply {
            currentRoomContext?.seatController?.removeSeatListener(seatListener!!)
        }
        NetworkUtils.unregisterNetworkStatusChangedListener(networkStateListener)
    }

    fun leaveRoom(callback: NECallback2<Unit>) {
        currentRoomContext?.leaveRoom(object : NECallback2<Unit>() {
            override fun onSuccess(data: Unit?) {
                callback.onSuccess(data)
            }

            override fun onError(code: Int, message: String?) {
                callback.onError(code, message)
            }
        })
        removeListener()
        listeners.clear()
        isEarBackEnable = false
        currentRoomContext = null
        currentSeatItems = null
    }

    fun endRoom(callback: NECallback<Unit>) {
        currentRoomContext?.endRoom(false, callback)
        removeListener()
        listeners.clear()
        isEarBackEnable = false
        currentRoomContext = null
        currentSeatItems = null
    }

    fun sendTextMessage(content: String, callback: NECallback2<Unit>) {
        currentRoomContext?.chatController?.sendBroadcastTextMessage(content, callback)
            ?: callback.onError(
                NEErrorCode.FAILURE,
                ERROR_MSG_ROOM_NOT_EXISTS
            )
    }

    fun kickMemberOut(userUuid: String, callback: NECallback2<Unit>) {
        currentRoomContext?.kickMemberOut(userUuid, callback)
            ?: callback.onError(
                NEErrorCode.FAILURE,
                ERROR_MSG_ROOM_NOT_EXISTS
            )
    }

    fun muteMyAudio(callback: NECallback2<Unit>) {
        val context = currentRoomContext
        if (context == null) {
            callback.onError(NEErrorCode.FAILURE, ERROR_MSG_ROOM_NOT_EXISTS)
            return
        }
        context.updateMemberProperty(
            context.localMember.uuid,
            MemberPropertyConstants.MUTE_VOICE_KEY,
            MemberPropertyConstants.MUTE_VOICE_VALUE_OFF,
            callback
        )
    }

    fun unmuteMyAudio(callback: NECallback2<Unit>) {
        val context = currentRoomContext
        if (context == null) {
            callback.onError(NEErrorCode.FAILURE, ERROR_MSG_ROOM_NOT_EXISTS)
            return
        }
        if (mapMember(context.localMember).isAudioBanned) {
            callback.onError(NEErrorCode.FAILURE, ERROR_MSG_MEMBER_AUDIO_BANNED)
            return
        }

        val uuid = context.localMember.uuid
        fun realUnmute() {
            context.updateMemberProperty(
                uuid,
                MemberPropertyConstants.MUTE_VOICE_KEY,
                MemberPropertyConstants.MUTE_VOICE_VALUE_ON,
                callback
            )
        }

        if (context.localMember.isAudioOn.not()) {
            context.rtcController.unmuteMyAudio(object : NEUnitCallback() {
                override fun onError(code: Int, message: String?) {
                    callback.onError(code, message)
                }
                override fun onSuccess() = realUnmute()
            })
        } else {
            realUnmute()
        }
    }

    fun banRemoteAudio(userId: String, callback: NECallback2<Unit>) {
        val context = currentRoomContext
        if (context == null) {
            callback.onError(NEErrorCode.FAILURE, ERROR_MSG_ROOM_NOT_EXISTS)
            return
        }
        val member = context.getMember(userId)
        if (member == null) {
            callback.onError(NEErrorCode.FAILURE, ERROR_MSG_MEMBER_NOT_EXISTS)
            return
        }
        context.updateMemberProperty(
            userId,
            MemberPropertyConstants.CAN_OPEN_MIC_KEY,
            MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO,
            callback
        )
    }

    fun unbanRemoteAudio(userId: String, callback: NECallback2<Unit>) {
        val context = currentRoomContext
        if (context == null) {
            callback.onError(NEErrorCode.FAILURE, ERROR_MSG_ROOM_NOT_EXISTS)
            return
        }
        val member = context.getMember(userId)
        if (member == null) {
            callback.onError(NEErrorCode.FAILURE, ERROR_MSG_MEMBER_NOT_EXISTS)
            return
        }
        if (member.properties[MemberPropertyConstants.CAN_OPEN_MIC_KEY]
            == MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO
        ) {
            context.updateMemberProperty(
                userId,
                MemberPropertyConstants.CAN_OPEN_MIC_KEY,
                MemberPropertyConstants.CAN_OPEN_MIC_VALUE_YES,
                callback
            )
        } else {
            callback.onSuccess(Unit)
        }
    }

    fun enableEarBack(volume: Int): Int {
        val result = currentRoomContext?.rtcController?.enableEarBack(volume) ?: NEErrorCode.FAILURE
        if (result == 0) {
            isEarBackEnable = true
        }
        return result
    }

    fun adjustRecordingSignalVolume(volume: Int): Int {
        val result = currentRoomContext?.rtcController?.adjustRecordingSignalVolume(volume)
            ?: NEErrorCode.FAILURE
        if (result == NEErrorCode.SUCCESS) {
            recordingSignalVolume = volume
        }
        return result
    }

    fun getRecordingSignalVolume(): Int {
        ListenTogetherLog.logApi("getRecordingSignalVolume")
        return recordingSignalVolume
    }

    fun adjustPlayMusicVolume(effectId: Int, volume: Int): Int {
        return currentRoomContext?.rtcController?.setEffectPlaybackVolume(effectId, volume)
            ?: NEErrorCode.FAILURE
    }

    fun disableEarBack(): Int {
        val result = currentRoomContext?.rtcController?.disableEarBack() ?: NEErrorCode.FAILURE
        if (result == 0) {
            isEarBackEnable = false
        }
        return result
    }

    fun getSeatInfo(callback: NECallback2<NESeatInfo>) {
        currentRoomContext?.seatController?.getSeatInfo(callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun getSeatRequestList(callback: NECallback2<List<NESeatRequestItem>>) {
        currentRoomContext?.seatController?.getSeatRequestList(callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun sendSeatInvitation(seatIndex: Int, user: String, callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.sendSeatInvitation(seatIndex, user, callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun submitSeatRequest(seatIndex: Int, exclusive: Boolean, callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.submitSeatRequest(seatIndex, exclusive, callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun cancelSeatRequest(callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.cancelSeatRequest(callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun leaveSeat(callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.leaveSeat(callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun approveSeatRequest(user: String, callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.approveSeatRequest(user, callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun rejectSeatRequest(user: String, callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.rejectSeatRequest(user, callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun kickSeat(user: String, callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.kickSeat(user, callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun openSeats(seatIndices: List<Int>, callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.openSeats(seatIndices, callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun closeSeats(seatIndices: List<Int>, callback: NECallback2<Unit>) {
        currentRoomContext?.seatController?.closeSeats(seatIndices, callback) ?: callback.onError(
            NEErrorCode.FAILURE,
            "roomContext is null"
        )
    }

    fun startAudioMixing(option: NEListenTogetherRoomCreateAudioMixingOption): Int {
        return currentRoomContext?.rtcController?.startAudioMixing(
            NERoomCreateAudioMixingOption(
                option.path,
                option.loopCount,
                option.sendEnabled,
                option.sendVolume,
                option.playbackEnabled,
                option.playbackVolume,
                0,
                NERoomRtcAudioStreamType.NERtcAudioStreamTypeMain
            )
        ) ?: NEErrorCode.FAILURE
    }

    fun pauseAudioMixing(): Int {
        return currentRoomContext?.rtcController?.pauseAudioMixing() ?: NEErrorCode.FAILURE
    }

    fun resumeAudioMixing(): Int {
        return currentRoomContext?.rtcController?.resumeAudioMixing() ?: NEErrorCode.FAILURE
    }

    fun stopAudioMixing(): Int {
        return currentRoomContext?.rtcController?.stopAudioMixing() ?: NEErrorCode.FAILURE
    }

    fun setAudioMixingVolume(volume: Int): Int {
        val sendResult = currentRoomContext?.rtcController?.setAudioMixingSendVolume(volume) ?: NEErrorCode.FAILURE
        val playbackResult = currentRoomContext?.rtcController?.setAudioMixingPlaybackVolume(volume) ?: NEErrorCode.FAILURE
        if (sendResult == NEErrorCode.SUCCESS && playbackResult == NEErrorCode.SUCCESS) {
            audioMixingVolume = volume
            return NEErrorCode.SUCCESS
        }
        return NEErrorCode.FAILURE
    }

    fun getAudioMixingVolume(): Int {
        return audioMixingVolume
    }

    fun playEffect(effectId: Int, option: NEListenTogetherRoomCreateAudioEffectOption): Int {
        return currentRoomContext?.rtcController?.playEffect(
            effectId,
            NERoomCreateAudioEffectOption(
                option.path,
                option.loopCount,
                option.sendEnabled,
                option.sendVolume,
                option.playbackEnabled,
                option.playbackVolume,
                option.startTimestamp,
                option.progressInterval,
                if (option.sendWithAudioType == NEListenTogetherRoomRtcAudioStreamType.NERtcAudioStreamTypeMain)NERoomRtcAudioStreamType.NERtcAudioStreamTypeMain else NERoomRtcAudioStreamType.NERtcAudioStreamTypeSub
            )
        ) ?: NEErrorCode.FAILURE
    }

    fun setEffectVolume(effectId: Int, volume: Int): Int {
        val sendResult = currentRoomContext?.rtcController?.setEffectSendVolume(effectId, volume)
        val playbackResult = currentRoomContext?.rtcController?.setEffectPlaybackVolume(
            effectId,
            volume
        ) ?: NEErrorCode.FAILURE
        if (sendResult == NEErrorCode.SUCCESS && playbackResult == NEErrorCode.SUCCESS) {
            effectVolume = volume
            return NEErrorCode.SUCCESS
        }
        return NEErrorCode.FAILURE
    }

    fun getEffectVolume(): Int {
        return effectVolume
    }

    fun stopAllEffect(): Int {
        return currentRoomContext?.rtcController?.stopAllEffects() ?: NEErrorCode.FAILURE
    }
    fun stopEffect(effectId: Int): Int {
        return currentRoomContext?.rtcController?.stopEffect(effectId) ?: NEErrorCode.FAILURE
    }

    fun removeListener(listener: NEListenTogetherRoomListener) {
        listeners.remove(listener)
        ListenTogetherLog.d(TAG, "removeListener,listeners.size:" + listeners.size)
    }

    fun addListener(listener: NEListenTogetherRoomListener) {
        listeners.add(listener)
        ListenTogetherLog.d(TAG, "addListener,listeners.size:" + listeners.size)
    }

    private fun mapMember(member: NERoomMember): NEListenTogetherRoomMember {
        return ListenTogetherRoomMember(member)
    }

    private fun addRoomListener() {
        roomListener = object : RoomListenerWrapper() {

            override fun onRtcChannelError(code: Int) {
                ListenTogetherLog.e(TAG, "onRtcChannelError code = $code")
                listeners.forEach {
                    it.onRtcChannelError(code)
                }
            }

            override fun onMemberPropertiesChanged(
                member: NERoomMember,
                properties: Map<String, String>
            ) {
                val uuid = getLocalMember()?.account
                if (properties.containsKey(MemberPropertyConstants.MUTE_VOICE_KEY)) {
                    val voiceValue = properties[MemberPropertyConstants.MUTE_VOICE_KEY]
                    if (voiceValue == MemberPropertyConstants.MUTE_VOICE_VALUE_ON || voiceValue == MemberPropertyConstants.MUTE_VOICE_VALUE_OFF) {
                        val mute = voiceValue != MemberPropertyConstants.MUTE_VOICE_VALUE_ON
                        if (member.uuid == uuid) {
                            syncLocalAudioState(mute)
                        }
                        val voiceRoomMember = mapMember(member)
                        ListenTogetherLog.d(
                            TAG,
                            "onMemberAudioMuteChanged voiceRoomMember:$voiceRoomMember,mute:$mute,operateBy:" + getLocalMember()
                        )
                        listeners.forEach {
                            it.onMemberAudioMuteChanged(voiceRoomMember, mute, getLocalMember())
                        }
                    }
                }
            }

            override fun onMemberPropertiesDeleted(
                member: NERoomMember,
                properties: Map<String, String>
            ) {
            }

            override fun onMemberJoinRoom(members: List<NERoomMember>) {
                val memberList = members.map {
                    mapMember(it)
                }
                listeners.forEach {
                    it.onMemberJoinRoom(memberList)
                }
            }

            override fun onMemberLeaveRoom(members: List<NERoomMember>) {
                val memberList = members.map {
                    mapMember(it)
                }
                listeners.forEach {
                    it.onMemberLeaveRoom(memberList)
                }
            }

            override fun onMemberJoinChatroom(members: List<NERoomMember>) {
                val memberList = members.map {
                    mapMember(it)
                }
                listeners.forEach {
                    it.onMemberJoinChatroom(memberList)
                }
            }

            override fun onMemberLeaveChatroom(members: List<NERoomMember>) {
                val memberList = members.map {
                    mapMember(it)
                }
                listeners.forEach {
                    it.onMemberLeaveChatroom(memberList)
                }
            }

            override fun onRoomEnded(reason: NERoomEndReason) {
                val endReason =
                    NEVoiceRoomEndReason.fromValue(reason.name.uppercase(Locale.getDefault()))
                listeners.forEach {
                    it.onRoomEnded(endReason)
                }
            }

            override fun onAudioEffectFinished(effectId: Int) {
                listeners.forEach {
                    it.onAudioEffectFinished(effectId)
                }
            }

            override fun onAudioEffectTimestampUpdate(effectId: Long, timeStampMS: Long) {
                listeners.forEach {
                    it.onAudioEffectTimestampUpdate(effectId, timeStampMS)
                }
            }

            override fun onRtcAudioVolumeIndication(
                volumes: List<NEMemberVolumeInfo>,
                totalVolume: Int
            ) {
                listeners.forEach {
                    it.onRtcAudioVolumeIndication(volumes, totalVolume)
                }
            }

            override fun onRtcAudioOutputDeviceChanged(device: NEAudioOutputDevice) {
                val outputDevice =
                    NEVoiceRoomAudioOutputDevice.fromValue(
                        device.name.uppercase(Locale.getDefault())
                    )
                ListenTogetherLog.d(TAG, "onRtcAudioOutputDeviceChanged,outputDevice:$outputDevice")
                listeners.forEach {
                    it.onAudioOutputDeviceChanged(outputDevice)
                }
            }

            override fun onMemberAudioMuteChanged(
                member: NERoomMember,
                mute: Boolean,
                operateBy: NERoomMember?
            ) {
            }

            override fun onReceiveChatroomMessages(messages: List<NERoomChatMessage>) {
                messages.forEach {
                    if (it is NERoomChatTextMessage) {
                        val textMessage = NEListenTogetherRoomChatTextMessage(
                            it.fromUserUuid,
                            it.fromNick,
                            it.toUserUuidList,
                            it.time,
                            it.text
                        )
                        listeners.forEach { listener ->
                            listener.onReceiveTextMessage(textMessage)
                        }
                    } else if (it is RoomCustomMessages) {
                        when (getType(it.attachStr)) {
                            TYPE_GIFT -> {
                                val result2 = GsonUtils.fromJson(
                                    it.attachStr,
                                    ListenTogetherRoomGiftModel::class.java
                                )
                                listeners.forEach { listener ->
                                    ListenTogetherLog.i(
                                        TAG,
                                        "onReceiveGift customAttachment:${it.attachStr}"
                                    )
                                    listener.onReceiveGift(
                                        VoiceRoomUtils.voiceRoomGiftModel2NEVoiceRoomGiftModel(
                                            result2
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }

            override fun onChatroomMessageAttachmentProgress(
                messageUuid: String,
                transferred: Long,
                total: Long
            ) {
            }

            override fun onAudioMixingStateChanged(reason: Int) {
                ListenTogetherLog.d(TAG, "onAudioMixingStateChanged,reason:$reason")
                listeners.forEach {
                    it.onAudioMixingStateChanged(reason)
                }
            }
        }
        currentRoomContext?.addRoomListener(roomListener!!)
        ListenTogetherLog.d(TAG, "addRoomListener,roomListener:$roomListener")
    }

    private fun addSeatListener() {
        seatListener = object : NESeatEventListener() {
            override fun onSeatInvitationReceived(seatIndex: Int, user: String, operateBy: String) {
                ListenTogetherLog.d(
                    TAG,
                    "onSeatInvitationReceived seatIndex = $seatIndex user = $user operateBy = $operateBy"
                )
            }

            override fun onSeatInvitationCancelled(
                seatIndex: Int,
                user: String,
                operateBy: String
            ) {
                ListenTogetherLog.d(
                    TAG,
                    "onSeatInvitationCancelled seatIndex = $seatIndex user = $user operateBy = $operateBy"
                )
            }

            override fun onSeatInvitationRejected(seatIndex: Int, user: String) {
                ListenTogetherLog.d(TAG, "onSeatInvitationRejected seatIndex = $seatIndex user = $user")
            }

            override fun onSeatLeave(seatIndex: Int, user: String) {
                ListenTogetherLog.d(TAG, "onSeatLeave seatIndex = $seatIndex user = $user")

                listeners.forEach {
                    it.onSeatLeave(seatIndex, user)
                }
            }

            override fun onSeatListChanged(seatItems: List<NESeatItem>) {
                ListenTogetherLog.d(TAG, "onSeatListChanged seatItems = $seatItems")
                handleSeatListItemChanged(seatItems)
                listeners.forEach {
                    it.onSeatListChanged(
                        seatItems.map { neSeatItem ->
                            VoiceRoomUtils.voiceRoomSeatItem2NEVoiceRoomSeatItem(
                                neSeatItem
                            )
                        }
                    )
                }
            }

            override fun onSeatManagerAdded(managers: List<String>) {
                ListenTogetherLog.d(TAG, "onSeatManagerAdded managers = $managers")
            }

            override fun onSeatManagerRemoved(managers: List<String>) {
                ListenTogetherLog.d(TAG, "onSeatManagerRemoved managers = $managers")
            }
        }

        currentRoomContext?.seatController?.addSeatListener(seatListener!!)
        ListenTogetherLog.d(TAG, "addSeatListener,seatListener:$seatListener")
    }

    private fun handleSeatListItemChanged(seatItems: List<NESeatItem>) {
        val context = currentRoomContext ?: return
        val myUuid = context.localMember.uuid
        val old = currentSeatItems?.firstOrNull { it.user == myUuid }
        val now = seatItems.firstOrNull { it.user == myUuid }
        if ((old == null || old.status != NESeatItemStatus.TAKEN) && now != null && now.status == NESeatItemStatus.TAKEN) {
            unmuteMyAudio(EmptyCallback)
            context.rtcController.setClientRole(NERoomRtcClientRole.BROADCASTER)
        } else if (old != null && old.status == NESeatItemStatus.TAKEN && now == null) {
            muteMyAudio(EmptyCallback)
            context.rtcController.setClientRole(NERoomRtcClientRole.AUDIENCE)
            // 成员自己重置
            if (context.localMember.properties[MemberPropertyConstants.CAN_OPEN_MIC_KEY]
                == MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO
            ) {
                context.deleteMemberProperty(
                    myUuid,
                    MemberPropertyConstants.CAN_OPEN_MIC_KEY,
                    EmptyCallback
                )
            }
        }
        currentSeatItems = seatItems
    }

    private fun isCurrentOnSeat(seatItems: List<NESeatItem>): Boolean {
        var currentOnSeat = false
        seatItems.forEach {
            if (it.status == NESeatItemStatus.TAKEN &&
                TextUtils.equals(currentRoomContext?.localMember?.uuid, it.user)
            ) {
                currentOnSeat = true
            }
        }
        return currentOnSeat
    }

    private fun syncLocalAudioState(mute: Boolean) {
        currentRoomContext?.rtcController?.setRecordDeviceMute(mute)
    }

    private fun getType(json: String): Int? {
        val jsonObject: JsonObject = GsonUtils.fromJson(
            json,
            JsonObject::class.java
        )
        return jsonObject["type"]?.asInt
    }

    fun setPlayingPosition(effectId: Int, position: Long): Int {
        if (currentRoomContext == null) {
            return NEVoiceRoomErrorCode.FAILURE
        }
        return currentRoomContext!!.rtcController.setEffectPosition(
            effectId,
            position
        )
    }

    fun pauseEffect(effectId: Int): Int {
        if (currentRoomContext == null) {
            return NEVoiceRoomErrorCode.FAILURE
        }
        return currentRoomContext!!.rtcController.pauseEffect(effectId)
    }

    fun resumeEffect(effectId: Int): Int {
        if (currentRoomContext == null) {
            return NEVoiceRoomErrorCode.FAILURE
        }
        return currentRoomContext!!.rtcController.resumeEffect(effectId)
    }

    fun enableAudioVolumeIndication(enable: Boolean, interval: Int): Int {
        if (currentRoomContext == null) {
            return NEVoiceRoomErrorCode.FAILURE
        }
        return currentRoomContext!!.rtcController.enableAudioVolumeIndication(enable, interval)
    }
}

internal open class RoomListenerWrapper : NERoomListener {
    override fun onRoomPropertiesChanged(properties: Map<String, String>) {
    }

    override fun onRoomPropertiesDeleted(properties: Map<String, String>) {
    }

    override fun onMemberRoleChanged(
        member: NERoomMember,
        oldRole: NERoomRole,
        newRole: NERoomRole
    ) {
    }

    override fun onMemberNameChanged(member: NERoomMember, name: String) {
    }

    override fun onMemberPropertiesChanged(member: NERoomMember, properties: Map<String, String>) {
    }

    override fun onMemberPropertiesDeleted(member: NERoomMember, properties: Map<String, String>) {
    }

    override fun onMemberJoinRoom(members: List<NERoomMember>) {
    }

    override fun onMemberLeaveRoom(members: List<NERoomMember>) {
    }

    override fun onRoomEnded(reason: NERoomEndReason) {
    }

    override fun onRoomLockStateChanged(isLocked: Boolean) {
    }

    override fun onMemberJoinRtcChannel(members: List<NERoomMember>) {
    }

    override fun onMemberLeaveRtcChannel(members: List<NERoomMember>) {
    }

    override fun onRtcChannelError(code: Int) {
    }

    override fun onRtcRecvSEIMsg(uuid: String, seiMsg: String) {
    }

    override fun onRtcAudioVolumeIndication(volumes: List<NEMemberVolumeInfo>, totalVolume: Int) {
    }

    override fun onRtcAudioOutputDeviceChanged(device: NEAudioOutputDevice) {
    }

    override fun onMemberJoinChatroom(members: List<NERoomMember>) {
    }

    override fun onMemberLeaveChatroom(members: List<NERoomMember>) {
    }

    override fun onMemberAudioMuteChanged(
        member: NERoomMember,
        mute: Boolean,
        operateBy: NERoomMember?
    ) {
    }

    override fun onMemberVideoMuteChanged(
        member: NERoomMember,
        mute: Boolean,
        operateBy: NERoomMember?
    ) {
    }

    override fun onMemberScreenShareStateChanged(
        member: NERoomMember,
        isSharing: Boolean,
        operateBy: NERoomMember?
    ) {
    }

    override fun onReceiveChatroomMessages(messages: List<NERoomChatMessage>) {
    }

    override fun onAudioEffectFinished(effectId: Int) {
    }

    override fun onAudioEffectTimestampUpdate(effectId: Long, timeStampMS: Long) {
    }

    override fun onAudioMixingStateChanged(reason: Int) {
    }

    override fun onChatroomMessageAttachmentProgress(
        messageUuid: String,
        transferred: Long,
        total: Long
    ) {
    }

    override fun onMemberWhiteboardStateChanged(
        member: NERoomMember,
        isSharing: Boolean,
        operateBy: NERoomMember?
    ) {
    }

    override fun onWhiteboardShowFileChooser(
        types: Array<String>,
        callback: NEValueCallback<Array<Uri>?>
    ) {
    }

    override fun onWhiteboardError(code: Int, message: String) {
    }

    override fun onRoomLiveStateChanged(state: NERoomLiveState) {
    }

    override fun onRtcVirtualBackgroundSourceEnabled(enabled: Boolean, reason: Int) {
    }
}

internal object MemberPropertyConstants {
    // 根据该成员属性 变更mic声音采集
    const val MUTE_VOICE_KEY = "recordDevice"
    const val MUTE_VOICE_VALUE_ON = "on"
    const val MUTE_VOICE_VALUE_OFF = "off"

    // 成员是否可以开启麦克风。如果值为 [CAN_OPEN_MIC_VALUE_NO]，表示不能开启麦克风。
    const val CAN_OPEN_MIC_KEY = "canOpenMic"
    const val CAN_OPEN_MIC_VALUE_NO = "0"
    const val CAN_OPEN_MIC_VALUE_YES = "1"
}

internal object EmptyCallback : NECallback2<Unit>()

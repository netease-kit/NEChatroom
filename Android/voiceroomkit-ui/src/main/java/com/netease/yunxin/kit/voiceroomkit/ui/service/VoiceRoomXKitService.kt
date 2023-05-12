/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.ui.service

import android.content.Context
import androidx.annotation.Keep
import com.netease.yunxin.kit.corekit.XKitService
import com.netease.yunxin.kit.corekit.startup.Initializer
import com.netease.yunxin.kit.voiceroomkit.BuildConfig
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit
import com.netease.yunxin.kit.voiceroomkit.ui.utils.FloatPlayManager

@Keep
class VoiceRoomXKitService(override val appKey: String?) : XKitService {
    companion object {
        const val GET_CURRENT_ROOM_INFO_METHOD = "getCurrentRoomInfo"
        const val IS_SHOW_FLOAT_VIEW_METHOD = "isShowFloatView"
        const val STOP_FLOAT_PLAY_METHOD = "stopFloatPlay"
    }

    override val serviceName: String
        get() = "VoiceRoomKit"

    override val versionName: String
        get() = BuildConfig.versionName

    override fun onMethodCall(method: String, param: Map<String, Any?>?): Any? {
        if (GET_CURRENT_ROOM_INFO_METHOD == method) {
            return NEVoiceRoomKit.instance.getCurrentRoomInfo() != null
        } else if (IS_SHOW_FLOAT_VIEW_METHOD == method) {
            return FloatPlayManager.getInstance().isShowFloatView
        } else if (STOP_FLOAT_PLAY_METHOD == method) {
            return FloatPlayManager.getInstance().stopFloatPlay()
        }
        return null
    }

    override fun create(context: Context): VoiceRoomXKitService {
        // expose send team tip method
        @Suppress("UNCHECKED_CAST")
        return this
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}

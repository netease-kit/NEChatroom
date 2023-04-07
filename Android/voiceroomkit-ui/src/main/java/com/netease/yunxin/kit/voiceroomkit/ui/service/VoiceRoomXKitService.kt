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
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit

@Keep
class VoiceRoomXKitService(override val appKey: String?) : XKitService {
    companion object {
        const val GET_CURRENT_ROOM_INFO_METHOD = "getCurrentRoomInfo"
    }

    override val serviceName: String
        get() = "VoiceRoomXKitService"

    override val versionName: String
        get() = "1.0.0"

    override fun onMethodCall(method: String, param: Map<String, Any?>?): Any? {
        if (GET_CURRENT_ROOM_INFO_METHOD == method) {
            return NEVoiceRoomKit.instance.getCurrentRoomInfo() != null
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

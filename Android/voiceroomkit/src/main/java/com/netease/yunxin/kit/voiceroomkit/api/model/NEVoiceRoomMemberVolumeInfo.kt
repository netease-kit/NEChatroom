/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * 用户音量信息
 * @property userUuid 用户id
 * @property volume 音量大小 [0-100]
 */
interface NEVoiceRoomMemberVolumeInfo {
    val userUuid: String
    val volume: Int
}

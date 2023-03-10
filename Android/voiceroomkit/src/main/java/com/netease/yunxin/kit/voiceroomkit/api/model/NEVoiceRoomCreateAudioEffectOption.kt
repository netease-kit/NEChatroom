/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * @property path 音效路径
 * @property loopCount 播放次数
 * @property sendEnabled 是否发送声音到远端
 * @property sendVolume 发送音量
 * @property playbackEnabled 是否本地播放
 * @property playbackVolume 本地播放音量
 *
 */
data class NEVoiceRoomCreateAudioEffectOption(
    val path: String,
    val loopCount: Int,
    val sendEnabled: Boolean,
    val sendVolume: Int,
    val playbackEnabled: Boolean,
    val playbackVolume: Int
)

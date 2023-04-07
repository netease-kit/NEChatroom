/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

import java.util.Locale

enum class NEVoiceRoomLanguage(
    val locale: Locale
) {
    /**
     * 根据当前的系统语言自动选择对应的语言类型。
     * - 如果当前的系统语言为受支持的语言(中文、英文、日文)之一，则使用该语言；
     * - 如果当前的系统语言不受支持，则使用英文。
     */
    AUTOMATIC(Locale("*")),

    /**
     * 中文
     */
    CHINESE(Locale.SIMPLIFIED_CHINESE),

    /**
     * 英文
     */
    ENGLISH(Locale.US)
}

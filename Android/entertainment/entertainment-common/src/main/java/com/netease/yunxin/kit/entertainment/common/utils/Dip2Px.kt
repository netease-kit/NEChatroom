/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.entertainment.common.utils

import android.content.Context

fun Int.dip2Px(context: Context): Int {
    val density = context.applicationContext.resources.displayMetrics.density
    return (this * density + 0.5f).toInt()
}

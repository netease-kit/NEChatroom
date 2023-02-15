/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.ordersong.ui

interface NEOrderSongCallback<T> {
    /**
     * 成功回调
     * @param t 数据
     */
    fun onSuccess(t: T?)

    /**
     * 失败回调
     * @param code 错误码
     * @param msg 错误信息
     */
    fun onFailure(code: Int, msg: String?)
}

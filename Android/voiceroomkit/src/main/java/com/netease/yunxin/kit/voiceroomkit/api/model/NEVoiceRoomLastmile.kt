/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.voiceroomkit.api.model

/**
 * Last mile 网络探测配置。
 * @property probeUplink 是否探测上行网络。 不发流的用户，例如直播房间中的普通观众，无需进行上行网络探测。true: 探测。false: 不探测。
 * @property probeDownlink 是否探测下行网络。true: 探测。false: 不探测。
 * @property expectedUplinkBitrate 本端期望的最高发送码率。 单位为 bps，范围为 [100000, 5000000]。
 * @property expectedDownlinkBitrate 本端期望的最高接收码率。 单位为 bps，范围为 [100000, 5000000]。
 * @constructor
 */
data class NEVoiceRoomRtcLastmileProbeConfig(
    val probeUplink: Boolean = true,
    val probeDownlink: Boolean = true,
    val expectedUplinkBitrate: Int = 2000000,
    val expectedDownlinkBitrate: Int = 2000000
)

/**
 *
 * @property state Last-mile 质量探测结果的状态，有如下几种：
 * LASTMILE_PROBE_RESULT_COMPLETE(1)：表示本次 Last-mile 质量探测是完整的。
 * LASTMILE_PROBE_RESULT_INCOMPLETE_NO_BWE(2)：表示本次 Last-mile 质量探测未进行带宽预测，因此结果不完整。通常原因为测试资源暂时受限。
 * LASTMILE_PROBE_RESULT_UNAVAILABLE(3)：未进行 Last-mile 质量探测。通常原因为网络连接中断。
 * @property rtt 往返时延，单位为毫秒(ms)。
 * @property uplinkReport 上行网络质量报告。
 * @property downlinkReport 下行网络质量报告。
 * @constructor
 */
data class NEVoiceRoomRtcLastmileProbeResult(
    var state: Short = 0,
    var rtt: Int = 0,
    var uplinkReport: NEVoiceRoomRtcLastmileProbeOneWayResult = NEVoiceRoomRtcLastmileProbeOneWayResult(),
    var downlinkReport: NEVoiceRoomRtcLastmileProbeOneWayResult = NEVoiceRoomRtcLastmileProbeOneWayResult()
)

/**
 *
 * @property packetLossRate 丢包率。
 * @property jitter 网络抖动，单位为毫秒 (ms)。
 * @property availableBandwidth 可用网络带宽预估，单位为 Kbps。
 * @constructor
 */
data class NEVoiceRoomRtcLastmileProbeOneWayResult(
    val packetLossRate: Int = 0,
    val jitter: Int = 0,
    val availableBandwidth: Int = 0
)

/**
 * 网络质量
 */
object NEVoiceRoomRtcNetworkStatusType {
    /**
     * 质量未知
     */
    const val NETWORK_STATUS_UNKNOWN = 0

    /**
     * 质量极好
     */
    const val NETWORK_STATUS_EXCELLENT = 1

    /**
     * 用户主观感觉和极好差不多，但码率可能略低于极好
     */
    const val NETWORK_STATUS_GOOD = 2

    /**
     * 用户主观感受有瑕疵但不影响沟通
     */
    const val NETWORK_STATUS_POOR = 3

    /**
     * 勉强能沟通但不顺畅
     */
    const val NETWORK_STATUS_BAD = 4

    /**
     * 网络质量非常差，基本不能沟通
     */
    const val NETWORK_STATUS_VERY_BAD = 5

    /**
     * 完全无法沟通
     */
    const val NETWORK_STATUS_DOWN = 6
}

/**
 * 质量探测结果的状态。
 */
object NEVoiceRoomRtcLastmileProbeResultState {
    /**
     * 表示本次 Last-mile 质量探测是完整的。
     */
    const val LASTMILE_PROBE_RESULT_COMPLETE = 1

    /**
     * 表示本次 Last-mile 质量探测未进行带宽预测，因此结果不完整。通常原因为测试资源暂时受限。
     */
    const val LASTMILE_PROBE_RESULT_INCOMPLETE_NO_BWE = 2

    /**
     * 未进行 Last-mile 质量探测。通常原因为网络连接中断。
     */
    const val LASTMILE_PROBE_RESULT_UNAVAILABLE = 3
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 创建房间回调
/// @param info 房间信息，如果失败则为nil
/// @param error 错误信息，成功则为nil
// public typealias NECreateRoomCompletion = (NERoomDetail?, NERoomUserDetail?, Error?) -> Void

/// 创建房间回调
/// @param error 错误信息，成功则为nil
public typealias NEDestroyRoomCompletion = (Error?) -> Void

/// 加入房间回调
/// @param error 错误信息，成功则为nil
// public typealias NEEnterRoomCompletion = (NERoomDetail?, NERoomUserDetail?, Error?) -> Void

/// 离开房间回调
/// @param error 错误信息，成功则为nil
public typealias NELeaveRoomCompletion = (Error?) -> Void

/// 离开房间回调
/// @param error 错误信息，成功则为nil
// public typealias NEListRoomCompletion = (NEListRoomResult?, Error?) -> Void

/// 推拉流方式
@objc
public enum NELiveRoomPushType: Int {
  case CDN = 0
  case RTC = 1
}

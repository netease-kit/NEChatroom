// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// 通用回调
/// 0 代表成功, -1 代表失败, 其他为SDK错误码
public typealias NELoginSampleCallback<T: Any> = (Int, String?, T?) -> Void

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// 错误码
@objcMembers

public class NELoginSampleErrorCode: NSObject {
  /// 失败
  public static var failed: Int { -1 }
  /// 成功
  public static var success: Int { 0 }
}

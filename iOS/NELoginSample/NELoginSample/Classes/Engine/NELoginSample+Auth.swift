// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

public extension NELoginSample {
  func createAccount(_ userName: String?, sceneType: NemoSceneType, userUuid: String?, imToken: String?, callback: NELoginSampleCallback<NemoAccount>?) {
    guard NELoginSample.getInstance().isInitialized else {
      NELoginSampleLog.errorLog(kitTag, desc: "Failed to login. Uninitialized.")
      callback?(NELoginSampleErrorCode.failed, "Failed to login. Uninitialized.", nil)
      return
    }
    var params: [String: Any] = [
      "sceneType": sceneType.rawValue,
    ]
    if let userName = userName {
      params["userName"] = userName
    }
    if let userUuid = userUuid {
      params["userUuid"] = userUuid
    }
    if let imToken = imToken {
      params["imToken"] = imToken
    }
    NEAPI.LoginSample.createAccount.request(params, returnType: NemoAccount.self, success: { account in
      callback?(NELoginSampleErrorCode.success, nil, account)
    }, failed: { error in
      callback?(NELoginSampleErrorCode.failed, error.localizedDescription, nil)
    })
  }
}

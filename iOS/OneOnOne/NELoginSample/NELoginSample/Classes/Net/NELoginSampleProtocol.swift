// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import UIKit

/// 网络请求方法
enum NEHttpMethod: Int {
  case get, post, put, delete
  // 转字符串
  func toString() -> String {
    switch self {
    case .get: return "GET"
    case .post: return "POST"
    case .put: return "PUT"
    case .delete: return "DELETE"
    }
  }
}

/// 网络API协议
protocol NEAPIProtocol {
  var url: String { get }
  var description: String { get }
  var extra: String? { get }
  var method: NEHttpMethod { get }
}

extension NEAPIProtocol {
  func request(_ parameters: [String: Any]? = nil,
               headers: [String: String] = NE.headers,
               success: (([String: Any]?) -> Void)? = nil,
               failed: ((NSError) -> Void)? = nil) {
    NE.request(url,
               method: method.toString(),
               headers: headers,
               body: parameters) { data in
      success?(data)
    } failed: { error in
      failed?(error)
    }
  }

  func request<T>(_ parameters: [String: Any]? = nil,
                  headers: [String: String] = NE.headers,
                  returnType: T.Type,
                  success: ((T?) -> Void)? = nil,
                  failed: ((NSError) -> Void)? = nil) where T: Codable {
    NE.request(url,
               method: method.toString(),
               headers: headers,
               body: parameters,
               returnType: returnType) { model in
      success?(model)
    } failed: { error in
      failed?(error)
    }
  }
}

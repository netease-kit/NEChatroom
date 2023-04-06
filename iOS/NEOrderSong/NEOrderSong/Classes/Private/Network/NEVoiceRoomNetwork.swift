// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

class NetworkConfig {
  /// 自定义url
  var customUrl: String?
  var baseUrl: String {
    if let url = customUrl {
      return url
    } else if isDebug {
      return "https://roomkit-dev.netease.im"
    } else {
      return "https://roomkit.netease.im"
    }
  }

  var isDebug: Bool = false
  var deviceId: String {
    NERoomKit.shared().deviceId()
  }
}

let NE = NEOrderSongNetwork.shared

/// 网络请求类
internal class NEOrderSongNetwork {
  let tag: String = "NEOrderSongNetwork"
  static let shared = NEOrderSongNetwork()
  // 配置信息
  var config = NetworkConfig()

  lazy var headers: [String: String] = { [unowned self] in
    var header = [
      "clientType": "ios",
      "deviceId": config.deviceId,
    ]
    // 添加 appid
    if let appId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
      header["appId"] = appId
    }
    // 添加 appname
    if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
      header["appName"] = appName
    }
    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
       let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      let versionCode = "\(appVersion)\(buildVersion)".replacingOccurrences(of: ".", with: "")
      header["versionCode"] = versionCode
    }
    return header
  }()

  /// 请求头添加参数
  /// - Parameter dictionary: 参数
  func addHeader(_ dictionary: [String: String]) {
    for (key, value) in dictionary {
      headers[key] = value
    }
  }

  /// 请求头移除参数
  /// - Parameter key: 移除的请求头key
  func removeHeader(_ key: String) {
    headers.removeValue(forKey: key)
  }

  /// 请求session
  var session: URLSession {
    let sessionConfigure = URLSessionConfiguration.default
    sessionConfigure.httpAdditionalHeaders = ["Content-Type": "application/json;charset=utf-8"]
    sessionConfigure.timeoutIntervalForRequest = 10
    sessionConfigure.requestCachePolicy = .reloadIgnoringLocalCacheData
    return URLSession(configuration: sessionConfigure)
  }

  // MARK: - ------------------------- Request --------------------------

  /// 网络请求 返回字典类型
  /// - Parameters:
  ///   - url: 地址路径
  ///   - method: 请求方法
  ///   - headers: 请求头
  ///   - body: 请求体
  ///   - success: 成功回调
  ///   - failed: 失败回调
  func request(_ url: String,
               method: String = "POST",
               headers: [String: String],
               body: [String: Any]? = nil,
               success: @escaping ([String: Any]?) -> Void,
               failed: @escaping (NSError) -> Void) {
    NEOrderSongLog.networkLog(
      tag,
      desc: "HTTPRequest\nUrl: \(url).\nMethod: \(method)\nHeaders: \(headers)\nBody: \(body?.prettyJSON ?? "")"
    )
    guard let URL = URL(string: url) else {
      NEOrderSongLog.errorLog(tag, desc: "\(url). Bad Url.")
      failed(makeError(NEOrderSongErrorCode.failed, "Bad url"))
      return
    }

    var request = URLRequest(
      url: URL,
      cachePolicy: .useProtocolCachePolicy,
      timeoutInterval: 10
    )
    // headers
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }
    // body
    if let body = body,
       let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) {
      request.httpBody = jsonData
    }
    // method
    request.httpMethod = method

    let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
      guard let self = self else { return }
      if let error = error as NSError? {
        guard error.code == NSURLErrorNotConnectedToInternet else {
          failed(error)
          return
        }
        failed(makeError(NEOrderSongErrorCode.failed, "网络连接失败，请检查你的网络连接！"))
        return
      }

      guard let httpResp = response as? HTTPURLResponse else {
        failed(makeError(
          NEOrderSongErrorCode.failed,
          "Response is not http response: \(String(describing: response.self))"
        ))
        return
      }
      // code 码
      guard httpResp.statusCode == 200 else {
        NEOrderSongLog.errorLog(
          self.tag,
          desc: "HTTPRequest error:\nHttp error with status: \(httpResp.statusCode)"
        )
        failed(makeError(NEOrderSongErrorCode.failed,
                         "Http error with status: \(httpResp.statusCode)"))
        return
      }
      guard data != nil, data!.count > 0 else {
        failed(makeError(NEOrderSongErrorCode.failed))
        return
      }
      guard let response = try? JSONSerialization.jsonObject(
        with: data!,
        options: JSONSerialization.ReadingOptions(rawValue: 0)
      ) as? [String: Any] else {
        failed(makeError(NEOrderSongErrorCode.failed, "Cannot decode content data"))
        return
      }
      // 打印requestId
      if let requestId = response["requestId"] as? String {
        NEOrderSongLog.infoLog(self.tag, desc: "RequestId:\n\(requestId)")
      }
      guard let code = response["code"] as? Int else {
        failed(makeError(NEOrderSongErrorCode.failed, "Empty code in response body!"))
        return
      }
      guard code == 0 else {
        let message = response["msg"] as? String ?? "Empty message in response body!"
        NEOrderSongLog.errorLog(
          self.tag,
          desc: "HTTPRequest Error:\nCode:\(code)\nMsg:\(message)"
        )
        failed(makeError(code, message))
        return
      }
      // 数据
      guard let data = response["data"] else {
        success(nil)
        return
      }
      // 成功返回
      let dic = data as? [String: Any] ?? ["data": data]
      NEOrderSongLog.infoLog(self.tag, desc: "Response data:\n\(response.prettyJSON)")
      success(dic)
    }
    dataTask.resume()
  }

  /// 网络请求 返回泛型对象
  /// - Parameters:
  ///   - url: 地址路径
  ///   - method: 请求方法
  ///   - headers: 请求头
  ///   - body: 请求体
  ///   - returnType: 返回数据类型
  ///   - success: 成功回调
  ///   - failed: 失败回调
  func request<T>(_ url: String,
                  method: String = "POST",
                  headers: [String: String],
                  body: [String: Any]? = nil,
                  returnType: T.Type,
                  success: @escaping (T?) -> Void,
                  failed: @escaping (NSError) -> Void) where T: Codable {
    request(url, method: method, headers: headers, body: body) { dic in
      guard let dic = dic else {
        success(nil)
        return
      }
      success(NEOrderSongDecoder.decode(returnType, param: dic) ?? nil)
    } failed: { error in
      failed(error)
    }
  }
}

internal func makeError(_ code: Int, _ message: String? = nil) -> NSError {
  guard let msg = message else {
    return NSError(domain: NSCocoaErrorDomain, code: code, userInfo: nil)
  }
  return NSError(
    domain: NSCocoaErrorDomain,
    code: code,
    userInfo: [NSLocalizedDescriptionKey: msg]
  )
}

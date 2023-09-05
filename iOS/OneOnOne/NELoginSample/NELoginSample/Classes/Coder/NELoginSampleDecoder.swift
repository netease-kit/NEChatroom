// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// 解析器
struct NELoginSampleDecoder {
  static let tag: String = "NELoginSampleDecoder"

  // MARK: - ------------------------- 字典转模型 --------------------------

  static func decode<T>(_ type: T.Type,
                        param: [String: Any]) -> T? where T: Decodable {
    guard let jsonData = getJsonData(with: param) else {
      return nil
    }

    return decode(type, data: jsonData)
  }

  // MARK: - ------------------------- 字典数组 转 模型数组 --------------------------

  static func decode<T>(_: T.Type,
                        array: [[String: Any]]) -> [T]? where T: Decodable {
    guard let data = getJsonData(with: array) else {
      return nil
    }
    return decode([T].self, data: data)
  }

  // MARK: - ------------------------- json字符串 转 模型 --------------------------

  static func decode<T>(_: T.Type, jsonString: String) -> T? where T: Decodable {
    guard let json = jsonString.data(using: .utf8) else { return nil }
    return decode(T.self, data: json)
  }

  /// 转data
  static func getJsonData(with param: Any) -> Data? {
    guard JSONSerialization.isValidJSONObject(param) else {
      return nil
    }
    guard let data = try? JSONSerialization.data(withJSONObject: param, options: []) else {
      return nil
    }
    return data
  }

  /// data 转 字典
  static func decode(_ data: Data) -> [String: Any]? {
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
      guard let dic = json as? [String: Any] else { return [String: Any]() }
      return dic
    } catch {
      return nil
    }
  }

  static func decode<T>(_ type: T.Type, data: Data) -> T? where T: Decodable {
    var model: T?
    do {
      model = try JSONDecoder().decode(type, from: data)
    } catch let DecodingError.dataCorrupted(context) {
      print("Property data corrupted. \(context.debugDescription). Path: \(context.chainPath())")
    } catch let DecodingError.keyNotFound(key, context) {
      print("Property name :\(key.stringValue) not fount. Path: \(context.chainPath())")
    } catch let DecodingError.valueNotFound(value, context) {
      print("Value :\(value) not fount. Path: \(context.chainPath())")
    } catch let DecodingError.typeMismatch(type, context) {
      print("Type '\(type)' mismatch. \(context.debugDescription). Path: \(context.chainPath())")
    } catch {
      print("Failed to decode.")
    }
    return model
  }
}

extension DecodingError.Context {
  func chainPath() -> String {
    var path = ""
    for item in 0 ..< codingPath.count {
      let key = codingPath[item]
      if item == codingPath.count - 1 {
        path += key.stringValue
      } else {
        path += "\(key.stringValue) -> "
      }
    }
    return path
  }
}

/// 编码器
struct NELoginSampleEncoder {
  let tag: String = "NELoginSampleEncoder"

  // MARK: - ------------------------- 模型转json字符串 --------------------------

  static func encoder<T>(toString model: T) -> String? where T: Encodable {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let data = try? encoder.encode(model) else {
      return nil
    }
    guard let jsonStr = String(data: data, encoding: .utf8) else {
      return nil
    }
    return jsonStr
  }

  // MARK: - ------------------------- 模型转字典 --------------------------

  static func encoder<T>(toDictionry model: T) -> [String: Any]? where T: Encodable {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let data = try? encoder.encode(model) else {
      return nil
    }
    guard let dictionary = try? JSONSerialization.jsonObject(
      with: data,
      options: .mutableLeaves
    ) as? [String: Any] else {
      return nil
    }
    return dictionary
  }
}

extension String {
  // MARK: - ------------------------- 字符串转字典 --------------------------

  func toDictionary() -> [String: Any]? {
    let data = data(using: String.Encoding.utf8)
    guard let dict = try? JSONSerialization.jsonObject(
      with: data!,
      options: JSONSerialization.ReadingOptions.mutableContainers
    ) as? [String: Any] else {
      return nil
    }
    return dict
  }
}

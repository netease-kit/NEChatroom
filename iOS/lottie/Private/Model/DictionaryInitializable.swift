// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

// MARK: - InitializableError

enum InitializableError: Error {
  case invalidInput
}

// MARK: - DictionaryInitializable

protocol DictionaryInitializable {
  init(dictionary: [String: Any]) throws
}

// MARK: - AnyInitializable

protocol AnyInitializable {
  init(value: Any) throws
}

extension Dictionary {
  @_disfavoredOverload
  func value<T, KeyType: RawRepresentable>(for key: KeyType) throws -> T where KeyType.RawValue == Key {
    guard let value = self[key.rawValue] as? T else {
      throw InitializableError.invalidInput
    }
    return value
  }

  func value<T: AnyInitializable, KeyType: RawRepresentable>(for key: KeyType) throws -> T where KeyType.RawValue == Key {
    if let value = self[key.rawValue] as? T {
      return value
    }

    if let value = self[key.rawValue] {
      return try T(value: value)
    }

    throw InitializableError.invalidInput
  }
}

// MARK: - Array + AnyInitializable

extension Array: AnyInitializable where Element == Double {
  init(value: Any) throws {
    guard let array = value as? [Double] else {
      throw InitializableError.invalidInput
    }
    self = array
  }
}

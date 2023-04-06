// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// NSPointerArray 扩展
extension NSPointerArray {
  /// 添加元素
  func addWeakObject<T: NSObjectProtocol>(_ object: T?) {
    guard let weakObjc = object else { return }
    let pointer = Unmanaged.passUnretained(weakObjc).toOpaque()
    addPointer(pointer)
  }

  /// 删除元素
  func removeWeakObject<T: NSObjectProtocol>(_ object: T?) {
    var listenerIndexArray = [Int]()
    for index in 0 ..< allObjects.count {
      let pointerListener = pointer(at: index)
      // 过滤nil
      guard let tempPointer = pointerListener else { continue }
      let tempListener = Unmanaged<T>.fromOpaque(tempPointer).takeUnretainedValue()
      if tempListener.isEqual(object) {
        listenerIndexArray.append(index)
      }
    }
    for listenerIndex in listenerIndexArray {
      if listenerIndex < allObjects.count {
        removePointer(at: listenerIndex)
      }
    }
  }
}

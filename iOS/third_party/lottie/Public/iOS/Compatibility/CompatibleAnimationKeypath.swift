// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)

  /// An Objective-C compatible wrapper around Lottie's AnimationKeypath
  @objc
  public final class CompatibleAnimationKeypath: NSObject {
    // MARK: Lifecycle

    /// Creates a keypath from a dot separated string. The string is separated by "."
    @objc
    public init(keypath: String) {
      animationKeypath = AnimationKeypath(keypath: keypath)
    }

    /// Creates a keypath from a list of strings.
    @objc
    public init(keys: [String]) {
      animationKeypath = AnimationKeypath(keys: keys)
    }

    // MARK: Public

    public let animationKeypath: AnimationKeypath
  }
#endif

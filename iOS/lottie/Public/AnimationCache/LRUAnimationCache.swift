// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@available(*, deprecated, message: """
Use DefaultAnimationCache instead, which is thread-safe and automatically responds to memory pressure.
""")
public typealias LRUAnimationCache = DefaultAnimationCache

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

extension String {
  var localized: String { NSLocalizedString(self, comment: "") }
}

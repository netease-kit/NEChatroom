// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class LiveConfig {
  static const int _defaultGridSide = 2;

  static int get defaultGridSide => _defaultGridSide;

  static int audienceSelectIndex = 1;

  factory LiveConfig() => _instance ??= (_instance = LiveConfig._internal());

  static LiveConfig? _instance;

  LiveConfig._internal();
}

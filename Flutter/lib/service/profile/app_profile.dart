// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:voiceroomkit_ui/service/auth/login_info.dart';

class AppProfile {
  /// self uid
  static String? accountId;

  /// auth token
  static String? accountToken;

  /// is in meeting
  static bool inMeeting = false;

  static String? deepLinkMeetingId;

  /// last av room cname
  // static int lastChannelId;

  /// last meeting id
  static String? lastMeetingId;

  /// appKey
  static String? appKey;

  static void updateProfile(LoginInfo loginInfo) {
    accountId = loginInfo.accountId;
    accountToken = loginInfo.accountToken;
  }

  static void clear() {
    accountToken = null;
    accountId = null;
  }
}

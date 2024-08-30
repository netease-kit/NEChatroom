// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

class NemoAccount {
  String? userUuid;
  String? userName;
  String? icon;
  String? mobile;
  int? rtcUid;
  String? userToken;
  String? imToken;
  int? sex;

  NemoAccount.fromJson(Map? json) {
    userUuid = json?['userUuid'] as String?;
    userName = json?['userName'] as String?;
    icon = json?['icon'] as String?;
    mobile = json?['mobile'] as String?;
    rtcUid = json?['rtcUid'] as int?;
    userToken = json?['userToken'] as String?;
    imToken = json?['imToken'] as String?;
    sex = json?['sex'] as int?;
  }

  NemoAccount(Map<String, dynamic> map) {
    userUuid = map['userUuid'];
    userName = map['userName'];
    icon = map['icon'];
    mobile = map['mobile'];
    rtcUid = map['rtcUid'];
    userToken = map['userToken'];
    imToken = map['imToken'];
    sex = map['sex'];
  }

  @override
  String toString() {
    Map map = <String, dynamic>{
      'userUuid': userUuid,
      'userName': userName,
      'icon': icon,
      'mobile': mobile,
      'rtcUid': rtcUid,
      'userToken': userToken,
      'imToken': imToken,
      'sex': sex,
    };
    return jsonEncode(map);
  }
}

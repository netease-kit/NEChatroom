// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:uuid/uuid.dart';
import 'package:voiceroomkit_ui/config/app_config.dart';
import 'package:voiceroomkit_ui/service/auth/nemo_account.dart';
import 'package:voiceroomkit_ui/service/proto/app_http_proto.dart';

class LoginByNemoProto extends AppHttpProto<NemoAccount> {
  LoginByNemoProto();

  @override
  String path() {
    return '${AppConfig().baseUrl}/nemo/app/initAppAndUser';
  }

  @override
  Map<String, dynamic>? header() {
    return {
      'deviceId': const Uuid().v1(),
      'clientType': 'aos',
      'appkey': AppConfig().appKey,
      'AppSecret': AppConfig().appSecret,
    };
  }

  @override
  NemoAccount result(Map map) {
    return NemoAccount.fromJson(map);
  }

  @override
  Map data() {
    return {
      'sceneType': 2,
    };
  }

  @override
  bool checkLoginState() {
    return false;
  }
}

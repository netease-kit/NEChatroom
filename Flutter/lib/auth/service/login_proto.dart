// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'app_http_proto.dart';
import 'login_info.dart';

enum LoginType { token, verify }

class LoginProto extends AppHttpProto<LoginInfo> {
  final LoginType loginType;

  LoginProto({required this.loginType});

  @override
  String path() {
    switch (loginType) {
      case LoginType.verify:
        return 'ne-meeting-account/loginByMobileVerifyCode';
      default:
        return 'account/login';
    }
  }

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map);
  }

  @override
  Map data() {
    return {
      'loginType': loginType.index,
    };
  }

  @override
  bool checkLoginState() {
    return LoginType.token == loginType;
  }
}

class TokenLoginProto extends LoginProto {
  /// accountId
  final String accountId;

  final String accountToken;

  TokenLoginProto(this.accountId, this.accountToken)
      : super(loginType: LoginType.token);

  @override
  Map data() => {
        ...super.data(),
        'accountId': accountId,
        'accountToken': accountToken,
      };
}

class VerifyCodeLoginProto extends LoginProto {
  /// accountId
  final String mobile;

  final String verifyCode;

  VerifyCodeLoginProto(this.mobile, this.verifyCode)
      : super(loginType: LoginType.verify);

  @override
  Map data() => {
        'mobile': mobile,
        'verifyCode': verifyCode,
      };
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'base_service.dart';
import 'login_by_nemo_proto.dart';
import 'login_info.dart';
import 'login_proto.dart';
import 'nemo_account.dart';
import 'result.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  Future<Result<NemoAccount>> loginByNemo() {
    return execute(LoginByNemoProto());
  }

  Future<Result<LoginInfo>> login(LoginProto loginProto) {
    return execute(loginProto);
  }
}

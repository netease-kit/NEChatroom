// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:voiceroomkit_ui/service/auth/nemo_account.dart';
import 'package:voiceroomkit_ui/service/base_service.dart';
import 'package:voiceroomkit_ui/service/proto/login_by_nemo_proto.dart';
import 'proto/login_proto.dart';
import 'response/result.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  Future<Result<NemoAccount>> loginByNemo() {
    return execute(LoginByNemoProto());
  }
}

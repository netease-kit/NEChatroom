// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:voiceroomkit_ui/service/auth/auth_manager.dart';
import 'package:voiceroomkit_ui/service/client/http_code.dart';
import 'package:voiceroomkit_ui/service/proto/base_proto.dart';
import 'package:voiceroomkit_ui/service/response/result.dart';

/// base service
class BaseService {
  /// execute method
  Future<Result<T>> execute<T>(BaseProto proto) {
    return proto.execute().then((result) {
      if (proto.checkLoginState() &&
          (result.code == HttpCode.verifyError ||
              result.code == HttpCode.tokenError)) {
        AuthManager()
            .tokenIllegal(HttpCode.getMsg(result.msg, 'Token invalid!'));
      }
      return result as Result<T>;
    });
  }
}

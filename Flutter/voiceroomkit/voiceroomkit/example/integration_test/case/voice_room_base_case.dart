// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

///case模板，模板代码的class需要在 [nim_core_test.dart] 中注册。
class HandleVoiceRoomBaseCase extends HandleBaseCase {
  HandleVoiceRoomBaseCase();

  final voiceRoomKit = NEVoiceRoomKit.instance;
  dynamic ret;
  final listenerMap = <String, dynamic>{};

  @override
  Future<ResultBean?> handle(event) async {
    super.handle(event);
    ret = null;
    return handleCaseResult;
  }

  ResultBean? reportCaseResult() {
    if (ret is NEResult) {
      handleCaseResult =
          ResultBean(code: ret!.code, message: ret!.msg, data: ret!.data);
    } else if (ret != null) {
      handleCaseResult = ResultBean.success(message: methodName, data: ret);
    }
    return handleCaseResult;
  }

  void reportInListener(String methodName,
      {int? code, dynamic data, String? message}) {
    IntegratedManager.instance.report(
        methodName, ResultBean(code: code ?? 0, data: data, message: message));
  }
}

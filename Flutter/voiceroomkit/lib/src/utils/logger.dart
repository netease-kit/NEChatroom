// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

mixin _AloggerMixin {
  static const moduleName = 'VoiceRoomKit';

  Alogger? _apiLogger, _commonLogger;

  Alogger get apiLogger {
    _apiLogger ??= Alogger.api(logTag, moduleName);
    return _apiLogger!;
  }

  Alogger get commonLogger {
    _commonLogger ??= Alogger.normal(logTag, moduleName);
    return _commonLogger!;
  }

  String get logTag {
    return runtimeType.toString();
  }
}

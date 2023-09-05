// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class ServersConfig {
  String _appKey = "";

  int get connectTimeout => 30000;

  int get receiveTimeout => 10000;

  static final ServersConfig _instance = ServersConfig._();

  ServersConfig._();

  factory ServersConfig() => _instance;

  String? _privateServerUrl;

  set serverUrl(String url) {
    if (TextUtils.isNotEmpty(url)) {
      _privateServerUrl = url;
    }
  }

  set appKey(String appKey) {
    if (TextUtils.isNotEmpty(appKey)) {
      _appKey = appKey;
    }
  }

  String get baseUrl {
    var baseUrl = _privateServerUrl;
    return baseUrl!;
  }

  String get appKey {
    return _appKey;
  }

  String? userUuid;
  String? token;
  String? deviceId;
}
